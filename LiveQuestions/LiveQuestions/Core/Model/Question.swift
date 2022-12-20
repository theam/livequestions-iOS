import Foundation

struct Question: Identifiable, Hashable, Equatable {
    let id: String
    let text: String
    let status: BoosterSchema.QuestionStatus
    let likes: Set<User.ID>
    let creator: User
    let isAnonymous: Bool
    let createdAt: Date
    let isMine: Bool
}

protocol QuestionModel {
    var id: String { get }
    var text: String { get }
    var status: GraphQLEnum<BoosterSchema.QuestionStatus> { get }
    var likes: [User.ID] { get }
    var isAnonymous: Bool { get }
    var createdAt: TimeInterval { get }
}

extension BoosterSchema.GetQuestionsByTopicIdQuery.Data.ListQuestionReadModels.Item: QuestionModel {}
extension BoosterSchema.QuestionsSubscription.Data.QuestionReadModels: QuestionModel {}

extension Question {
    static func newQuestion(id: String, text: String, isAnonymous: Bool, creator: User) -> Question {
        .init(id: id,
              text: text,
              status: .unanswered,
              likes: [],
              creator: creator,
              isAnonymous: isAnonymous,
              createdAt: .now,
              isMine: true)
    }

    init(model: QuestionModel, creator: User, currentUserId: User.ID) {
        self.init(id: model.id,
                  text: model.text,
                  status: model.status.value ?? .unanswered,
                  likes: Set(model.likes),
                  creator: creator,
                  isAnonymous: Bool(model.isAnonymous),
                  createdAt: Date(timeIntervalSince1970: model.createdAt / 1000),
                  isMine: currentUserId == creator.id)
    }

    func updated(text: String? = nil, status: BoosterSchema.QuestionStatus? = nil, likes: Set<User.ID>? = nil) -> Question {
        .init(
            id: id,
            text: text ?? self.text,
            status: status ?? self.status,
            likes: likes ?? self.likes,
            creator: creator,
            isAnonymous: isAnonymous,
            createdAt: createdAt,
            isMine: isMine
        )
    }
}

extension BoosterSchema.QuestionStatus {
    var toggle: BoosterSchema.QuestionStatus {
        switch self {
        case .answered: return .unanswered
        case .unanswered: return .answered
        case .deleted: return .deleted
        }
    }
}
