import UIKit
import AVFoundation


extension UIImage {
    func resize(maxSize: CGSize) -> UIImage? {
        let availableRect = AVFoundation.AVMakeRect(aspectRatio: size, insideRect: .init(origin: .zero, size: maxSize))
        let targetSize = availableRect.size

        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)

        return renderer.image { context in
            draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}
