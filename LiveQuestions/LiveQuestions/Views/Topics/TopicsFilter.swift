import Foundation

/// Filter to be used on Topics
///  - allOpen: All topics where the current user is the host or a participant and are open.
///  - mine: Topics where the current user is the host
///  - others: Topics where the current user is a participant
///  - allOpen: All topics where the current user is the host or a participant and are closed.
enum TopicsFilter: Int, CaseIterable, Identifiable {
    case allOpen
    case mine
    case others
    case allClosed

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .allOpen: return "All Topics"
        case .mine: return "My Topics"
        case .others: return "Topics Joined"
        case .allClosed: return "All Closed"
        }
    }

    var filterBy: (Topic) -> Bool {
        { topic in
            switch self {
            case .allOpen: return topic.status == .open
            case .others: return !topic.isMine
            case .mine: return topic.isMine
            case .allClosed: return topic.status == .closed
            }
        }
    }
}
