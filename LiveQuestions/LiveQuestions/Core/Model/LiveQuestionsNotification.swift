import Foundation

enum LiveQuestionsNotification: String {
    case socketDidReconnect

    var name: Notification.Name { Notification.Name(rawValue: "com.livequestions." + rawValue) }
}
