import Foundation

struct QuestionsQuerySequence: AsyncSequence {
    typealias Element = [Question]
    let topicId: Topic.ID
    let currentUserId: User.ID
    let networkClient: NetworkClient

    func makeAsyncIterator() -> QuestionsQueryIterator {
        QuestionsQueryIterator(topicId: topicId, currentUserId: currentUserId, networkClient: networkClient)
    }
}

struct QuestionsQueryIterator: AsyncIteratorProtocol {
    let topicId: Topic.ID
    let currentUserId: User.ID
    let networkClient: NetworkClient
    fileprivate var cursor: GraphQLNullable<BoosterSchema.JSON>? = .null

    mutating func next() async throws -> [Question]? {
        try NetworkMonitor.throwErrorIfNoInternetConnection()
        guard let cursor = cursor else { return nil }

        let query = BoosterSchema.GetQuestionsByTopicIdQuery(topicId: topicId, cursor: cursor)

        guard let response = try? await networkClient.fetch(query: query, cachePolicy: .fetchIgnoringCacheCompletely)?.listQuestionReadModels else { return nil }

        self.cursor = response.cursor.map(GraphQLNullable.some)
        let creatorIds = Set(response.items.map(\.creatorID))

        guard let creatorsById = try? await UsersQuerySequence(ids: creatorIds, networkClient: networkClient, cachePolicy: .returnCacheDataElseFetch).reduce([], +).dictionary(groupedBy: \.id) else { return nil }

        return response.items.compactMap { model in
            guard let creator = creatorsById[model.creatorID] else { return nil }
            return .init(model: model, creator: creator, currentUserId: currentUserId)
        }
    }
}
