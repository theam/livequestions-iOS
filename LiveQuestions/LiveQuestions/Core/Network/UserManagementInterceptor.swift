import Apollo

class UserManagementInterceptor: ApolloInterceptor {
    private let authService: AuthService

    init(authService: AuthService) {
        self.authService = authService
    }

    /// Helper function to add the token then move on to the next step
    private func addTokenAndProceed<Operation: GraphQLOperation>(
        _ token: String,
        to request: HTTPRequest<Operation>,
        chain: RequestChain,
        response: HTTPResponse<Operation>?,
        completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void
    ) {
        request.addHeader(name: "Authorization", value: "Bearer \(token)")
        chain.proceedAsync(request: request, response: response, completion: completion)
    }

    func interceptAsync<Operation: GraphQLOperation>(
        chain: RequestChain,
        request: HTTPRequest<Operation>,
        response: HTTPResponse<Operation>?,
        completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void
    ) {
        Task {
            do {
                let authInfo = try await authService.renewTokenIfNeeded()

                // Renewing worked! Add the token and move on
                self.addTokenAndProceed(authInfo.accessToken, to: request, chain: chain, response: response, completion: completion)
            } catch {
                // Pass the token renewal error up the chain, and do
                // not proceed further. Note that you could also wrap this in a
                // `UserError` if you want.
                chain.handleErrorAsync(error, request: request, response: response, completion: completion)
            }
        }
    }
}
