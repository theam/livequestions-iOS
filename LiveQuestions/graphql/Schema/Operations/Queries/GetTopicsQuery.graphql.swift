// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension BoosterSchema {
  class GetTopicsQuery: GraphQLQuery {
    public static let operationName: String = "GetTopics"
    public static let document: ApolloAPI.DocumentType = .notPersisted(
      definition: .init(
        #"""
        query GetTopics($userId: ID!, $cursor: JSON) {
          ListTopicReadModels(
            filter: {or: [{hostID: {eq: $userId}}, {participantIDs: {includes: $userId}}]}
            afterCursor: $cursor
          ) {
            __typename
            items {
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
            count
            cursor
          }
        }
        """#
      ))

    public var userId: ID
    public var cursor: GraphQLNullable<JSON>

    public init(
      userId: ID,
      cursor: GraphQLNullable<JSON>
    ) {
      self.userId = userId
      self.cursor = cursor
    }

    public var __variables: Variables? { [
      "userId": userId,
      "cursor": cursor
    ] }

    public struct Data: BoosterSchema.SelectionSet {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ApolloAPI.ParentType { BoosterSchema.Objects.Query }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("ListTopicReadModels", ListTopicReadModels.self, arguments: [
          "filter": ["or": [["hostID": ["eq": .variable("userId")]], ["participantIDs": ["includes": .variable("userId")]]]],
          "afterCursor": .variable("cursor")
        ]),
      ] }

      public var listTopicReadModels: ListTopicReadModels { __data["ListTopicReadModels"] }

      /// ListTopicReadModels
      ///
      /// Parent Type: `TopicReadModelConnection`
      public struct ListTopicReadModels: BoosterSchema.SelectionSet {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public static var __parentType: ApolloAPI.ParentType { BoosterSchema.Objects.TopicReadModelConnection }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("items", [Item].self),
          .field("count", Int.self),
          .field("cursor", BoosterSchema.JSON?.self),
        ] }

        public var items: [Item] { __data["items"] }
        public var count: Int { __data["count"] }
        public var cursor: BoosterSchema.JSON? { __data["cursor"] }

        /// ListTopicReadModels.Item
        ///
        /// Parent Type: `TopicReadModel`
        public struct Item: BoosterSchema.SelectionSet {
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

}