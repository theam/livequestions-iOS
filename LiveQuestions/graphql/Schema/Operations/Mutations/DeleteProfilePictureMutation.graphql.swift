// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension BoosterSchema {
  class DeleteProfilePictureMutation: GraphQLMutation {
    public static let operationName: String = "DeleteProfilePicture"
    public static let document: ApolloAPI.DocumentType = .notPersisted(
      definition: .init(
        #"""
        mutation DeleteProfilePicture {
          DeleteProfilePicture
        }
        """#
      ))

    public init() {}

    public struct Data: BoosterSchema.SelectionSet {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ApolloAPI.ParentType { BoosterSchema.Objects.Mutation }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("DeleteProfilePicture", Bool.self),
      ] }

      public var deleteProfilePicture: Bool { __data["DeleteProfilePicture"] }
    }
  }

}