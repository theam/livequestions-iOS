// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension BoosterSchema {
  class GetQuestionsByTopicIdQuery: GraphQLQuery {
    public static let operationName: String = "GetQuestionsByTopicId"
    public static let document: ApolloAPI.DocumentType = .notPersisted(
      definition: .init(
        #"""
        query GetQuestionsByTopicId($topicId: ID!, $cursor: JSON) {
          ListQuestionReadModels(filter: {topicID: {eq: $topicId}}, afterCursor: $cursor) {
            __typename
            items {
              __typename
              id
              text
              status
              creatorID
              isAnonymous
              createdAt
              likes
            }
            count
            cursor
          }
        }
        """#
      ))

    public var topicId: ID
    public var cursor: GraphQLNullable<JSON>

    public init(
      topicId: ID,
      cursor: GraphQLNullable<JSON>
    ) {
      self.topicId = topicId
      self.cursor = cursor
    }

    public var __variables: Variables? { [
      "topicId": topicId,
      "cursor": cursor
    ] }

    public struct Data: BoosterSchema.SelectionSet {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ApolloAPI.ParentType { BoosterSchema.Objects.Query }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("ListQuestionReadModels", ListQuestionReadModels.self, arguments: [
          "filter": ["topicID": ["eq": .variable("topicId")]],
          "afterCursor": .variable("cursor")
        ]),
      ] }

      public var listQuestionReadModels: ListQuestionReadModels { __data["ListQuestionReadModels"] }

      /// ListQuestionReadModels
      ///
      /// Parent Type: `QuestionReadModelConnection`
      public struct ListQuestionReadModels: BoosterSchema.SelectionSet {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public static var __parentType: ApolloAPI.ParentType { BoosterSchema.Objects.QuestionReadModelConnection }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("items", [Item].self),
          .field("count", Int.self),
          .field("cursor", BoosterSchema.JSON?.self),
        ] }

        public var items: [Item] { __data["items"] }
        public var count: Int { __data["count"] }
        public var cursor: BoosterSchema.JSON? { __data["cursor"] }

        /// ListQuestionReadModels.Item
        ///
        /// Parent Type: `QuestionReadModel`
        public struct Item: BoosterSchema.SelectionSet {
          public let __data: DataDict
          public init(data: DataDict) { __data = data }

          public static var __parentType: ApolloAPI.ParentType { BoosterSchema.Objects.QuestionReadModel }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("id", BoosterSchema.ID.self),
            .field("text", String.self),
            .field("status", GraphQLEnum<BoosterSchema.QuestionStatus>.self),
            .field("creatorID", BoosterSchema.ID.self),
            .field("isAnonymous", Bool.self),
            .field("createdAt", Double.self),
            .field("likes", [BoosterSchema.ID].self),
          ] }

          public var id: BoosterSchema.ID { __data["id"] }
          public var text: String { __data["text"] }
          public var status: GraphQLEnum<BoosterSchema.QuestionStatus> { __data["status"] }
          public var creatorID: BoosterSchema.ID { __data["creatorID"] }
          public var isAnonymous: Bool { __data["isAnonymous"] }
          public var createdAt: Double { __data["createdAt"] }
          public var likes: [BoosterSchema.ID] { __data["likes"] }
        }
      }
    }
  }

}