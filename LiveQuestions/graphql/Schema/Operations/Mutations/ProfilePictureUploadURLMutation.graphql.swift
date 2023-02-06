// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension BoosterSchema {
  class ProfilePictureUploadURLMutation: GraphQLMutation {
    public static let operationName: String = "ProfilePictureUploadURL"
    public static let document: ApolloAPI.DocumentType = .notPersisted(
      definition: .init(
        #"""
        mutation ProfilePictureUploadURL {
          ProfilePictureUploadURL {
            __typename
            url
            fields
          }
        }
        """#
      ))

    public init() {}

    public struct Data: BoosterSchema.SelectionSet {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ApolloAPI.ParentType { BoosterSchema.Objects.Mutation }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("ProfilePictureUploadURL", ProfilePictureUploadURL.self),
      ] }

      public var profilePictureUploadURL: ProfilePictureUploadURL { __data["ProfilePictureUploadURL"] }

      /// ProfilePictureUploadURL
      ///
      /// Parent Type: `PresignedPostResponse`
      public struct ProfilePictureUploadURL: BoosterSchema.SelectionSet {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public static var __parentType: ApolloAPI.ParentType { BoosterSchema.Objects.PresignedPostResponse }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("url", String.self),
          .field("fields", BoosterSchema.JSON.self),
        ] }

        public var url: String { __data["url"] }
        public var fields: BoosterSchema.JSON { __data["fields"] }
      }
    }
  }

}