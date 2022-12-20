import Foundation

extension Array {
    /// Safely returns the element on the array with the index
    /// - Parameter index: Index of the element
    /// - Returns: Returns the element if the index exists
    subscript(safe index: Int) -> Element? {
        return index < count ? self[index] : nil
    }

    /// Finds the first element on the array where the value of a keypath is equal to
    /// - Parameters:
    ///   - keyPath: Keypath of the element
    ///   - value: Value for which the object's keypath should be equal to
    /// - Returns: First element found
    func first<T: Equatable>(where keyPath: KeyPath<Element, T>, is value: T) -> Element? {
        first(where: { $0[keyPath: keyPath] == value })
    }

    /// Creates chunks of a specific size from an array
    /// - Parameter size: Maximum size of each chunk
    /// - Returns: Array in chunks
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }

    /// Creates a dictionary grouped by a keypath of the array's element
    /// - Parameter keyPath: Keypath used as a key of the dictionary
    /// - Returns: Dictionary
    ///
    /// **Precondition**
    /// The sequence must not have duplicate keys
    func dictionary<T: Hashable>(groupedBy keyPath: KeyPath<Element, T>) -> [T: Element] {
        Dictionary(uniqueKeysWithValues: map { ($0[keyPath: keyPath], $0) })
    }
}

extension Array where Element == Question {
    /// Sort questions by sorting type (most recent or most liked)
    /// - Parameter sorting: Sorting type to be applied
    /// - Returns: Sorted questions
    func sorted(by sorting: QuestionsSort) -> [Element] {
        switch sorting {
        case .mostRecent: return sortedDescending(by: \.createdAt)
        case .mostLiked: return sortedDescending(by: \.likes.count)
        }
    }
}

public extension Sequence {
    /// Sorts elements of a sequence through a comparable keypath in descending order
    /// - Parameter keyPath: Comparable keypath to use for sorting
    /// - Returns: Sorted elements
    func sortedDescending<T: Comparable>(by keyPath: KeyPath<Element, T>) -> [Element] {
        return sorted { a, b in
            a[keyPath: keyPath] > b[keyPath: keyPath]
        }
    }
}
