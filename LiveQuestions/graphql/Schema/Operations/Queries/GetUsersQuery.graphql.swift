// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension BoosterSchema {
  class GetUsersQuery: GraphQLQuery {
    public static let operationName: String = "GetUsers"
    public static let document: ApolloAPI.DocumentType = .notPersisted(
      definition: .init(
        """
        query GetUsers($ids: [ID!]!, $cursor: JSON) {
          ListUserReadModels(filter: {id: {in: $ids}}, afterCursor: $cursor) {
            __typename
            items {
              __typename
              id
              displayName
              username
            }
            count
            cursor
          }
        }
        """
      ))

    public var ids: [ID]
    public var cursor: GraphQLNullable<JSON>

    public init(
      ids: [ID],
      cursor: GraphQLNullable<JSON>
    ) {
      self.ids = ids
      self.cursor = cursor
    }

    public var __variables: Variables? { [
      "ids": ids,
      "cursor": cursor
    ] }

    public struct Data: BoosterSchema.SelectionSet {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ParentType { BoosterSchema.Objects.Query }
      public static var __selections: [Selection] { [
        .field("ListUserReadModels", ListUserReadModels.self, arguments: [
          "filter": ["id": ["in": .variable("ids")]],
          "afterCursor": .variable("cursor")
        ]),
      ] }

      public var listUserReadModels: ListUserReadModels { __data["ListUserReadModels"] }

      /// ListUserReadModels
      ///
      /// Parent Type: `UserReadModelConnection`
      public struct ListUserReadModels: BoosterSchema.SelectionSet {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public static var __parentType: ParentType { BoosterSchema.Objects.UserReadModelConnection }
        public static var __selections: [Selection] { [
          .field("items", [Item].self),
          .field("count", Int.self),
          .field("cursor", JSON?.self),
        ] }

        public var items: [Item] { __data["items"] }
        public var count: Int { __data["count"] }
        public var cursor: JSON? { __data["cursor"] }

        /// ListUserReadModels.Item
        ///
        /// Parent Type: `UserReadModel`
        public struct Item: BoosterSchema.SelectionSet {
          public let __data: DataDict
          public init(data: DataDict) { __data = data }

          public static var __parentType: ParentType { BoosterSchema.Objects.UserReadModel }
          public static var __selections: [Selection] { [
            .field("id", ID.self),
            .field("displayName", String.self),
            .field("username", String.self),
          ] }

          public var id: ID { __data["id"] }
          public var displayName: String { __data["displayName"] }
          public var username: String { __data["username"] }
        }
      }
    }
  }

}