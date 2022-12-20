// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension BoosterSchema {
  class QuestionsSubscription: GraphQLSubscription {
    public static let operationName: String = "QuestionsSubscription"
    public static let document: ApolloAPI.DocumentType = .notPersisted(
      definition: .init(
        """
        subscription QuestionsSubscription($topicId: ID!) {
          QuestionReadModels(filter: {topicID: {eq: $topicId}}) {
            __typename
            id
            text
            status
            creatorID
            isAnonymous
            createdAt
            likes
          }
        }
        """
      ))

    public var topicId: ID

    public init(topicId: ID) {
      self.topicId = topicId
    }

    public var __variables: Variables? { ["topicId": topicId] }

    public struct Data: BoosterSchema.SelectionSet {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ParentType { BoosterSchema.Objects.Subscription }
      public static var __selections: [Selection] { [
        .field("QuestionReadModels", QuestionReadModels?.self, arguments: ["filter": ["topicID": ["eq": .variable("topicId")]]]),
      ] }

      public var questionReadModels: QuestionReadModels? { __data["QuestionReadModels"] }

      /// QuestionReadModels
      ///
      /// Parent Type: `QuestionReadModel`
      public struct QuestionReadModels: BoosterSchema.SelectionSet {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public static var __parentType: ParentType { BoosterSchema.Objects.QuestionReadModel }
        public static var __selections: [Selection] { [
          .field("id", ID.self),
          .field("text", String.self),
          .field("status", GraphQLEnum<QuestionStatus>.self),
          .field("creatorID", ID.self),
          .field("isAnonymous", Bool.self),
          .field("createdAt", Double.self),
          .field("likes", [ID].self),
        ] }

        public var id: ID { __data["id"] }
        public var text: String { __data["text"] }
        public var status: GraphQLEnum<QuestionStatus> { __data["status"] }
        public var creatorID: ID { __data["creatorID"] }
        public var isAnonymous: Bool { __data["isAnonymous"] }
        public var createdAt: Double { __data["createdAt"] }
        public var likes: [ID] { __data["likes"] }
      }
    }
  }

}