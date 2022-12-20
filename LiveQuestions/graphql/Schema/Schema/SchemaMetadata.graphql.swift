// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public protocol BoosterSchema_SelectionSet: ApolloAPI.SelectionSet & ApolloAPI.RootSelectionSet
where Schema == BoosterSchema.SchemaMetadata {}

public protocol BoosterSchema_InlineFragment: ApolloAPI.SelectionSet & ApolloAPI.InlineFragment
where Schema == BoosterSchema.SchemaMetadata {}

public protocol BoosterSchema_MutableSelectionSet: ApolloAPI.MutableRootSelectionSet
where Schema == BoosterSchema.SchemaMetadata {}

public protocol BoosterSchema_MutableInlineFragment: ApolloAPI.MutableSelectionSet & ApolloAPI.InlineFragment
where Schema == BoosterSchema.SchemaMetadata {}

public extension BoosterSchema {
  typealias ID = String

  typealias SelectionSet = BoosterSchema_SelectionSet

  typealias InlineFragment = BoosterSchema_InlineFragment

  typealias MutableSelectionSet = BoosterSchema_MutableSelectionSet

  typealias MutableInlineFragment = BoosterSchema_MutableInlineFragment

  enum SchemaMetadata: ApolloAPI.SchemaMetadata {
    public static let configuration: ApolloAPI.SchemaConfiguration.Type = SchemaConfiguration.self

    public static func objectType(forTypename typename: String) -> Object? {
      switch typename {
      case "Mutation": return BoosterSchema.Objects.Mutation
      case "Query": return BoosterSchema.Objects.Query
      case "TopicReadModel": return BoosterSchema.Objects.TopicReadModel
      case "UserReadModelConnection": return BoosterSchema.Objects.UserReadModelConnection
      case "UserReadModel": return BoosterSchema.Objects.UserReadModel
      case "QuestionReadModelConnection": return BoosterSchema.Objects.QuestionReadModelConnection
      case "QuestionReadModel": return BoosterSchema.Objects.QuestionReadModel
      case "TopicReadModelConnection": return BoosterSchema.Objects.TopicReadModelConnection
      case "Subscription": return BoosterSchema.Objects.Subscription
      default: return nil
      }
    }
  }

  enum Objects {}
  enum Interfaces {}
  enum Unions {}

}