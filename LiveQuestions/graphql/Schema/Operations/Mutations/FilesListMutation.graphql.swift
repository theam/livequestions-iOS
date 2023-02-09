// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension BoosterSchema {
  class FilesListMutation: GraphQLMutation {
    public static let operationName: String = "FilesList"
    public static let document: ApolloAPI.DocumentType = .notPersisted(
      definition: .init(
        #"""
        mutation FilesList {
          FilesList {
            __typename
            name
            properties
            metadata
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
        .field("FilesList", [FilesList].self),
      ] }

      public var filesList: [FilesList] { __data["FilesList"] }

      /// FilesList
      ///
      /// Parent Type: `ListItem`
      public struct FilesList: BoosterSchema.SelectionSet {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public static var __parentType: ApolloAPI.ParentType { BoosterSchema.Objects.ListItem }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("name", String.self),
          .field("properties", BoosterSchema.JSON.self),
          .field("metadata", BoosterSchema.JSON?.self),
        ] }

        public var name: String { __data["name"] }
        public var properties: BoosterSchema.JSON { __data["properties"] }
        public var metadata: BoosterSchema.JSON? { __data["metadata"] }
      }
    }
  }

}