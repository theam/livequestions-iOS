import SwiftUI
import PhotosUI


struct ProfileImage: View {
    let imageState: ImageState
    
    var body: some View {
        switch imageState {
        case .success(let image):
            image.resizable()
        case .loading:
            ProgressView()
        case .empty:
            Image(systemName: "person.fill")
                .font(.system(size: 50))
                .foregroundColor(.white)
        }
    }
}

struct CircularProfileImage: View {
    let imageState: ImageState
    
    init(_ image: Image) {
        self.init(imageState: .success(image))
    }
    
    init(imageState: ImageState) {
        self.imageState = imageState
    }
    
    var body: some View {
        ProfileImage(imageState: imageState)
            .scaledToFill()
            .clipShape(Circle())
    }
}

struct EditableCircularProfileImage: View {
    @ObservedObject var viewModel: UserProfileVM
    
    var body: some View {
        CircularProfileImage(imageState: viewModel.imageState)
            .frame(width: 100, height: 100)
            .background {
                Circle().fill(
                    LinearGradient(
                        colors: [.yellow, .orange],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
            .overlay(alignment: .bottomTrailing) {
                PhotosPicker(selection: $viewModel.imageSelection,
                             matching: .images,
                             photoLibrary: .shared()) {
                    Image(systemName: "pencil.circle.fill")
                        .symbolRenderingMode(.multicolor)
                        .font(.system(size: 30))
                        .foregroundColor(.accentColor)
                }
                .buttonStyle(.borderless)
            }
    }
}
