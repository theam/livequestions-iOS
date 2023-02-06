// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension BoosterSchema {
  class UnblockUserMutation: GraphQLMutation {
    public static let operationName: String = "UnblockUser"
    public static let document: ApolloAPI.DocumentType = .notPersisted(
      definition: .init(
        #"""
        mutation UnblockUser($userId: ID!) {
          UnblockUser(input: {userID: $userId})
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
        .field("UnblockUser", Bool.self, arguments: ["input": ["userID": .variable("userId")]]),
      ] }

      public var unblockUser: Bool { __data["UnblockUser"] }
    }
  }

}