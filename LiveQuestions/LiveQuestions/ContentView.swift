import SwiftUI

struct ContentView: View {
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var topicsManager: TopicsManager

    @State private var isShowingUserProfile = false

    var body: some View {
        NavigationStack {
            TopicsView(topicsManager: topicsManager, userManager: userManager)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        if userManager.isUserAuthenticated {
                            Button {
                                isShowingUserProfile = true
                            } label: {
                                Image(systemName: "person.crop.circle")
                            }
                        }
                    }
                }
        }
        .sheet(isPresented: $isShowingUserProfile) {
            isShowingUserProfile = false
        } content: {
            UserProfileView()
                .environmentObject(userManager)
                .environmentObject(topicsManager)
        }
        .onReceive(userManager.$user.removeDuplicates()) { _ in
            guard userManager.isPickingUsernameNeeded else { return }
            isShowingUserProfile = true
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(UserManager())
            .environmentObject(TopicsManager(userManager: UserManager()))
    }
}
