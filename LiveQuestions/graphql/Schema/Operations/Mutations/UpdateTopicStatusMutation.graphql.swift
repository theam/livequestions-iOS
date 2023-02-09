// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension BoosterSchema {
  class UpdateTopicStatusMutation: GraphQLMutation {
    public static let operationName: String = "UpdateTopicStatus"
    public static let document: ApolloAPI.DocumentType = .notPersisted(
      definition: .init(
        #"""
        mutation UpdateTopicStatus($topicId: ID!, $status: TopicStatus!) {
          UpdateTopicStatus(input: {topicID: $topicId, status: $status})
        }
        """#
      ))

    public var topicId: ID
    public var status: GraphQLEnum<TopicStatus>

    public init(
      topicId: ID,
      status: GraphQLEnum<TopicStatus>
    ) {
      self.topicId = topicId
      self.status = status
    }

    public var __variables: Variables? { [
      "topicId": topicId,
      "status": status
    ] }

    public struct Data: BoosterSchema.SelectionSet {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ApolloAPI.ParentType { BoosterSchema.Objects.Mutation }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("UpdateTopicStatus", Bool.self, arguments: ["input": [
          "topicID": .variable("topicId"),
          "status": .variable("status")
        ]]),
      ] }

      public var updateTopicStatus: Bool { __data["UpdateTopicStatus"] }
    }
  }

}