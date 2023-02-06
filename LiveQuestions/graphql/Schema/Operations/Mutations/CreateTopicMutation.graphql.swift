// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension BoosterSchema {
  class CreateTopicMutation: GraphQLMutation {
    public static let operationName: String = "CreateTopic"
    public static let document: ApolloAPI.DocumentType = .notPersisted(
      definition: .init(
        #"""
        mutation CreateTopic($title: String!, $timeToLive: Float!) {
          CreateTopic(input: {title: $title, timeToLive: $timeToLive})
        }
        """#
      ))

    public var title: String
    public var timeToLive: Double

    public init(
      title: String,
      timeToLive: Double
    ) {
      self.title = title
      self.timeToLive = timeToLive
    }

    public var __variables: Variables? { [
      "title": title,
      "timeToLive": timeToLive
    ] }

    public struct Data: BoosterSchema.SelectionSet {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ApolloAPI.ParentType { BoosterSchema.Objects.Mutation }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("CreateTopic", BoosterSchema.ID.self, arguments: ["input": [
          "title": .variable("title"),
          "timeToLive": .variable("timeToLive")
        ]]),
      ] }

      public var createTopic: BoosterSchema.ID { __data["CreateTopic"] }
    }
  }

}