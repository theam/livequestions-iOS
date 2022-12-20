// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension BoosterSchema {
  class UpdateQuestionMutation: GraphQLMutation {
    public static let operationName: String = "UpdateQuestion"
    public static let document: ApolloAPI.DocumentType = .notPersisted(
      definition: .init(
        """
        mutation UpdateQuestion($id: ID!, $question: String!) {
          UpdateQuestion(input: {questionID: $id, question: $question})
        }
        """
      ))

    public var id: ID
    public var question: String

    public init(
      id: ID,
      question: String
    ) {
      self.id = id
      self.question = question
    }

    public var __variables: Variables? { [
      "id": id,
      "question": question
    ] }

    public struct Data: BoosterSchema.SelectionSet {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ParentType { BoosterSchema.Objects.Mutation }
      public static var __selections: [Selection] { [
        .field("UpdateQuestion", Bool.self, arguments: ["input": [
          "questionID": .variable("id"),
          "question": .variable("question")
        ]]),
      ] }

      public var updateQuestion: Bool { __data["UpdateQuestion"] }
    }
  }

}