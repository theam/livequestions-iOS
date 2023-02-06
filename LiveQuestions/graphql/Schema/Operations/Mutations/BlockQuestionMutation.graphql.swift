// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension BoosterSchema {
  class BlockQuestionMutation: GraphQLMutation {
    public static let operationName: String = "BlockQuestion"
    public static let document: ApolloAPI.DocumentType = .notPersisted(
      definition: .init(
        #"""
        mutation BlockQuestion($questionId: ID!) {
          BlockQuestion(input: {questionID: $questionId})
        }
        """#
      ))

    public var questionId: ID

    public init(questionId: ID) {
      self.questionId = questionId
    }

    public var __variables: Variables? { ["questionId": questionId] }

    public struct Data: BoosterSchema.SelectionSet {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ApolloAPI.ParentType { BoosterSchema.Objects.Mutation }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("BlockQuestion", Bool.self, arguments: ["input": ["questionID": .variable("questionId")]]),
      ] }

      public var blockQuestion: Bool { __data["BlockQuestion"] }
    }
  }

}