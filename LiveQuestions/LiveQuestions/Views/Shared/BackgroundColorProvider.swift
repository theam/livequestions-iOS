import Foundation
import SwiftUI

final class BackgroundColorProvider {
    private static var items: [String: Color] = [:]

    static func color(itemId: String) -> Color {
        if let color = items[itemId] {
            return color
        } else {
            let newColor = AppColor.allCases.randomElement()!.value
            items[itemId] = newColor
            return newColor
        }
    }
}
