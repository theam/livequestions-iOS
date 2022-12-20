import SwiftUI

struct UserProfileView: View {
    @EnvironmentObject private var userManager: UserManager
    @EnvironmentObject private var topicsManager: TopicsManager
    @Environment(\.presentationMode) private var presentationMode

    @State private var username = String.empty
    @State private var displayName = String.empty
    @State private var contentState = ContentState.idle
    @State private var isShowingDeleteAccountAlert = false

    private var user: User { userManager.user }

    private var navigationTitle: String {
        userManager.isPickingUsernameNeeded ? "Welcome! 🥳" : "@" + user.username
    }

    var body: some View {
        NavigationView {
            ContainerView(state: $contentState) {
                ZStack {
                    Color.black.edgesIgnoringSafeArea(.all)

                    VStack {
                        Image(systemName: "person")
                            .resizable()
                            .scaledToFit()
                            .frame(minWidth: 30, maxWidth: 60, minHeight: 30, maxHeight: 60)
                            .padding(30)
                            .background(Circle().strokeBorder(.white, lineWidth: 2))
                            .padding(.bottom, 40)

                        if userManager.isPickingUsernameNeeded {
                            TextField("Username", text: $username)
                                .textFieldStyle(RoundedTextFieldStyle())
                                .padding(.top, 10)

                            Text("Choose wisely, the username is unique and can't be changed later.")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding(.bottom, 10)
                        }

                        TextField("Display name", text: $displayName)
                            .textFieldStyle(RoundedTextFieldStyle())
                            .padding(.top, 10)

                        if userManager.isPickingUsernameNeeded {
                            Text("You can change your display name whenever you want.")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding(.bottom, 10)
                        }

                        Spacer()

                        Group {
                            if userManager.isPickingUsernameNeeded {
                                Button(action: createUserAction) {
                                    Text("Save").frame(maxWidth: .infinity)
                                }
                            } else {
                                Button(action: updateUserAction) {
                                    Text("Update").frame(maxWidth: .infinity)
                                }
                            }
                        }
                        .buttonStyle(RoundedButtonStyle())
                        .padding(.bottom, 50)
                    }
                    .padding(.horizontal)
                    .padding()
                    .navigationTitle(navigationTitle)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            if !userManager.isPickingUsernameNeeded {
                                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                                    Image(systemName: "xmark.circle.fill")
                                }
                                .tint(.gray)
                            }
                        }

                        ToolbarItem(placement: .navigationBarLeading) {
                            Menu(content: {
                                Button("Sign Out", action: signOutAction)
                                Button("Delete Account", role: .destructive) { isShowingDeleteAccountAlert = true }
                            }) { Image(systemName: "ellipsis.circle") }
                        }
                    }
                }
                .onAppear {
                    username = user.username
                    displayName = user.displayName
                }
                .onReceive(userManager.$user) { user in
                    guard !user.isAuthenticated else { return }

                    // Ugly fix to give the Auth0 webView some time to be dismissed first:
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                .interactiveDismissDisabled(userManager.isPickingUsernameNeeded)
            }
            .alert("Are you sure you want to delete your account?",
                   isPresented: $isShowingDeleteAccountAlert,
                   actions: {
                Button("Cancel", role: .cancel) {
                    isShowingDeleteAccountAlert = false
                }
                
                Button("Delete", role: .destructive) {
                    deleteUserAction()
                }
            }, message: {
                Text("If you delete it, all your topics and questions will be deleted as well.")
            })
        }
    }

    private func createUserAction() {
        Task {
            do {
                contentState = .loading
                try await userManager.createUserAndSubscribe(username: username, displayName: displayName)
                presentationMode.wrappedValue.dismiss()
            } catch {
                contentState = .didFail(error.localizedDescription)
            }
        }
    }

    private func updateUserAction() {
        Task {
            do {
                contentState = .loading
                try await userManager.updateUser(displayName: displayName)
                presentationMode.wrappedValue.dismiss()
            } catch {
                contentState = .didFail(error.localizedDescription)
            }
        }
    }

    private func signOutAction() {
        Task {
            do {
                try await userManager.signOut()
                topicsManager.reset()
            } catch {
                contentState = .didFail(error.localizedDescription)
            }
        }
    }

    private func deleteUserAction() {
        Task {
            do {
                contentState = .loading
                try await userManager.deleteUser()
                topicsManager.reset()
                contentState = .idle
            } catch {
                contentState = .didFail(error.localizedDescription)
            }
        }
    }
}

struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        UserProfileView().environmentObject(UserManager())
    }
}
