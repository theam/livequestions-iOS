import SwiftUI

@main
struct LiveQuestionsApp: App {
    @StateObject var userManager = UserManager.shared
    @StateObject var topicsManager = TopicsManager(userManager: .shared)
    @State var joinTopic: Topic?

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL(perform: handle(url:))
                .sheet(item: $joinTopic) { topic in
                    NavigationStack {
                        TopicView(topic: topic, topicsManager: topicsManager, userManager: userManager)
                    }
                }
                .environmentObject(userManager)
                .environmentObject(topicsManager)
        }
    }

    private func handle(url: URL) {
        guard let topicLink = Deeplink(url: url), case let .topic(id) = topicLink else { return }

        Task {
            guard let topic = await topicsManager.fetchTopic(id: id) else { return }
            await MainActor.run {
                self.joinTopic = topic
            }
        }
    }
}
