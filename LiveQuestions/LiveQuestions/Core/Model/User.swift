import Auth0
import Foundation
import JWTDecode

struct User: Identifiable, Hashable, Equatable, Codable {
    let id: String
    let username: String
    let displayName: String
    let blockedUserIds: Set<User.ID>
    let blockedQuestionIds: Set<Question.ID>
}

protocol UserModel {
    var id: String { get }
    var username: String { get }
    var displayName: String { get }
}

protocol CurrentUserModel: UserModel {
    var blockedUserIDs: Array<User.ID> { get }
    var blockedQuestionIDs: Array<Question.ID> { get }
}

extension BoosterSchema.GetUserQuery.Data.UserReadModel: CurrentUserModel {}
extension BoosterSchema.GetUsersQuery.Data.ListUserReadModels.Item: UserModel {}
extension BoosterSchema.UserSubscription.Data.UserReadModel: CurrentUserModel {}

extension User {
    static let anonymous = User(id: .empty, username: .empty, displayName: .empty, blockedUserIds: [], blockedQuestionIds: [])

    var isAuthenticated: Bool { return id != .empty }

    init(model: UserModel) {
        id = model.id
        username = model.username
        displayName = model.displayName
        blockedUserIds = []
        blockedQuestionIds = []
    }
    
    init(model: CurrentUserModel) {
        id = model.id
        username = model.username
        displayName = model.displayName
        blockedUserIds = Set(model.blockedUserIDs)
        blockedQuestionIds = Set(model.blockedQuestionIDs)
    }
}
