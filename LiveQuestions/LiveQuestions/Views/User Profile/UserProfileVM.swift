import Foundation
import PhotosUI
import SwiftUI
import CoreTransferable
import Combine

enum ImageState {
    case empty
    case loading
    case success(Image)
    
    var hasImage: Bool {
        guard case .success = self else { return false }
        return true
    }
}

enum ProfilePhotoError: Error {
    case importFailed
    case uploadFailed
    
    var localizedDescription: String {
        switch self {
        case .importFailed: return "Failed to import photo from library"
        case .uploadFailed: return "Failed to upload photo"
        }
    }
}

@MainActor
final class UserProfileVM: ObservableObject {
    @Published var contentState = ContentState.idle
    @Published private(set) var imageState: ImageState
    @Published var isAuthenticated: Bool = true
    @Published var imageSelection: PhotosPickerItem? = nil {
        didSet {
            guard let selection = imageSelection else { return }
            Task { await uploadProfilePicture(item: selection) }
        }
    }
    
    var user: User { userManager.user }
    var isPickingUsernameNeeded: Bool { userManager.isPickingUsernameNeeded }
    
    private var userId: User.ID { userManager.user.id }
    private let userManager: UserManager
    private let topicsManager: TopicsManager
    private let networkClient: NetworkClient
    private let fileService = FileService()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Public
    init(topicsManager: TopicsManager, userManager: UserManager = .shared, networkClient: NetworkClient = .shared) {
        self.topicsManager = topicsManager
        self.userManager = userManager
        self.networkClient = networkClient
        
        if let photo = PhotosCache.shared.profilePhoto(userId: userManager.user.id) {
            imageState = .success(photo)
        } else {
            imageState = .empty
        }
        
        setUpObservers()
    }
    
    func createUser(username: String, displayName: String) async -> Bool {
        do {
            contentState = .loading
            try await userManager.createUserAndSubscribe(username: username, displayName: displayName)
            
            if let data = PhotosCache.shared.profilePhotoData(userId: userId) {
                try await fileService.uploadProfilePicture(data: data)
            }
            return true
        } catch {
            contentState = .didFail(error.localizedDescription)
            return false
        }
    }
    
    func deleteUser() async {
        do {
            contentState = .loading
            try await userManager.deleteUser()
            topicsManager.reset()
            contentState = .idle
        } catch {
            contentState = .didFail(error.localizedDescription)
        }
    }
    
    func signOut() async {
        do {
            try await userManager.signOut()
            topicsManager.reset()
        } catch {
            contentState = .didFail(error.localizedDescription)
        }
    }
    
    func updateName(_ name: String) async throws -> Bool {
        do {
            contentState = .loading
            try await userManager.updateUser(displayName: name)
            contentState = .idle
            return true
        } catch {
            contentState = .didFail(error.localizedDescription)
            return false
        }
    }
    
    // MARK: - Private
    private func setUpObservers() {
        userManager.$user
            .map(\.isAuthenticated)
            .removeDuplicates()
            .assign(to: \.isAuthenticated, on: self)
            .store(in: &cancellables)
        
        networkClient.$isUserAuthorized
            .filter { $0 }
            .first()
            .sink { [weak self] _ in
                guard let self = self else { return }
                Task { await self.downloadProfilePictureIfNeeded() }
            }
            .store(in: &cancellables)
    }
    
    private func downloadProfilePictureIfNeeded() async {        
        guard !imageState.hasImage, !isPickingUsernameNeeded else { return }
        
        imageState = .loading
        
        guard let data = try? await fileService.downloadProfilePicture(),
              let uiImage = UIImage(data: data) else {
            imageState = .empty
            return
        }
    
        try? PhotosCache.shared.saveProfilePhoto(data, userId: userId)
        imageState = .success(.init(uiImage: uiImage))
    }
    
    private func uploadProfilePicture(item: PhotosPickerItem) async {
        imageState = .loading

        guard let data = try? await item.loadTransferable(type: Data.self),
              let uiImage = UIImage(data: data),
              let resizedImage = uiImage.resize(maxSize: .init(width: 800, height: 800)),
              let compressedJPEG = resizedImage.jpegData(compressionQuality: 0.6) else {
            contentState = .didFail(ProfilePhotoError.importFailed.localizedDescription)
            imageState = .empty
            return
        }
        
        do {
            if isPickingUsernameNeeded {
                /// User didn't complete sign up process, we will upload the profile photo after the user is created on the BE
            } else {
                try await fileService.uploadProfilePicture(data: compressedJPEG)
            }
            
            try? PhotosCache.shared.saveProfilePhoto(compressedJPEG, userId: userId)
            imageState = .success(Image(uiImage: uiImage))
        } catch {
            contentState = .didFail(ProfilePhotoError.uploadFailed.localizedDescription)
            imageState = .empty
        }
    }
}
