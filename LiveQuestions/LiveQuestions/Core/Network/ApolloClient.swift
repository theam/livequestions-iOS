import Apollo
import Foundation

/// Async / await extension for Apollo Client
extension ApolloClient {
    /// Perform an async GraphQL query
    /// - Parameters:
    ///   - query: A GraphQL Query
    ///   - cachePolicy:A cache policy that specifies whether results should be fetched from the server or loaded from the local cache
    /// - Returns: Server's response or throws with an error on failure
    @discardableResult
    func fetch<Query: GraphQLQuery>(query: Query, cachePolicy: CachePolicy) async throws -> Query.Data? {
        return try await withCheckedThrowingContinuation { continuation in
            fetch(query: query, cachePolicy: cachePolicy) { result in
                switch result {
                case let .success(value):
                    if let error = value.errors?.first {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: value.data)
                    }

                case let .failure(error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    /// Perform an async GraphQL mutation
    /// - Parameters:
    ///   - mutation: A GraphQL mutation
    ///   - publishResultToStore: If true, this will publish the result returned from the operation to the cache store. Default is true
    /// - Returns: Mutation result or throws with an error on failure
    @discardableResult
    func mutate<Mutation: GraphQLMutation>(mutation: Mutation, publishResultToStore: Bool = true) async throws -> Mutation.Data? {
        return try await withCheckedThrowingContinuation { continuation in
            perform(mutation: mutation, publishResultToStore: publishResultToStore) { result in
                switch result {
                case let .success(value):
                    if let error = value.errors?.first {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: value.data)
                    }

                case let .failure(error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    /// Subscribe to a GraphQL subscription via a generated asynchronous sequence
    /// - Parameters:
    ///   - subscription: A GraphQL subscription
    ///   - queue: A dispatch queue on which the result handler will be called. Should default to the main queue.
    /// - Returns: An object that can be used to cancel an in progress subscription
    @discardableResult
    func subscribe<Subscription: GraphQLSubscription>(subscription: Subscription, queue: DispatchQueue = .main) -> AsyncThrowingStream<GraphQLResult<Subscription.Data>, Error> {
        AsyncThrowingStream { continuation in
            let request = subscribe(subscription: subscription, queue: queue) { result in
                switch result {
                case let .success(value):
                    continuation.yield(value)
                case let .failure(error):
                    continuation.finish(throwing: error)
                }
            }

            continuation.onTermination = { @Sendable _ in request.cancel() }
        }
    }
}
