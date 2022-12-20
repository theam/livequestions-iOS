import Foundation

enum Deeplink {
    case topic(Topic.ID)

    private static let scheme = "qstn"
    private static let topicPath = "topic"
    private static let topicId = "id"

    init?(url: URL) {
        guard let scheme = url.scheme,
            scheme.caseInsensitiveCompare(Self.scheme) == .orderedSame,
            url.host == Self.topicPath,
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let topicId = components.queryItems?.first(where: \.name, is: Self.topicId)?.value else { return nil }
        self = .topic(topicId)
    }

    var url: URL {
        var components = URLComponents()
        components.scheme = Self.scheme

        switch self {
        case let .topic(id):
            components.host = Self.topicPath
            components.queryItems = [URLQueryItem(name: Self.topicId, value: id)]
            return components.url!
        }
    }
}
