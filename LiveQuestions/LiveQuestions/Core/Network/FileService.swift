import Foundation
import Apollo

typealias JSON = [String : Any?]


final class FileService {
    var accessToken: String? { networkClient.authService.authInfo?.accessToken }
    
    private let networkClient: NetworkClient = .shared
    private var task: URLSessionUploadTask?
    
    func uploadProfilePicture(data: Data) async throws {
        let mutation = BoosterSchema.ProfilePictureUploadURLMutation()
        
        guard let result = try await networkClient.mutate(mutation: mutation)?.profilePictureUploadURL,
              let fields = result.fields.value as? [String: String] else { throw FileError.presignPostFailure }
                   
        let presignedPost = PresignedPost(url: result.url, fields: fields)
        let uploadEndpoint = API.uploadFile(data: data, metadata: presignedPost)
        let uploadRequest = try URLRequest(endpoint: uploadEndpoint)

        _ = try await URLSession.shared.data(for: uploadRequest)
    }
    
    func downloadProfilePicture() async throws -> Data {
        let mutation = BoosterSchema.ProfilePictureDownloadURLMutation()
        
        guard let urlString = try await networkClient.mutate(mutation: mutation)?.profilePictureDownloadURL,
              let url = URL(string: urlString) else { throw FileError.presignGetFailure }
        
        let fileRequest = URLRequest(url: url)
        let (imageData, _) = try await URLSession.shared.data(for: fileRequest)
        return imageData
    }
    
    func removeProfilePicture() async throws {
        let mutation = BoosterSchema.DeleteProfilePictureMutation()
        guard let success = try await networkClient.mutate(mutation: mutation)?.deleteProfilePicture, success else { throw FileError.listFilesFailure }
    }
    
    // **** Working method, but not currently used (except for testing purposes) ****
    func filesList() async throws {
        let mutation = BoosterSchema.FilesListMutation()
        guard let result = try await networkClient.mutate(mutation: mutation)?.filesList else { throw FileError.deleteFileFailure }
        
        debugPrint("Files:")
        debugPrint(result)
    }
}
