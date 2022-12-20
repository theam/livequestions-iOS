import Combine
import Foundation
import Network

/// With this class we can fail requests as soon as possible if we know there isn't Internet connection,
/// because Apollo introduces sometimes a big timeout even if there isn't connection.
final class NetworkMonitor {
    static let shared = NetworkMonitor()
    static var isConnected: Bool { shared.isConnected }

    @Published private(set) var isConnected = true

    private let pathMonitor = NWPathMonitor()

    init() {
        pathMonitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = (path.status == .satisfied)
        }

        pathMonitor.start(queue: .global())
    }

    deinit {
        pathMonitor.cancel()
    }

    static func throwErrorIfNoInternetConnection() throws {
        guard isConnected else {
            throw LiveQuestionsError.noInternetConnection
        }
    }
}
