import Foundation

typealias StorageHandler<T> = (Result<T, Error>) -> Void

protocol ReadableStorage {
    func fetchValue(for key: String) throws -> Data
    func fetchValue(for key: String, handler: @escaping StorageHandler<Data>)
}

protocol WritableStorage {
    func save(value: Data, for key: String, isProtected: Bool) throws
    func save(value: Data, for key: String, isProtected: Bool, handler: @escaping StorageHandler<Data>)
}

protocol DeletableStorage {
    func delete(for key: String) throws
    func delete(for key: String, handler: @escaping StorageHandler<Bool>)
}

typealias MaydayStorage = ReadableStorage & WritableStorage & DeletableStorage

enum StorageError: Error {
    case notFound
    case cantWrite(Error)
    case cantDelete(Error)
}

final class DiskStorage {
    private let queue: DispatchQueue
    private let fileManager: FileManager
    private let path: URL

    init(
        path: URL,
        queue: DispatchQueue = .init(label: "DiskCache.Queue"),
        fileManager: FileManager = FileManager.default
    ) {
        self.path = path
        self.queue = queue
        self.fileManager = fileManager
    }
}

extension DiskStorage: WritableStorage {
    func save(value: Data, for key: String, isProtected: Bool) throws {
        let url = path.appendingPathComponent(key)
        do {
            var options: Data.WritingOptions = [.atomic]
            if !isProtected {
                options.insert(.noFileProtection)
            }
            try createFolders(in: url)
            try value.write(to: url, options: options)
        } catch {
            throw StorageError.cantWrite(error)
        }
    }

    func save(value: Data, for key: String, isProtected: Bool, handler: @escaping StorageHandler<Data>) {
        queue.async {
            do {
                try self.save(value: value, for: key, isProtected: isProtected)
                handler(.success(value))
            } catch {
                handler(.failure(error))
            }
        }
    }
}

extension DiskStorage {
    private func createFolders(in url: URL) throws {
        let folderUrl = url.deletingLastPathComponent()
        if !fileManager.fileExists(atPath: folderUrl.path) {
            try fileManager.createDirectory(
                at: folderUrl,
                withIntermediateDirectories: true,
                attributes: nil
            )
        }
    }
}

extension DiskStorage: ReadableStorage {
    func fetchValue(for key: String) throws -> Data {
        let url = path.appendingPathComponent(key)
        guard let data = fileManager.contents(atPath: url.path) else {
            throw StorageError.notFound
        }
        return data
    }

    func fetchValue(for key: String, handler: @escaping StorageHandler<Data>) {
        queue.async {
            handler(Result { try self.fetchValue(for: key) })
        }
    }
}

extension DiskStorage: DeletableStorage {
    func delete(for key: String) throws {
        let url = path.appendingPathComponent(key)
        do {
            try fileManager.removeItem(at: url)
        } catch {
            throw StorageError.cantDelete(error)
        }
    }

    func delete(for key: String, handler: @escaping StorageHandler<Bool>) {
        queue.async {
            do {
                try self.delete(for: key)
                handler(.success(true))
            } catch {
                handler(.failure(error))
            }
        }
    }
}
