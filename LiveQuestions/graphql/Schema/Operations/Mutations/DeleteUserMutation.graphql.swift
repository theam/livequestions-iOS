// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension BoosterSchema {
  class DeleteUserMutation: GraphQLMutation {
    public static let operationName: String = "DeleteUser"
    public static let document: ApolloAPI.DocumentType = .notPersisted(
      definition: .init(
        #"""
        mutation DeleteUser {
          DeleteUser
        }
        """#
      ))

    public init() {}

    public struct Data: BoosterSchema.SelectionSet {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ApolloAPI.ParentType { BoosterSchema.Objects.Mutation }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("DeleteUser", Bool.self),
      ] }

      public var deleteUser: Bool { __data["DeleteUser"] }
    }
  }

}