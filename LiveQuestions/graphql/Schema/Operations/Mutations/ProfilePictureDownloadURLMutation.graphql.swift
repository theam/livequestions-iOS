// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension BoosterSchema {
  class ProfilePictureDownloadURLMutation: GraphQLMutation {
    public static let operationName: String = "ProfilePictureDownloadURL"
    public static let document: ApolloAPI.DocumentType = .notPersisted(
      definition: .init(
        #"""
        mutation ProfilePictureDownloadURL {
          ProfilePictureDownloadURL
        }
        """#
      ))

    public init() {}

    public struct Data: BoosterSchema.SelectionSet {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ApolloAPI.ParentType { BoosterSchema.Objects.Mutation }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("ProfilePictureDownloadURL", String.self),
      ] }

      public var profilePictureDownloadURL: String { __data["ProfilePictureDownloadURL"] }
    }
  }

}