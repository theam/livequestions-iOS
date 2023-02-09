import Foundation

final class CodableStorage {
    private let storage: DiskStorage
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    init(
        storage: DiskStorage,
        decoder: JSONDecoder = .init(),
        encoder: JSONEncoder = .init()
    ) {
        self.storage = storage
        self.decoder = decoder
        self.encoder = encoder
    }

    func fetch<T: Decodable>(for key: String) throws -> T {
        let data = try storage.fetchValue(for: key)
        return try decoder.decode(T.self, from: data)
    }

    func save<T: Encodable>(_ value: T, for key: String, isProtected: Bool = true) throws {
        let data = try encoder.encode(value)
        try storage.save(value: data, for: key, isProtected: isProtected)
    }

    func delete(for key: String) throws {
        try storage.delete(for: key)
    }
}
