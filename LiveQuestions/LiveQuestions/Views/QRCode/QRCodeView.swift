import SwiftUI
import CoreImage.CIFilterBuiltins

struct QRCodeView: View {
    @Environment(\.dismiss) var dismiss
    
    let topic: Topic
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    
    var body: some View {
        NavigationStack {
            VStack {
                Text(topic.title)
                    .multilineTextAlignment(.center)
                    .font(.title)
                    .fontWeight(.semibold)
                    .padding([.top, .horizontal])
                Spacer()
                Image(uiImage: qrCodeImage)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                Text("Share this QR code for others to join your topic!")
                    .multilineTextAlignment(.center)
                    .font(.body)
                    .foregroundColor(.gray)
                    .padding(.top)
                    .frame(width: 230)
                Spacer()
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                    }
                    .tint(.gray)
                }
            }
        }
    }
    
    var qrCodeImage: UIImage {
        filter.message = Data(Deeplink.topic(topic.id).url.absoluteString.utf8)

        if let outputImage = filter.outputImage {
            if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgimg)
            }
        }

        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
}
