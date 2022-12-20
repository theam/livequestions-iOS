import Foundation

/// Sorting to be used on Questions
///  - mostRecent: Questions sorted by created at
///  - mostLiked: Questions sorted by count of likes
enum QuestionsSort: Int, Identifiable, CaseIterable {
    case mostRecent
    case mostLiked

    var title: String {
        switch self {
        case .mostRecent: return "Most Recent"
        case .mostLiked: return "Most Liked"
        }
    }

    var image: String {
        switch self {
        case .mostRecent: return "calendar"
        case .mostLiked: return "heart.fill"
        }
    }

    var id: Int { rawValue }
}
