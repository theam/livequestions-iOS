import Foundation

extension Date {
    var relativeFormatted: String {
        timeIntervalSinceNow < -60 ? formatted(.relative(presentation: .named)) : "Now"
    }
}
