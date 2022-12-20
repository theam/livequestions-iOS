import SwiftUI

enum AppColor: String, CaseIterable {
    case blue = "B1E1F8"
    case blueHighlight = "58C9FF"
    case green = "B3F1D0"
    case greenHighlight = "57EB9C"
    case orange = "F8D4C3"
    case orangeHighlight = "FFAA82"
    case pink = "EABBED"
    case pinkHighlight = "F888FF"
    case violet = "D4BCF9"
    case violetHighlight = "C096FF"

    var value: Color { .init(hex: rawValue) }
}

extension Color {
    init(hex: String) {
        var colorString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        colorString = String(colorString.suffix(6)) // This will remove any possible "#" starting character.

        var rgbValue: UInt64 = 0
        Scanner(string: colorString).scanHexInt64(&rgbValue)

        self.init(red: Double((rgbValue & 0xFF0000) >> 16) / 255.0,
                  green: Double((rgbValue & 0x00FF00) >> 8) / 255.0,
                  blue: Double(rgbValue & 0x0000FF) / 255.0)
    }
}
