// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension BoosterSchema {
  class JoinedTopicsSubscription: GraphQLSubscription {
    public static let operationName: String = "JoinedTopicsSubscription"
    public static let document: ApolloAPI.DocumentType = .notPersisted(
      definition: .init(
        """
        subscription JoinedTopicsSubscription($userId: ID!) {
          TopicReadModels(filter: {participantIDs: {includes: $userId}}) {
            __typename
            id
            title
            createdAt
            expiredAt
            status
            hostID
            questionsCount
            participantIDs
          }
        }
        """
      ))

    public var userId: ID

    public init(userId: ID) {
      self.userId = userId
    }

    public var __variables: Variables? { ["userId": userId] }

    public struct Data: BoosterSchema.SelectionSet {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ParentType { BoosterSchema.Objects.Subscription }
      public static var __selections: [Selection] { [
        .field("TopicReadModels", TopicReadModels?.self, arguments: ["filter": ["participantIDs": ["includes": .variable("userId")]]]),
      ] }

      public var topicReadModels: TopicReadModels? { __data["TopicReadModels"] }

      /// TopicReadModels
      ///
      /// Parent Type: `TopicReadModel`
      public struct TopicReadModels: BoosterSchema.SelectionSet {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public static var __parentType: ParentType { BoosterSchema.Objects.TopicReadModel }
        public static var __selections: [Selection] { [
          .field("id", ID.self),
          .field("title", String.self),
          .field("createdAt", Double.self),
          .field("expiredAt", Double.self),
          .field("status", GraphQLEnum<TopicStatus>.self),
          .field("hostID", ID.self),
          .field("questionsCount", Double.self),
          .field("participantIDs", [ID].self),
        ] }

        public var id: ID { __data["id"] }
        public var title: String { __data["title"] }
        public var createdAt: Double { __data["createdAt"] }
        public var expiredAt: Double { __data["expiredAt"] }
        public var status: GraphQLEnum<TopicStatus> { __data["status"] }
        public var hostID: ID { __data["hostID"] }
        public var questionsCount: Double { __data["questionsCount"] }
        public var participantIDs: [ID] { __data["participantIDs"] }
      }
    }
  }

}