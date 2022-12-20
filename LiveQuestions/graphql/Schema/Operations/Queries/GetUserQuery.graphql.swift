// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension BoosterSchema {
  class GetUserQuery: GraphQLQuery {
    public static let operationName: String = "GetUser"
    public static let document: ApolloAPI.DocumentType = .notPersisted(
      definition: .init(
        """
        query GetUser($id: ID!) {
          UserReadModel(id: $id) {
            __typename
            id
            displayName
            username
            blockedUserIDs
            blockedQuestionIDs
          }
        }
        """
      ))

    public var id: ID

    public init(id: ID) {
      self.id = id
    }

    public var __variables: Variables? { ["id": id] }

    public struct Data: BoosterSchema.SelectionSet {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ParentType { BoosterSchema.Objects.Query }
      public static var __selections: [Selection] { [
        .field("UserReadModel", UserReadModel?.self, arguments: ["id": .variable("id")]),
      ] }

      public var userReadModel: UserReadModel? { __data["UserReadModel"] }

      /// UserReadModel
      ///
      /// Parent Type: `UserReadModel`
      public struct UserReadModel: BoosterSchema.SelectionSet {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public static var __parentType: ParentType { BoosterSchema.Objects.UserReadModel }
        public static var __selections: [Selection] { [
          .field("id", ID.self),
          .field("displayName", String.self),
          .field("username", String.self),
          .field("blockedUserIDs", [ID].self),
          .field("blockedQuestionIDs", [ID].self),
        ] }

        public var id: ID { __data["id"] }
        public var displayName: String { __data["displayName"] }
        public var username: String { __data["username"] }
        public var blockedUserIDs: [ID] { __data["blockedUserIDs"] }
        public var blockedQuestionIDs: [ID] { __data["blockedQuestionIDs"] }
      }
    }
  }

}