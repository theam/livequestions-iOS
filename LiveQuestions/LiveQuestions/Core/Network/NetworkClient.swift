import Apollo
import ApolloWebSocket
import Combine
import Foundation
import UIKit

final class NetworkClient {
    /// Network client singleton
    static let shared = NetworkClient()
    /// Service response for authentication
    let authService = AuthService()

    private var cancellables: [AnyCancellable] = []
    private lazy var webSocketTransport = WebSocketTransport(websocket: WebSocket(request: URLRequest(url: AppEnvironment.config.websocketBaseUrl), protocol: .graphql_ws))

    /// GraphQL Client to make queries, mutations and subscribe using subscriptions
    ///
    /// **Apollo Documentation**
    /// https://www.apollographql.com/docs/ios/
    private lazy var apolloClient: ApolloClient = {
        let cache = InMemoryNormalizedCache()
        let store = ApolloStore(cache: cache)
        let client = URLSessionClient()
        let provider = NetworkInterceptorProvider(store: store, client: client, authService: authService)

        let requestChainTransport = RequestChainNetworkTransport(interceptorProvider: provider, endpointURL: AppEnvironment.config.apiBaseUrl)
        webSocketTransport.delegate = self

        let splitNetworkTransport = SplitNetworkTransport(
            uploadingNetworkTransport: requestChainTransport,
            webSocketNetworkTransport: webSocketTransport
        )

        return ApolloClient(networkTransport: splitNetworkTransport, store: store)
    }()

    private init() {
        setUpObservers()
    }

    // MARK: - Public

    /// Perform an async GraphQL query
    /// - Parameters:
    ///   - query: A GraphQL Query
    ///   - cachePolicy:A cache policy that specifies whether results should be fetched from the server or loaded from the local cache
    /// - Returns: Server's response or throws with an error on failure
    @discardableResult func fetch<Query: GraphQLQuery>(query: Query, cachePolicy: CachePolicy) async throws -> Query.Data? {
        try NetworkMonitor.throwErrorIfNoInternetConnection()
        return try await apolloClient.fetch(query: query, cachePolicy: cachePolicy)
    }

    /// Perform an async GraphQL mutation
    /// - Parameters:
    ///   - mutation: A GraphQL mutation
    ///   - publishResultToStore: If true, this will publish the result returned from the operation to the cache store. Default is true
    /// - Returns: Mutation result or throws with an error on failure
    @discardableResult func mutate<Mutation: GraphQLMutation>(mutation: Mutation, publishResultToStore: Bool = true) async throws -> Mutation.Data? {
        try NetworkMonitor.throwErrorIfNoInternetConnection()
        return try await apolloClient.mutate(mutation: mutation, publishResultToStore: publishResultToStore)
    }

    /// Subscribe to a GraphQL subscription via a generated asynchronous sequence
    /// - Parameters:
    ///   - subscription: A GraphQL subscription
    ///   - queue: A dispatch queue on which the result handler will be called. Should default to the main queue.
    /// - Returns: An asynchronous throwing sequence
    @discardableResult
    func subscribe<Subscription: GraphQLSubscription>(subscription: Subscription, queue: DispatchQueue = .main) -> AsyncThrowingStream<GraphQLResult<Subscription.Data>, Error> {
        apolloClient.subscribe(subscription: subscription, queue: queue)
    }

    // MARK: - Private

    /// Set up observers
    ///
    /// **Observes for:**
    /// - Auth info changes from `AuthService`
    /// - Notification did enter background
    /// - Notification will enter foreground
    private func setUpObservers() {
        authService.$authInfo
            .compactMap(\ .?.accessToken)
            .removeDuplicates()
            .sink { [weak self] accessToken in
                self?.webSocketTransport.updateConnectingPayload(["Authorization": "Bearer \(accessToken)"])
            }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.webSocketTransport.pauseWebSocketConnection()
            }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.webSocketTransport.resumeWebSocketConnection(autoReconnect: true)
            }
            .store(in: &cancellables)
    }
}

extension NetworkClient: WebSocketTransportDelegate {
    public func webSocketTransportDidConnect(_: WebSocketTransport) {
        debugPrint("Websocket connected!")
        NotificationCenter.default.post(name: LiveQuestionsNotification.socketDidReconnect.name, object: nil)
    }

    public func webSocketTransportDidReconnect(_: WebSocketTransport) {
        debugPrint("Websocket reconnected")
        NotificationCenter.default.post(name: LiveQuestionsNotification.socketDidReconnect.name, object: nil)
    }

    public func webSocketTransport(_: WebSocketTransport, didDisconnectWithError error: Error?) {
        debugPrint("Websocket disconnected with error: \(error.debugDescription)")
    }
}
