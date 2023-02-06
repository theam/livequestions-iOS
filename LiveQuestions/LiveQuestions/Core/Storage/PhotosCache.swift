import Foundation
import SwiftUI

final class PhotosCache: ObservableObject {
    static let shared = PhotosCache()
    private let storage = CodableStorage(storage: DiskStorage(path: FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]))
    
    private init() {}
    
    // MARK: - Public
    func saveProfilePhoto<T: Encodable>(_ value: T, userId: User.ID) throws {
        try save(value, for: .profilePhoto(userId: userId))
        objectWillChange.send()
    }
    
    func profilePhoto(userId: User.ID) -> Image? {
        guard let data = profilePhotoData(userId: userId),
              let photo = UIImage(data: data) else { return nil }
        return .init(uiImage: photo)
    }
    
    func profilePhotoData(userId: User.ID) -> Data? {
        try? fetch(for: .profilePhoto(userId: userId))
    }
    
    // MARK: - Private
    private func fetch<T: Decodable>(for key: CacheKey) throws -> T {
        try storage.fetch(for: key.key)
    }
    
    private func save<T: Encodable>(_ value: T, for key: CacheKey, isProtected: Bool = true) throws {
        try storage.save(value, for: key.key, isProtected: isProtected)
    }
}

enum CacheKey {
    case profilePhoto(userId: String)
    
    var key: String {
        switch self {
        case let .profilePhoto(userId): return "/profilePhoto/\(userId)"
        }
    }
}
