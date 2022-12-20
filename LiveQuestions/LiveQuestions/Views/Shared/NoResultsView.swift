import SwiftUI

struct NoResultsView: View {
    let title: String
    var subtitle: String? = nil
    var buttonTitle: String? = nil
    var buttonAction: (() -> Void)? = nil

    var body: some View {
        VStack {
            Text(title)
                .multilineTextAlignment(.center)
                .font(.title)
                .padding()

            if let subtitle = subtitle {
                Text(subtitle)
                    .multilineTextAlignment(.center)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding()
            }

            if let buttonTitle = buttonTitle {
                Button {
                    buttonAction?()
                } label: {
                    Text(buttonTitle)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(RoundedButtonStyle())
                .padding(.horizontal, 40)
            }
        }
    }
}

struct NoResultsView_Previews: PreviewProvider {
    @State static var state = ContentState.idle

    static var previews: some View {
        NoResultsView(title: "Title", subtitle: "Subtitle", buttonTitle: "Button Title")
    }
}
