import Foundation
import Apollo

enum FileError: Error {
    case notAuthorized
    case presignPostFailure
    case presignGetFailure
    case deleteFileFailure
}

extension URLRequest {
    init(endpoint: FileService.API, accessToken: String? = nil) throws {
        self.init(url: endpoint.url)
        httpMethod = endpoint.httpMethod.value
        
        if let accessToken = accessToken {
            addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        
        let (headers, body) = try endpoint.headersAndBody()
        headers.forEach { addValue($0.value, forHTTPHeaderField: $0.key) }
        
        httpBody = body
    }
}

extension FileService {
    enum HTTPMethod: String {
        case post, put, get, delete, patch
        var value: String { rawValue.uppercased() }
    }
    
    enum API {
        case uploadFile(data: Data, metadata: PresignedPost)
        
        fileprivate func headersAndBody() throws -> ([String: String], Data?) {
            switch self {
            case let .uploadFile(data, metadata):
                let formData = MultipartFormData()
                try metadata.fields.forEach { key, value in
                    try formData.appendPart(string: value, name: key)
                }
                formData.appendPart(data: data, name: "file")
                
                let headers = ["Content-Type": "multipart/form-data; boundary=\(formData.boundary)"]
                let body = try formData.encode()
                return (headers, body)
            }
        }
        
        fileprivate var url: URL {
            switch self {
            case let .uploadFile(_, metadata):
                return URL(string: metadata.url)!
            }
        }
        
        fileprivate var httpMethod: HTTPMethod { return .post }
        private var baseURL: URL { AppEnvironment.config.httpURL }
    }

    struct PresignedPost: Decodable {
        let url: String
        let fields: [String: String]
    }
}
