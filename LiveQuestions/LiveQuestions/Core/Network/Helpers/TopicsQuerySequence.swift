import Foundation

struct TopicsQuerySequence: AsyncSequence {
    typealias Element = [Topic]
    let user: User
    let networkClient: NetworkClient

    func makeAsyncIterator() -> TopicsQueryIterator {
        TopicsQueryIterator(user: user, networkClient: networkClient)
    }
}

struct TopicsQueryIterator: AsyncIteratorProtocol {
    let user: User
    let networkClient: NetworkClient
    fileprivate var cursor: GraphQLNullable<BoosterSchema.JSON>? = .null

    mutating func next() async throws -> [Topic]? {
        guard let cursor = cursor else { return nil }

        let query = BoosterSchema.GetTopicsQuery(userId: user.id, cursor: cursor)

        guard let response = try? await networkClient.fetch(query: query, cachePolicy: .fetchIgnoringCacheCompletely)?.listTopicReadModels else { return nil }
        self.cursor = response.cursor.map(GraphQLNullable.some)

        let hostsIds = Set(response.items.map(\.hostID))

        guard let hostsById = try? await UsersQuerySequence(ids: hostsIds, networkClient: networkClient, cachePolicy: .returnCacheDataElseFetch).reduce([], +).dictionary(groupedBy: \.id) else { return nil }

        return response.items.compactMap { model in
            guard let host = hostsById[model.hostID] else { return nil }
            return Topic(model: model, host: host, currentUser: user)
        }
    }
}
