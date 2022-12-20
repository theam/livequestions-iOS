// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension BoosterSchema {
  class JoinTopicMutation: GraphQLMutation {
    public static let operationName: String = "JoinTopic"
    public static let document: ApolloAPI.DocumentType = .notPersisted(
      definition: .init(
        """
        mutation JoinTopic($id: ID!) {
          JoinTopic(input: {topicID: $id})
        }
        """
      ))

    public var id: ID

    public init(id: ID) {
      self.id = id
    }

    public var __variables: Variables? { ["id": id] }

    public struct Data: BoosterSchema.SelectionSet {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ParentType { BoosterSchema.Objects.Mutation }
      public static var __selections: [Selection] { [
        .field("JoinTopic", Bool.self, arguments: ["input": ["topicID": .variable("id")]]),
      ] }

      public var joinTopic: Bool { __data["JoinTopic"] }
    }
  }

}