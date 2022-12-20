import Apollo
import Combine
import Foundation

@MainActor
final class TopicsManager: ObservableObject {
    /// List of topics where the user is a host or a participant
    @Published private(set) var topics: [Topic] = []
    /// Cached list of questions by topic id
    var questionsByTopicId: [Topic.ID: [Question]] = [:]
    /// Cached list of blocked user ids
    @Published var blockedUserIds: Set<User.ID> = []
    
    private var userId: User.ID { userManager.user.id }
    private let networkClient: NetworkClient
    private let userManager: UserManager
    private var myTopicsSubscriptionTask: Task<Void, Error>?
    private var joinedTopicsSubscriptionTask: Task<Void, Error>?
    private var cancellables: [AnyCancellable] = []
    
    private static let subscriptionRetryInSeconds: TimeInterval = 10

    /// Manager initializer
    /// - Parameters:
    ///   - userManager: User Manager
    ///   - networkClient: Network Client
    init(userManager: UserManager, networkClient: NetworkClient = .shared) {
        self.networkClient = networkClient
        self.userManager = userManager
        
        setUpObservers()
    }
    
    /// Clear datasource and cancel topics subscription
    func reset() {
        topics = []
        myTopicsSubscriptionTask?.cancel()
        joinedTopicsSubscriptionTask?.cancel()
    }
    
    /// Change topic's title
    /// - Parameters:
    ///   - topic: Topic to be updated
    ///   - title: Title to be set to topic
    func changeTopicTitle(_ topic: Topic, title: String) async throws {
        let updatedTopic = topic.updated(title: title)
        updateTopics(update: updatedTopic)

        do {
            let mutation = BoosterSchema.UpdateTopicMutation(id: topic.id, title: title)
            _ = try await networkClient.mutate(mutation: mutation)
        } catch {
            updateTopics(update: topic)
            throw error
        }
    }

    /// Update topic status
    /// - Parameters:
    ///   - topic: Topic to be updated
    ///   - status: Topic status to be set on topic
    func updateTopicStatus(_ topic: Topic, status: BoosterSchema.TopicStatus) async throws {
        let updatedTopic = topic.updated(status: status)
        updateTopics(update: updatedTopic)

        do {
            let mutation = BoosterSchema.UpdateTopicStatusMutation(topicId: topic.id, status: .case(status))
            _ = try await networkClient.mutate(mutation: mutation)
        } catch {
            updateTopics(update: topic)
            throw error
        }
    }

    /// Delete topic
    /// - Parameter topic: Topic deleted
    func deleteTopic(_ topic: Topic) async throws {
        updateTopics(remove: topic.id)

        do {
            let mutation = BoosterSchema.UpdateTopicStatusMutation(topicId: topic.id, status: .case(.deleted))
            _ = try await networkClient.mutate(mutation: mutation)
        } catch {
            updateTopics(add: topic)
            throw error
        }
    }
    
    /// Block user
    /// - Parameter user: User to be blocked
    func blockUser(_ user: User) async throws {
        do {
            blockedUserIds.insert(user.id)
            let mutation = BoosterSchema.BlockUserMutation(userId: user.id)
            try await networkClient.mutate(mutation: mutation)
        } catch {
            blockedUserIds.remove(user.id)
        }
    }
    
    /// Unblock user
    /// - Parameter user: User to be unblocked
    func unblockUser(user: User) async throws {
        do {
            blockedUserIds.remove(user.id)
            let mutation = BoosterSchema.UnblockUserMutation(userId: user.id)
            try await networkClient.mutate(mutation: mutation)
        } catch {
            blockedUserIds.insert(user.id)
        }
    }

    /// Fetch topic with id.
    /// - Parameter id: Id of the topic to be fetched.
    /// - Returns: Topic if it is found.
    func fetchTopic(id: Topic.ID) async -> Topic? {
        let query = BoosterSchema.GetTopicQuery(id: id)
        guard let model = try? await networkClient.fetch(query: query, cachePolicy: .fetchIgnoringCacheCompletely)?.topicReadModel,
            let host = try? await userManager.fetchUser(id: model.hostID) else { return nil }

        return Topic(model: model, host: host, currentUser: userManager.user)
    }

    /// Join a topic where the current user is not the host and neither a participant.
    /// - Parameter topic: Topic to join
    func join(topic: Topic) async throws {
        let mutation = BoosterSchema.JoinTopicMutation(id: topic.id)
        guard let success = try await networkClient.mutate(mutation: mutation)?.joinTopic, success else { return }
        updateTopics(update: topic.updated(hasJoined: true))
    }

    /// Subscribe to a subscription for topics updates where user is a host.
    func subscribeToMyTopicsUpdates(delayInterval: TimeInterval = 0) {
        myTopicsSubscriptionTask?.cancel()

        let userId = userId
        myTopicsSubscriptionTask = Task.delayed(byTimeInterval: delayInterval) { [weak self] in
            guard let self = self else { return }

            let subscription = BoosterSchema.MyTopicsSubscription(userId: userId)
            let results = self.networkClient.subscribe(subscription: subscription)

            do {
                for try await result in results {
                    guard let model = result.data?.topicReadModels,
                        let host = try? await self.userManager.fetchUser(id: model.hostID) else { return }

                    let user = await self.userManager.user
                    let topic = Topic(model: model, host: host, currentUser: user)

                    await MainActor.run { self.updateTopics(update: topic) }
                }
            } catch {
                await self.subscribeToMyTopicsUpdates(delayInterval: Self.subscriptionRetryInSeconds)
            }
        }
    }

    /// Subscribe to a subscription for topics updates where user is a participant.
    /// NOTE: This is provisional. We need to do 2 Topics subscriptions because the OR filter is
    /// not working properly in Booster.
    func subscribeToJoinedTopicsUpdates(delayInterval: TimeInterval = 0) {
        joinedTopicsSubscriptionTask?.cancel()

        let userId = userId
        joinedTopicsSubscriptionTask = Task.delayed(byTimeInterval: delayInterval) { [weak self] in
            guard let self = self else { return }

            let subscription = BoosterSchema.JoinedTopicsSubscription(userId: userId)
            let results = self.networkClient.subscribe(subscription: subscription)

            do {
                for try await result in results {
                    guard let model = result.data?.topicReadModels,
                        let host = try? await self.userManager.fetchUser(id: model.hostID) else { return }

                    let user = await self.userManager.user
                    let topic = Topic(model: model, host: host, currentUser: user)

                    await MainActor.run { self.updateTopics(update: topic) }
                }
            } catch {
                await self.subscribeToJoinedTopicsUpdates(delayInterval: Self.subscriptionRetryInSeconds)
            }
        }
    }

    /// Create topic with title
    /// - Parameter title: Title for the created topic
    /// - Parameter expirationDays: The topic is scheduled to be closed after this amount of days.
    func createTopic(title: String, expirationDays: Int) async throws {
        let expirationInterval: TimeInterval = 60 * 60 * 24 * Double(expirationDays) * 1000 // Days in milliseconds
        let mutation = BoosterSchema.CreateTopicMutation(title: title, timeToLive: expirationInterval)

        let id = try await networkClient.mutate(mutation: mutation)?.createTopic
        guard let id = id else { return }

        let topic = Topic.newTopic(id: id, title: title, timeToLive: expirationInterval, host: userManager.user)
        updateTopics(add: topic)
    }

    /// Fetch topics
    func fetchTopics() async throws {
        try NetworkMonitor.throwErrorIfNoInternetConnection()
        let topics = try await TopicsQuerySequence(user: userManager.user, networkClient: networkClient).reduce([], +)
        updateTopics(replaceAll: topics)
    }

    // MARK: - Private
    
    /// Update data source
    /// - Parameters:
    ///   - replaceAll: Topics to replace currente datasource
    ///   - remove: Topic with id to remove
    ///   - add: Topic to add
    ///   - update: Topic to update
    private func updateTopics(
        replaceAll: [Topic]? = nil,
        remove: Topic.ID? = nil,
        add: Topic? = nil,
        update: Topic? = nil
    ) {
        var updatedTopics = topics

        if let replaceAll = replaceAll {
            updatedTopics = replaceAll
        }

        if let remove = remove {
            updatedTopics = updatedTopics.filter { $0.id != remove }
        }

        if let add = add {
            updatedTopics.append(add)
        }

        if let update = update {
            if updatedTopics.map(\.id).contains(update.id) {
                updatedTopics = updatedTopics.map { $0.id == update.id ? update : $0 }
            } else {
                updatedTopics.append(update)
            }
        }

        topics = updatedTopics
    }
    
    /// Set up observers
    ///
    /// **Observes for:**
    /// - Blocked user ids changes on the current user
    private func setUpObservers() {
        userManager.$user
            .map(\.blockedUserIds)
            .removeDuplicates()
            .receive(on: OperationQueue.main)
            .assign(to: \.blockedUserIds, on: self)
            .store(in: &cancellables)
    }
}
