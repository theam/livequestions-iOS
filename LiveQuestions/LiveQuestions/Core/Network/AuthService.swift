import Auth0
import Foundation
import JWTDecode

struct AuthInfo: Equatable {
    let userId: String
    let accessToken: String
    let email: String
}

private enum Configuration {
    static let authAudience = "questionably.booster"
    static let hasRunBeforeKey = "hasRunBefore"
}

final class AuthService: ObservableObject {
    /// Authentication info including userId, access token and email
    @Published private(set) var authInfo: AuthInfo?

    private let credentialsManager = CredentialsManager(authentication: Auth0.authentication())

    /// AuthService initializer
    init() {
        if !UserDefaults.standard.bool(forKey: Configuration.hasRunBeforeKey) {
            _ = credentialsManager.clear()
            UserDefaults.standard.set(true, forKey: Configuration.hasRunBeforeKey)
        }

        Task {
            do {
                try await renewTokenIfNeeded()
            } catch {
                _ = credentialsManager.clear()
            }
        }
    }

    /// Authenticate user through sign in
    @MainActor func signIn() async throws {
        /// For Auth0 to auto-renew an expired access token, it needs to receive a refresh token.
        /// This is made by setting the `offline_access` scope.
        /// https://auth0.com/docs/libraries/auth0-swift/auth0-swift-save-and-renew-tokens
        /// https://auth0.com/docs/get-started/apis/scopes/openid-connect-scopes
        
        let credentials = try await Auth0
            .webAuth()
            .scope("openid profile email offline_access")
            .audience(Configuration.authAudience)
            .start()

        guard credentialsManager.store(credentials: credentials) else {
            throw LiveQuestionsError.signInUnexpectedError
        }

        authInfo = try? authInfo(with: credentials)
    }

    /// Sign out user
    @MainActor func signOut() async throws {
        try await Auth0.webAuth().clearSession()
        _ = credentialsManager.clear()
        authInfo = nil
    }

    /// Get valid authentication info
    /// - Returns: A valid auth info from the keychain or renews the access token if expired
    @discardableResult @MainActor func renewTokenIfNeeded() async throws -> AuthInfo {
        // Calling this method on credentialsManager will renew and store the token too if needed
        let credentials = try await credentialsManager.credentials()

        let authInfo = try authInfo(with: credentials)
        self.authInfo = authInfo

        return authInfo
    }

    /// Extracts authentication info from credentials
    /// - Parameter credentials: Credentials from the Credential Manager
    /// - Returns: Authentication info
    private func authInfo(with credentials: Credentials) throws -> AuthInfo {
        // We only want auth0's userId (not the rest of the User) because we have our
        // own user object in Booster. We need to save the email info from the idToken so we use it too
        // to populate the Booster User entity when creating it.
        guard let tokenData = try? decode(jwt: credentials.idToken),
            let userId = tokenData.subject,
            let email = tokenData["email"].string
        else {
            throw LiveQuestionsError.signInDecodingError
        }

        return AuthInfo(userId: userId, accessToken: credentials.accessToken, email: email)
    }
}
