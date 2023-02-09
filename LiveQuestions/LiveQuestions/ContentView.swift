import SwiftUI

struct ContentView: View {
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var topicsManager: TopicsManager

    @State private var isShowingUserProfile = false
    @StateObject private var cache = PhotosCache.shared
    
    var body: some View {
        NavigationStack {
            TopicsView(topicsManager: topicsManager, userManager: userManager)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        if userManager.isUserAuthenticated {
                            Button {
                                isShowingUserProfile = true
                            } label: {
                                Group {
                                    if let photo = cache.profilePhoto(userId: userManager.user.id) {
                                        CircularProfileImage(photo)
                                    } else {
                                        Image(systemName: "person.crop.circle")
                                    }
                                }.frame(width: 30, height: 30)
                            }
                        }
                    }
                }
        }
        .sheet(isPresented: $isShowingUserProfile) {
            isShowingUserProfile = false
        } content: {
            UserProfileView(topicsManager: topicsManager, userManager: userManager)
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
