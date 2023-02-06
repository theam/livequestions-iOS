// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension BoosterSchema {
  class UpdateQuestionStatusMutation: GraphQLMutation {
    public static let operationName: String = "UpdateQuestionStatus"
    public static let document: ApolloAPI.DocumentType = .notPersisted(
      definition: .init(
        #"""
        mutation UpdateQuestionStatus($id: ID!, $status: QuestionStatus!) {
          UpdateQuestionStatus(input: {questionID: $id, status: $status})
        }
        """#
      ))

    public var id: ID
    public var status: GraphQLEnum<QuestionStatus>

    public init(
      id: ID,
      status: GraphQLEnum<QuestionStatus>
    ) {
      self.id = id
      self.status = status
    }

    public var __variables: Variables? { [
      "id": id,
      "status": status
    ] }

    public struct Data: BoosterSchema.SelectionSet {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ApolloAPI.ParentType { BoosterSchema.Objects.Mutation }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("UpdateQuestionStatus", Bool.self, arguments: ["input": [
          "questionID": .variable("id"),
          "status": .variable("status")
        ]]),
      ] }

      public var updateQuestionStatus: Bool { __data["UpdateQuestionStatus"] }
    }
  }

}