import Foundation

struct Topic: Identifiable, Hashable, Equatable {
    let id: String
    let title: String
    let createdAt: Date
    let expiration: Date
    let status: BoosterSchema.TopicStatus
    let host: User
    let questionsCount: Int
    let hasJoined: Bool
    let isMine: Bool
}

protocol TopicModel {
    var id: String { get }
    var title: String { get }
    var createdAt: TimeInterval { get }
    var expiredAt: TimeInterval { get }
    var status: GraphQLEnum<BoosterSchema.TopicStatus> { get }
    var questionsCount: Double { get }
    var participantIDs: [String] { get }
}

extension BoosterSchema.GetTopicQuery.Data.TopicReadModel: TopicModel {}
extension BoosterSchema.MyTopicsSubscription.Data.TopicReadModels: TopicModel {}
extension BoosterSchema.JoinedTopicsSubscription.Data.TopicReadModels: TopicModel {}
extension BoosterSchema.GetTopicsQuery.Data.ListTopicReadModels.Item: TopicModel {}

extension Topic {
    var isOpen: Bool { status == .open }
    var isClosed: Bool { status == .closed }
    var closedDescription: String { "The topic is closed 🔒" }
    /// Should join topic, before having access to topic
    var shouldJoinFirst: Bool { !isMine && !hasJoined }
    
    init(model: TopicModel, host: User, currentUser: User) {
        self.init(id: model.id,
                  title: model.title,
                  createdAt: Date(timeIntervalSince1970: model.createdAt / 1000),
                  expiration: Date(timeIntervalSince1970: model.expiredAt / 1000),
                  status: model.status.value ?? .open,
                  host: host,
                  questionsCount: Int(model.questionsCount),
                  hasJoined: model.participantIDs.contains(currentUser.id),
                  isMine: host.id == currentUser.id)
    }

    func updated(title: String? = nil, hasJoined: Bool? = nil, status: BoosterSchema.TopicStatus? = nil) -> Topic {
        .init(id: id,
              title: title ?? self.title,
              createdAt: createdAt,
              expiration: expiration,
              status: status ?? self.status,
              host: host,
              questionsCount: questionsCount,
              hasJoined: hasJoined ?? self.hasJoined,
              isMine: isMine)
    }

    static func newTopic(id: String, title: String, timeToLive: TimeInterval, host: User) -> Topic {
        .init(id: id,
              title: title,
              createdAt: .now,
              expiration: .now.addingTimeInterval(timeToLive),
              status: .open,
              host: host,
              questionsCount: 0,
              hasJoined: false,
              isMine: true)
    }
}
