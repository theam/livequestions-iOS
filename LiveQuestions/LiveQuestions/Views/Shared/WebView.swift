import SwiftUI
import WebKit

extension URL: Identifiable {
    public var id: String { absoluteString }
}

enum UserAgreement: String, Identifiable {
    case privacyPolicy = "https://theagilemonkeys.notion.site/theagilemonkeys/Live-Questions-Privacy-Policy-49e873b9c639424b97923ba0357ac9cd"
    case termsOfService = "https://theagilemonkeys.notion.site/EULA-01fc01bf8ba34fd1a1b28daba84e724d"
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .privacyPolicy: return "Privacy Policy"
        case .termsOfService: return "Terms of Service"
        }
    }
    
    var url: URL { URL(string: rawValue)! }
}

struct UserAgreementView: View {
    @Environment(\.dismiss) var dismiss
    let agreement: UserAgreement
    
    var body: some View {
        NavigationStack {
            WebView(url: agreement.url)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark.circle.fill")
                        }
                        .tint(.gray)
                    }
                }
                .navigationTitle(agreement.title)
        }
    }
}

struct WebView: UIViewRepresentable {
    let url: URL
 
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
 
    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
}
