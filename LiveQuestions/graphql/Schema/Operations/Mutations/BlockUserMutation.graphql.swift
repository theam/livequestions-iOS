// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension BoosterSchema {
  class BlockUserMutation: GraphQLMutation {
    public static let operationName: String = "BlockUser"
    public static let document: ApolloAPI.DocumentType = .notPersisted(
      definition: .init(
        #"""
        mutation BlockUser($userId: ID!) {
          BlockUser(input: {userID: $userId})
        }
        """#
      ))

    public var userId: ID

    public init(userId: ID) {
      self.userId = userId
    }

    public var __variables: Variables? { ["userId": userId] }

    public struct Data: BoosterSchema.SelectionSet {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ApolloAPI.ParentType { BoosterSchema.Objects.Mutation }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("BlockUser", Bool.self, arguments: ["input": ["userID": .variable("userId")]]),
      ] }

      public var blockUser: Bool { __data["BlockUser"] }
    }
  }

}