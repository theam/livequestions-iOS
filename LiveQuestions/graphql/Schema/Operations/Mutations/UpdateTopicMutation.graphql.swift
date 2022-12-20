// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension BoosterSchema {
  class UpdateTopicMutation: GraphQLMutation {
    public static let operationName: String = "UpdateTopic"
    public static let document: ApolloAPI.DocumentType = .notPersisted(
      definition: .init(
        """
        mutation UpdateTopic($id: ID!, $title: String!) {
          UpdateTopic(input: {topicID: $id, title: $title})
        }
        """
      ))

    public var id: ID
    public var title: String

    public init(
      id: ID,
      title: String
    ) {
      self.id = id
      self.title = title
    }

    public var __variables: Variables? { [
      "id": id,
      "title": title
    ] }

    public struct Data: BoosterSchema.SelectionSet {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ParentType { BoosterSchema.Objects.Mutation }
      public static var __selections: [Selection] { [
        .field("UpdateTopic", Bool.self, arguments: ["input": [
          "topicID": .variable("id"),
          "title": .variable("title")
        ]]),
      ] }

      public var updateTopic: Bool { __data["UpdateTopic"] }
    }
  }

}