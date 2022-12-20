import Foundation

enum UserDefaultsManager {
    enum Key: String, CaseIterable {
        case cachedUser
    }

    static func object<T: Codable>(forKey key: Key) -> T? {
        guard let data = UserDefaults.standard.object(forKey: key.rawValue) as? Data else { return nil }
        return try? PropertyListDecoder().decode(T.self, from: data)
    }

    static func save<T: Codable>(_ object: T, forKey key: Key) {
        UserDefaults.standard.set(try? PropertyListEncoder().encode(object), forKey: key.rawValue)
    }

    static func removeObject(forKey key: Key) {
        UserDefaults.standard.removeObject(forKey: key.rawValue)
    }

    static func clear() {
        Key.allCases.forEach(removeObject(forKey:))
    }
}
