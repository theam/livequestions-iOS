import Apollo
import Foundation

struct UsersQuerySequence: AsyncSequence {
    typealias Element = [User]
    let ids: Set<User.ID>
    let networkClient: NetworkClient
    let cachePolicy: CachePolicy

    func makeAsyncIterator() -> UsersQueryIterator {
        UsersQueryIterator(
            idsInChunks: Array(ids).chunked(into: 20),
            networkClient: networkClient,
            cachePolicy: cachePolicy
        )
    }
}

struct UsersQueryIterator: AsyncIteratorProtocol {
    let idsInChunks: [[User.ID]]
    let networkClient: NetworkClient
    let cachePolicy: CachePolicy
    fileprivate var index = 0

    mutating func next() async throws -> [User]? {
        guard let ids = idsInChunks[safe: index] else { return nil }

        let query = BoosterSchema.GetUsersQuery(ids: ids, cursor: .null)
        index += 1

        guard let data = try? await networkClient.fetch(query: query, cachePolicy: cachePolicy) else { return nil }
        return data.listUserReadModels.items.map(User.init)
    }
}
