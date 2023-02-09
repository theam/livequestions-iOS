import Apollo
import AsyncAlgorithms
import Auth0
import Combine
import Foundation

@MainActor
final class UserManager: ObservableObject {
    static let shared = UserManager()

    /// Current user
    @Published var user: User {
        didSet {
            guard user != .anonymous else {
                UserDefaultsManager.removeObject(forKey: .cachedUser)
                return
            }

            UserDefaultsManager.save(user, forKey: .cachedUser)
        }
    }

    /// Is the current user authenticated
    var isUserAuthenticated: Bool { user.isAuthenticated }

    /// Does the current user need to pick an username
    var isPickingUsernameNeeded: Bool { isUserAuthenticated && user.username == .empty }

    private let networkClient: NetworkClient
    private let fileService = FileService()
    private var subscriptionTask: Task<Void, Error>?
    private static let subscriptionRetryInSeconds: TimeInterval = 10

    /// User Manager  initializer
    /// - Parameter networkClient: Network Client
    init(networkClient: NetworkClient = .shared) {
        user = UserDefaultsManager.object(forKey: .cachedUser) ?? .anonymous
        self.networkClient = networkClient

        setUpObservers()
    }

    /// Authenticate user through sign in
    func signIn() async throws {
        try await networkClient.authService.signIn()
    }

    /// Sign out user
    func signOut() async throws {
        try await networkClient.authService.signOut()
    }

    /// Delete user account and sign out
    func deleteUser() async throws {
        try? await fileService.removeProfilePicture()
        
        let mutation = BoosterSchema.DeleteUserMutation()
        try await networkClient.mutate(mutation: mutation)
        try await networkClient.authService.signOut()
    }

    /// Fetch user with id
    /// - Parameters:
    ///   - id: Id of the user to fetch
    ///   - cachePolicy: A cache policy that specifies whether results should be fetched from the server or loaded from the local cache
    /// - Returns: A user if it is found
    func fetchUser(id: User.ID, cachePolicy: CachePolicy = .returnCacheDataElseFetch) async throws -> User? {
        try await networkClient.fetch(query: BoosterSchema.GetUserQuery(id: id), cachePolicy: cachePolicy)?.userReadModel.map(User.init)
    }

    /// Create user and subscribe to user changes
    /// - Parameters:
    ///   - username: User's username
    ///   - displayName: User's display name
    func createUserAndSubscribe(username: String, displayName: String) async throws {
        guard let currentUserEmail = networkClient.authService.authInfo?.email else { return }

        try await networkClient.mutate(mutation: BoosterSchema.CreateUserMutation(username: username, displayName: displayName, email: currentUserEmail))

        user = User(id: user.id, username: username, displayName: displayName, blockedUserIds: [], blockedQuestionIds: [])
        subscribeToUserUpdates()
    }

    /// Update user's display name
    /// - Parameter displayName: Updated users's display name
    func updateUser(displayName: String) async throws {
        try await networkClient.mutate(mutation: BoosterSchema.UpdateUserMutation(displayName: displayName))
    }

    // MARK: - Private

    /// Set up observers
    ///
    /// **Observes for:**
    /// - Auth info changes from the auth service
    private func setUpObservers() {
        Task {
            // We need to make sure we start listening to authInfo updates right after the authService init, otherwise it can happens that
            // this manager retrieves the user from cache and we immediately receive a nil authInfo due to the authService init (the call that retrieves
            // the stored credentials from the keychain takes a bit, it's async):
            _ = try? await networkClient.authService.renewTokenIfNeeded()

            // We listen here for changes in the authInfo status:
            for try await authInfo in networkClient.authService.$authInfo.values.removeDuplicates() {
                guard let authInfo = authInfo else {
                    await MainActor.run {
                        user = .anonymous
                        subscriptionTask?.cancel()
                    }
                    continue
                }

                do {
                    try await fetchOrTriggerBoosterUserCreation(for: authInfo.userId)
                    subscribeToUserUpdates()
                } catch {
                    debugPrint(error)
                }
            }
        }
    }

    /// Subscribe to a subscription for user updates
    private func subscribeToUserUpdates(delayInterval: TimeInterval = 0) {
        subscriptionTask?.cancel()
        guard user.isAuthenticated, !isPickingUsernameNeeded else { return }

        let userId = user.id

        subscriptionTask = Task.delayed(byTimeInterval: delayInterval) { [weak self] in
            guard let self = self else { return }

            let subscription = BoosterSchema.UserSubscription(id: userId)
            let results = self.networkClient.subscribe(subscription: subscription)

            do {
                for try await result in results {
                    guard let readModel = result.data?.userReadModel else { return }
                    await MainActor.run {
                        self.user = User(model: readModel)
                    }
                }
            } catch {
                await self.subscribeToUserUpdates(delayInterval: Self.subscriptionRetryInSeconds)
            }
        }
    }

    /// Fetch user or trigger user creation if the user doesn't exists yet
    /// - Parameter userId: User id
    private func fetchOrTriggerBoosterUserCreation(for userId: User.ID) async throws {
        // We try to fetch the Booster user that belongs to the userId. In case it doesn't exist yet,
        // we need to create it in Booster.
        let fetchedUser = try await fetchUser(id: userId, cachePolicy: .fetchIgnoringCacheData)

        // We assign a local user with an empty username, so the UI will detect that and present the user profile screen
        // where the user must set the mandatory username:
        user = fetchedUser ?? User(id: userId, username: .empty, displayName: .empty, blockedUserIds: [], blockedQuestionIds: [])
    }
}
