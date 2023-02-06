// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension BoosterSchema {
  class GetTopicQuery: GraphQLQuery {
    public static let operationName: String = "GetTopic"
    public static let document: ApolloAPI.DocumentType = .notPersisted(
      definition: .init(
        #"""
        query GetTopic($id: ID!) {
          TopicReadModel(id: $id) {
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

    public var id: ID

    public init(id: ID) {
      self.id = id
    }

    public var __variables: Variables? { ["id": id] }

    public struct Data: BoosterSchema.SelectionSet {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ApolloAPI.ParentType { BoosterSchema.Objects.Query }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("TopicReadModel", TopicReadModel?.self, arguments: ["id": .variable("id")]),
      ] }

      public var topicReadModel: TopicReadModel? { __data["TopicReadModel"] }

      /// TopicReadModel
      ///
      /// Parent Type: `TopicReadModel`
      public struct TopicReadModel: BoosterSchema.SelectionSet {
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