import Foundation

enum EnvironmentConfiguration: String {
    case development
    case production

    var apiBaseUrl: URL {
        switch self {
        case .development:
            // TODO:
            return URL(string: "https://<ADD YOUR DEV URL>.execute-api.eu-west-1.amazonaws.com/dev/graphql")!
        case .production:
            // TODO:
            return URL(string: "https://<ADD YOUR PROD URL>.execute-api.eu-west-1.amazonaws.com/prod/graphql")!
        }
    }

    var websocketBaseUrl: URL {
        switch self {
        case .development:
            // TODO:
            return URL(string: "wss://<ADD YOUR SOCKET DEV URL>.execute-api.eu-west-1.amazonaws.com/dev/")!
        case .production:
            // TODO:
            return URL(string: "wss://<ADD YOUR SOCKET PROD URL>.execute-api.eu-west-1.amazonaws.com/prod/")!
        }
    }
}

enum AppEnvironment {
    static var config: EnvironmentConfiguration {
        #if DEBUG
            return .development
        #else
            return .production
        #endif
    }
}
