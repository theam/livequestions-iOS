// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension BoosterSchema {
  class UpdateUserMutation: GraphQLMutation {
    public static let operationName: String = "UpdateUser"
    public static let document: ApolloAPI.DocumentType = .notPersisted(
      definition: .init(
        #"""
        mutation UpdateUser($displayName: String!) {
          UpdateUser(input: {displayName: $displayName})
        }
        """#
      ))

    public var displayName: String

    public init(displayName: String) {
      self.displayName = displayName
    }

    public var __variables: Variables? { ["displayName": displayName] }

    public struct Data: BoosterSchema.SelectionSet {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ApolloAPI.ParentType { BoosterSchema.Objects.Mutation }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("UpdateUser", Bool.self, arguments: ["input": ["displayName": .variable("displayName")]]),
      ] }

      public var updateUser: Bool { __data["UpdateUser"] }
    }
  }

}