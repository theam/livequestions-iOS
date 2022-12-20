import SwiftUI

struct SignInView: View {
    
    var signInHandler: () -> Void
    @State private var userAgreement: UserAgreement?
    
    var body: some View {
        VStack {
            Text("Sign In to create topics or join others! 🥳")
                .multilineTextAlignment(.center)
                .font(.title)
                .padding()

            Group {
                Text("By tapping Sign In, you're agreeing to our ") +
                Text(.init("[Privacy Policy](\(UserAgreement.privacyPolicy.url))")) +
                Text(" and ") +
                Text(.init("[Terms of Service](\(UserAgreement.termsOfService.url))."))
            }
            .font(.caption)
            .foregroundColor(.gray)
            .accentColor(Color.white.opacity(0.8))
            .padding()
            .multilineTextAlignment(.center)
            .environment(\.openURL, OpenURLAction { url in
                guard let agreement = UserAgreement(rawValue: url.absoluteString) else { return .discarded }
                userAgreement = agreement
                return .handled
            })
            
            Button(action: { signInHandler() }) {
                Text("Sign In")
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(RoundedButtonStyle())
            .padding(.horizontal, 40)
        }
        .padding()
        .sheet(item: $userAgreement) { agreement in
            UserAgreementView(agreement: agreement)
        }
    }
}
