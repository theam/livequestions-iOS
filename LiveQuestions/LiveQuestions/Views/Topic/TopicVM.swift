import Apollo
import Combine
import SwiftUI

@MainActor
final class TopicVM: ObservableObject {
    /// Current sorting applied on questions
    @Published var sorting: QuestionsSort = .mostRecent
    /// Topic to be shown on UI
    @Published var topic: Topic
    /// Current state to be shown on UI (idle, loading, failure)
    @Published var state: ContentState = .idle
    /// List of questions properly sorted
    @Published var questions: [Question] {
        didSet { manager.questionsByTopicId[topic.id] = questions }
    }
    /// Should unblock user, before having access to topic
    @Published var shouldUnblockUserFirst: Bool
    
    var userId: User.ID { userManager.user.id }
    
    private let manager: TopicsManager
    private let userManager: UserManager
    private let networkClient: NetworkClient
    private var subscriptionTask: Task<Void, Error>?
    private var cancellables = Set<AnyCancellable>()
    private static let subscriptionRetryInSeconds: TimeInterval = 10

    /// View model initializer
    /// - Parameters:
    ///   - topic: Topic to visualize
    ///   - manager: Topics Manager
    ///   - userManager: User Manager
    ///   - networkClient: Network Client
    init(topic: Topic,
         manager: TopicsManager,
         userManager: UserManager,
         networkClient: NetworkClient = .shared) {
        self.topic = topic
        questions = (manager.questionsByTopicId[topic.id] ?? []).sorted(by: .mostRecent)
        self.manager = manager
        self.userManager = userManager
        self.networkClient = networkClient
        self.shouldUnblockUserFirst = userManager.user.blockedUserIds.contains(topic.host.id)
        setUpObservers()
    }

    /// Start observation
    func startObservers() {
        setUpObservers()
    }
    
    /// Stop observation
    func stopObservers() {
        subscriptionTask?.cancel()
        cancellables.forEach { $0.cancel() }
    }

    /// Sort questions by sorting type
    /// - Parameter sort: Sorting type to apply to list of questions
    func sortQuestions(by sort: QuestionsSort) {
        sorting = sort
        updateQuestions()
    }

    /// Join a topic where the current user is not the host and neither a participant
    func joinTopic() async {
        do {
            try await manager.join(topic: topic)
        } catch {
            state = .didFail(error.localizedDescription)
        }
    }
    
    func unblockHost() async {
        do {
            try await manager.unblockUser(user: topic.host)
        } catch {
            state = .didFail(error.localizedDescription)
        }
    }

    /// Background color for question
    /// - Parameter questionId: Question's id for the background returned
    /// - Returns: Background color for the respective question
    func backgroundColor(for questionId: Question.ID) -> Color {
        BackgroundColorProvider.color(itemId: questionId)
    }

    /// Can current user delete question
    /// - Parameter question: Question to check if current user can delete question
    /// - Returns: Can question be deleted by current user - `True/False`
    func canDelete(question: Question) -> Bool {
        question.creator.id == userId
    }

    /// Has current user liked question
    /// - Parameter question: Question to check if current user has liked
    /// - Returns: Has current user liked question - `True/False`
    func hasLiked(question: Question) -> Bool {
        return question.likes.contains(userId)
    }

    /// Change question's text
    /// - Parameters:
    ///   - question: Question to be updated
    ///   - text: Question that user wants to ask
    func changeQuestionText(_ question: Question, text: String) async {
        let updatedQuestion = question.updated(text: text)
        updateQuestions(update: updatedQuestion)

        do {
            let mutation = BoosterSchema.UpdateQuestionMutation(id: question.id, question: text)
            _ = try await networkClient.mutate(mutation: mutation)
        } catch {
            updateQuestions(update: question)
            state = .didFail(error.localizedDescription)
        }
    }

    /// Update question status (Answer / Unanswer)
    /// - Parameter question: Question the user wants to update the status to
    func answerOrUnanswer(question: Question) async {
        let newStatus = question.status.toggle
        let updatedQuestion = question.updated(status: newStatus)

        updateQuestions(update: updatedQuestion)

        do {
            let mutation = BoosterSchema.UpdateQuestionStatusMutation(id: question.id, status: .case(newStatus))
            try await networkClient.mutate(mutation: mutation)
        } catch {
            updateQuestions(update: question)
            state = .didFail(error.localizedDescription)
        }
    }
    
    func blockQuestion(_ question: Question) async {
        updateQuestions(remove: question.id)
        
        do {
            let mutation = BoosterSchema.BlockQuestionMutation(questionId: question.id)
            try await networkClient.mutate(mutation: mutation)
        } catch {
            updateQuestions(add: question)
            state = .didFail(error.localizedDescription)
        }
    }

    /// React to question (Like / Unlike)
    /// - Parameter question: Question the user wants to react to
    func likeOrUnlike(question: Question) async {
        guard question.status == .unanswered else { return }

        var likes = question.likes

        if likes.contains(userId) {
            likes.remove(userId)
        } else {
            likes.insert(userId)
        }

        let updatedLikes = likes
        let hasLiked = updatedLikes.contains(userId)
        let updatedQuestion = question.updated(likes: updatedLikes)
        updateQuestions(update: updatedQuestion)

        do {
            let mutation = BoosterSchema.ReactToQuestionMutation(questionId: question.id, like: hasLiked)
            try await networkClient.mutate(mutation: mutation)
        } catch {
            updateQuestions(update: question)
            state = .didFail(error.localizedDescription)
        }
    }

    /// Create question
    /// - Parameters:
    ///   - text: Question that user wants to ask
    ///   - isAnonymous: Ask anonymously
    func createQuestion(text: String, isAnonymous: Bool) async {
        do {
            let mutation = BoosterSchema.CreateQuestionMutation(topicId: topic.id, question: text, isAnonymous: isAnonymous)
            guard let id = try await networkClient.mutate(mutation: mutation)?.createQuestion else { return }

            let question = Question.newQuestion(id: id, text: text, isAnonymous: isAnonymous, creator: userManager.user)
            updateQuestions(add: question)
        } catch {
            state = .didFail(error.localizedDescription)
        }
    }

    /// Delete question
    /// - Parameter question: Question to delete
    func deleteQuestion(_ question: Question) async {
        updateQuestions(remove: question.id)

        do {
            let mutation = BoosterSchema.UpdateQuestionStatusMutation(id: question.id, status: .case(.deleted))
            _ = try await networkClient.mutate(mutation: mutation)
        } catch {
            updateQuestions(add: question)
            state = .didFail(error.localizedDescription)
        }
    }

    /// Load questions & update datasource
    /// - Note:
    /// State will only be updated to loading if the current questions count is 0
    func loadQuestions() async {
        let silentLoading = !questions.isEmpty
        if !silentLoading {
            state = .loading
        }

        do {
            let questions = try await fetchQuestions(topicId: topic.id)
            updateQuestions(replaceAll: questions)
            state = .idle
        } catch {
            guard !silentLoading else { return }
            state = .didFail(error.localizedDescription)
        }
    }

    // MARK: - Private

    /// Fetch questions that belong to topic id
    /// - Parameter topicId: Topic id of the questions to fetch
    private func fetchQuestions(topicId: Topic.ID) async throws -> [Question] {
        try await QuestionsQuerySequence(topicId: topicId, currentUserId: userId, networkClient: networkClient).reduce([], +)
    }

    /// Set up observers
    ///
    /// **Observes for:**
    /// - Topic updates from the `TopicsManager`
    /// - Question updates received from the graphQL subscription
    private func setUpObservers() {
        let topicId = topic.id
        let hostId = topic.host.id
        
        manager.$topics
            .compactMap { $0.first(where: \.id, is: topicId) }
            .assign(to: &$topic)

        manager.$blockedUserIds
            .removeDuplicates()
            .map { $0.contains(hostId) }
            .assign(to: &$shouldUnblockUserFirst)
        
        subscribeForQuestionsUpdates(topicId: topicId)

        NotificationCenter.default.publisher(for: LiveQuestionsNotification.socketDidReconnect.name)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                Task { await self.loadQuestions() }
            }
            .store(in: &cancellables)
    }

    /// Subscribe to a subscription for question updates of a specific topic
    /// - Parameter topicId: Topic id of the questions to observe changes
    /// - Returns: An object that can be used to cancel an in progress subscription
    private func subscribeForQuestionsUpdates(topicId: Topic.ID, delayInterval: TimeInterval = 0) {
        subscriptionTask?.cancel()
        let userId = userManager.user.id
        
        subscriptionTask = Task.delayed(byTimeInterval: delayInterval) { [weak self] in
            guard let self = self else { return }

            
            let subscription = BoosterSchema.QuestionsSubscription(topicId: topicId)
            let results = self.networkClient.subscribe(subscription: subscription)

            do {
                for try await result in results {
                    guard let model = result.data?.questionReadModels,
                        let creator = try? await self.userManager.fetchUser(id: model.creatorID) else { return }

                    let question = Question(model: model, creator: creator, currentUserId: userId)
                    await self.updateQuestions(update: question)
                }
            } catch {
                await self.subscribeForQuestionsUpdates(topicId: topicId, delayInterval: Self.subscriptionRetryInSeconds)
            }
        }
    }

    /// Update data source
    /// - Parameters:
    ///   - replaceAll: Questions to replace currente datasource
    ///   - remove: Question with id to remove
    ///   - add: Question to add
    ///   - update: Question to update
    private func updateQuestions(
        replaceAll: [Question]? = nil,
        remove: Question.ID? = nil,
        add: Question? = nil,
        update: Question? = nil
    ) {
        var updatedQuestions = questions

        if let replaceAll = replaceAll {
            updatedQuestions = replaceAll
        }

        if let remove = remove {
            updatedQuestions = updatedQuestions.filter { $0.id != remove }
        }

        if let add = add {
            updatedQuestions.append(add)
        }

        if let update = update {
            if updatedQuestions.map(\.id).contains(update.id) {
                updatedQuestions = updatedQuestions.map { $0.id == update.id ? update : $0 }
            } else {
                updatedQuestions.append(update)
            }
        }

        // Note: the animation block is needed to preserve SwiftUI list animations. Not ideal to have it here, but for the sake of simplicity:
        withAnimation {
            let blockedQuestionIds = userManager.user.blockedQuestionIds
            
            questions = updatedQuestions
                .filter { !blockedQuestionIds.contains($0.id) }
                .sorted(by: sorting)
        }
    }
}
