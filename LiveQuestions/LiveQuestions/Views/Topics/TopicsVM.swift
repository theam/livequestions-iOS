import Combine
import Foundation
import SwiftUI

@MainActor
final class TopicsVM: ObservableObject {
    /// List of topics to be shown on UI
    @Published var topics: [Topic] = []
    /// Current filter applied on topics
    @Published var filter: TopicsFilter = .allOpen
    /// Current state to be shown on UI (idle, loading, failure)
    @Published var state: ContentState = .idle
    
    var userId: User.ID { userManager.user.id }

    private let manager: TopicsManager
    private let userManager: UserManager
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Public

    /// View model initializer
    /// - Parameters:
    ///   - manager: Topics Manager
    ///   - userManager: User Manager
    init(manager: TopicsManager, userManager: UserManager) {
        self.manager = manager
        self.userManager = userManager

        setUpObservers()
    }

    /// Authenticate user through sign in
    func signIn() async {
        state = .loading

        do {
            try await userManager.signIn()
            state = .idle
        } catch {
            state = .didFail(error.localizedDescription)
        }
    }

    /// Filter topics by filter
    /// - Parameter filter: Filter type to be aplied on list of topics
    func filterTopics(by filter: TopicsFilter) {
        self.filter = filter
        updateDataSource()
    }
    
    func blockUser(_ user: User) async {
        guard userManager.isUserAuthenticated else { return }
        
        do {
            try await manager.blockUser(user)
        } catch {
            state = .didFail(error.localizedDescription)
        }
    }

    /// Fetch topics  & subscribe to topic updates where the user is a host or a participant
    func loadTopics() async {
        guard userManager.isUserAuthenticated else {
            state = .idle
            return
        }

        guard state != .loading else { return }

        manager.subscribeToMyTopicsUpdates()
        /// NOTE: This is provisional. We need to do 2 Topics subscriptions because the OR filter is
        /// not working properly in Booster:
        manager.subscribeToJoinedTopicsUpdates()

        state = .loading
        do {
            try await refreshTopics()
            state = .idle
        } catch {
            state = .didFail(error.localizedDescription)
        }
    }

    /// Change topic's title
    /// - Parameters:
    ///   - topic: Topic to be updated
    ///   - title: Title to be set to topic
    func changeTopicTitle(_ topic: Topic, title: String) async {
        guard userManager.isUserAuthenticated else { return }

        do {
            try await manager.changeTopicTitle(topic, title: title)
        } catch {
            state = .didFail(error.localizedDescription)
        }
    }

    /// Update topic status
    /// - Parameters:
    ///   - topic: Topic to be updated
    ///   - status: Topic status to be set on topic
    func updateTopicStatus(_ topic: Topic, status: BoosterSchema.TopicStatus) async {
        guard userManager.isUserAuthenticated else { return }

        do {
            try await manager.updateTopicStatus(topic, status: status)
        } catch {
            state = .didFail(error.localizedDescription)
        }
    }

    /// Delete topic
    /// - Parameter topic: Topic deleted
    func deleteTopic(_ topic: Topic) async {
        guard userManager.isUserAuthenticated else { return }

        do {
            try await manager.deleteTopic(topic)
        } catch {
            state = .didFail(error.localizedDescription)
        }
    }

    /// Fetch topics
    func refreshTopics() async throws {
        guard userManager.isUserAuthenticated else { return }
        try await manager.fetchTopics()
    }

    /// Create topic with title
    /// - Parameter title: Title for the created topic.
    /// - Parameter expirationDays: The topic is scheduled to be closed after this amount of days.
    func createTopic(title: String, expirationDays: Int) async {
        guard userManager.isUserAuthenticated else { return }
        do {
            try await manager.createTopic(title: title, expirationDays: expirationDays)
        } catch {
            state = .didFail(error.localizedDescription)
        }
    }

    // MARK: - Private

    private func updateDataSource() {
        updateTopics(topics: manager.topics)
    }
    
    /// Update datasource with topics, filtered by the selected filter and sorted by `createdAt`
    /// - Parameter topics: New topics snapshot to be used on datasource
    private func updateTopics(topics: [Topic]) {
        // Note: the animation block is needed to preserve SwiftUI list animations. Not ideal to have it here, but for the sake of simplicity:
        withAnimation {
            let blockedUserIds = manager.blockedUserIds
            
            self.topics = topics
                .filter(filter.filterBy)
                .filter { !blockedUserIds.contains($0.host.id) }
                .sortedDescending(by: \.createdAt)
        }
    }

    /// Set up observers
    ///
    /// **Observes for:**
    /// - Topics updates from the `TopicsManager`
    /// - User authentication to reload topics
    /// - Socket reconnection to reload topics
    private func setUpObservers() {
        manager.$topics.sink { [weak self] topics in
            guard let self = self else { return }
            Task { await MainActor.run { self.updateTopics(topics: topics) } }
        }
        .store(in: &cancellables)
        
        manager.$blockedUserIds.sink { [weak self] _ in
            guard let self = self else { return }
            Task { await MainActor.run { self.updateDataSource() } }
        }
        .store(in: &cancellables)
        
        userManager.$user
            .map(\.isAuthenticated)
            .removeDuplicates()
            .sink { [weak self] _ in
                guard let self = self else { return }
                Task { await self.loadTopics() }
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: LiveQuestionsNotification.socketDidReconnect.name)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                Task { await self.loadTopics() }
            }
            .store(in: &cancellables)
    }
}
