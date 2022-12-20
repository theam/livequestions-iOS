import Foundation

enum LiveQuestionsError: Error, CustomStringConvertible, LocalizedError {
    case noInternetConnection
    case signInUnexpectedError
    case signInDecodingError

    var description: String {
        switch self {
        case .noInternetConnection: return "Check your Internet connection."
        case .signInUnexpectedError: return "Unexpected error when trying to sign in."
        case .signInDecodingError: return "Unexpected error when trying to decode the authorization token."
        }
    }

    var errorDescription: String? { description }
}
