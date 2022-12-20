// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension BoosterSchema {
  class ReactToQuestionMutation: GraphQLMutation {
    public static let operationName: String = "ReactToQuestion"
    public static let document: ApolloAPI.DocumentType = .notPersisted(
      definition: .init(
        """
        mutation ReactToQuestion($questionId: ID!, $like: Boolean!) {
          ReactToQuestion(input: {questionID: $questionId, like: $like})
        }
        """
      ))

    public var questionId: ID
    public var like: Bool

    public init(
      questionId: ID,
      like: Bool
    ) {
      self.questionId = questionId
      self.like = like
    }

    public var __variables: Variables? { [
      "questionId": questionId,
      "like": like
    ] }

    public struct Data: BoosterSchema.SelectionSet {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ParentType { BoosterSchema.Objects.Mutation }
      public static var __selections: [Selection] { [
        .field("ReactToQuestion", Bool.self, arguments: ["input": [
          "questionID": .variable("questionId"),
          "like": .variable("like")
        ]]),
      ] }

      public var reactToQuestion: Bool { __data["ReactToQuestion"] }
    }
  }

}