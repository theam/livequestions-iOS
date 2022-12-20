import Apollo
import Foundation

struct NetworkInterceptorProvider: InterceptorProvider {
    // These properties will remain the same throughout the life of the `InterceptorProvider`, even though they
    // will be handed to different interceptors.
    private let store: ApolloStore
    private let client: URLSessionClient
    private let authService: AuthService

    init(store: ApolloStore, client: URLSessionClient, authService: AuthService) {
        self.store = store
        self.client = client
        self.authService = authService
    }

    func interceptors<Operation: GraphQLOperation>(for _: Operation) -> [ApolloInterceptor] {
        return [
            MaxRetryInterceptor(),
            CacheReadInterceptor(store: store),
            UserManagementInterceptor(authService: authService),
            RequestLoggingInterceptor(),
            NetworkFetchInterceptor(client: client),
            ResponseLoggingInterceptor(),
            ResponseCodeInterceptor(),
            JSONResponseParsingInterceptor(),
            AutomaticPersistedQueryInterceptor(),
            CacheWriteInterceptor(store: store),
        ]
    }
}
