// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension BoosterSchema {
  class CreateUserMutation: GraphQLMutation {
    public static let operationName: String = "CreateUser"
    public static let document: ApolloAPI.DocumentType = .notPersisted(
      definition: .init(
        #"""
        mutation CreateUser($username: String!, $displayName: String!, $email: String!) {
          CreateUser(
            input: {displayName: $displayName, username: $username, email: $email}
          )
        }
        """#
      ))

    public var username: String
    public var displayName: String
    public var email: String

    public init(
      username: String,
      displayName: String,
      email: String
    ) {
      self.username = username
      self.displayName = displayName
      self.email = email
    }

    public var __variables: Variables? { [
      "username": username,
      "displayName": displayName,
      "email": email
    ] }

    public struct Data: BoosterSchema.SelectionSet {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ApolloAPI.ParentType { BoosterSchema.Objects.Mutation }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("CreateUser", String.self, arguments: ["input": [
          "displayName": .variable("displayName"),
          "username": .variable("username"),
          "email": .variable("email")
        ]]),
      ] }

      public var createUser: String { __data["CreateUser"] }
    }
  }

}