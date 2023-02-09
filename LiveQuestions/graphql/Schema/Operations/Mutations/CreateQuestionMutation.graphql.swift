// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension BoosterSchema {
  class CreateQuestionMutation: GraphQLMutation {
    public static let operationName: String = "CreateQuestion"
    public static let document: ApolloAPI.DocumentType = .notPersisted(
      definition: .init(
        #"""
        mutation CreateQuestion($topicId: ID!, $question: String!, $isAnonymous: Boolean!) {
          CreateQuestion(
            input: {topicID: $topicId, question: $question, isAnonymous: $isAnonymous}
          )
        }
        """#
      ))

    public var topicId: ID
    public var question: String
    public var isAnonymous: Bool

    public init(
      topicId: ID,
      question: String,
      isAnonymous: Bool
    ) {
      self.topicId = topicId
      self.question = question
      self.isAnonymous = isAnonymous
    }

    public var __variables: Variables? { [
      "topicId": topicId,
      "question": question,
      "isAnonymous": isAnonymous
    ] }

    public struct Data: BoosterSchema.SelectionSet {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ApolloAPI.ParentType { BoosterSchema.Objects.Mutation }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("CreateQuestion", BoosterSchema.ID.self, arguments: ["input": [
          "topicID": .variable("topicId"),
          "question": .variable("question"),
          "isAnonymous": .variable("isAnonymous")
        ]]),
      ] }

      public var createQuestion: BoosterSchema.ID { __data["CreateQuestion"] }
    }
  }

}