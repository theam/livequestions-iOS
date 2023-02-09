// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension BoosterSchema {
  class JoinedTopicsSubscription: GraphQLSubscription {
    public static let operationName: String = "JoinedTopicsSubscription"
    public static let document: ApolloAPI.DocumentType = .notPersisted(
      definition: .init(
        #"""
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
        """#
      ))

    public var userId: ID

    public init(userId: ID) {
      self.userId = userId
    }

    public var __variables: Variables? { ["userId": userId] }

    public struct Data: BoosterSchema.SelectionSet {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ApolloAPI.ParentType { BoosterSchema.Objects.Subscription }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("TopicReadModels", TopicReadModels?.self, arguments: ["filter": ["participantIDs": ["includes": .variable("userId")]]]),
      ] }

      public var topicReadModels: TopicReadModels? { __data["TopicReadModels"] }

      /// TopicReadModels
      ///
      /// Parent Type: `TopicReadModel`
      public struct TopicReadModels: BoosterSchema.SelectionSet {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public static var __parentType: ApolloAPI.ParentType { BoosterSchema.Objects.TopicReadModel }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("id", BoosterSchema.ID.self),
          .field("title", String.self),
          .field("createdAt", Double.self),
          .field("expiredAt", Double.self),
          .field("status", GraphQLEnum<BoosterSchema.TopicStatus>.self),
          .field("hostID", BoosterSchema.ID.self),
          .field("questionsCount", Double.self),
          .field("participantIDs", [BoosterSchema.ID].self),
        ] }

        public var id: BoosterSchema.ID { __data["id"] }
        public var title: String { __data["title"] }
        public var createdAt: Double { __data["createdAt"] }
        public var expiredAt: Double { __data["expiredAt"] }
        public var status: GraphQLEnum<BoosterSchema.TopicStatus> { __data["status"] }
        public var hostID: BoosterSchema.ID { __data["hostID"] }
        public var questionsCount: Double { __data["questionsCount"] }
        public var participantIDs: [BoosterSchema.ID] { __data["participantIDs"] }
      }
    }
  }

}