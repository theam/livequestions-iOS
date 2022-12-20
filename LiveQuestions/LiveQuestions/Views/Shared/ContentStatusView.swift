import AlertToast
import SwiftUI

enum ContentState: Equatable {
    case idle
    case loading
    case didFail(String, timestamp: TimeInterval = Date.now.timeIntervalSince1970)

    var errorMessage: String? {
        guard case let .didFail(message, _) = self else { return nil }
        return message
    }

    var isLoading: Bool { self == .loading }
    var hasFailed: Bool { self != .idle && self != .loading }
}

struct ContainerView<Content: View>: View {
    @Binding var state: ContentState
    var content: () -> Content

    @State private var isShowingLoadingHUD = false
    @State private var isShowingErrorHUD = false

    var body: some View {
        content()
            .onChange(of: state) { state in
                isShowingLoadingHUD = state.isLoading
                isShowingErrorHUD = state.hasFailed
            }
            .toast(isPresenting: $isShowingLoadingHUD) {
                AlertToast(displayMode: .alert, type: .loading)
            }
            .toast(isPresenting: $isShowingErrorHUD) {
                AlertToast(type: .systemImage("xmark", .red), subTitle: state.errorMessage)
            }
    }
}

struct ContainerView_Previews: PreviewProvider {
    @State static var state = ContentState.idle

    static var previews: some View {
        Text("Hello").frame(maxWidth: .infinity, maxHeight: .infinity)
            .toast(isPresenting: .constant(true)) {
                AlertToast(type: .systemImage("xmark", .red), subTitle: "What an error!")
            }
    }
}
