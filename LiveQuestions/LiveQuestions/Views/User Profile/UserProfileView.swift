import SwiftUI
import PhotosUI

struct UserProfileView: View {
    @Environment(\.presentationMode) private var presentationMode

    @StateObject var viewModel: UserProfileVM
    @State private var username = String.empty
    @State private var displayName = String.empty
    @State private var isShowingDeleteAccountAlert = false
    
    private var user: User { viewModel.user }
    private var navigationTitle: String { viewModel.isPickingUsernameNeeded ? "Welcome! 🥳" : "@" + user.username }

    init(topicsManager: TopicsManager, userManager: UserManager) {
        _viewModel = StateObject(wrappedValue: .init(topicsManager: topicsManager, userManager: userManager))
    }
    
    var body: some View {
        NavigationView {
            ContainerView(state: $viewModel.contentState) {
                ZStack {
                    Color.black.edgesIgnoringSafeArea(.all)

                    VStack {
                        EditableCircularProfileImage(viewModel: viewModel)
                            .padding()
                            
                        if viewModel.isPickingUsernameNeeded {
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

                        if viewModel.isPickingUsernameNeeded {
                            Text("You can change your display name whenever you want.")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding(.bottom, 10)
                        }

                        Spacer()

                        Group {
                            if viewModel.isPickingUsernameNeeded {
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
                            if !viewModel.isPickingUsernameNeeded {
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
                .onReceive(viewModel.$isAuthenticated) { isAuthenticated in
                    guard !isAuthenticated else { return }

                    // Ugly fix to give the Auth0 webView some time to be dismissed first:
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                .interactiveDismissDisabled(viewModel.isPickingUsernameNeeded)
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
    
    //MARK: - Actions
    private func createUserAction() {
        Task {
            guard await viewModel.createUser(username: username, displayName: displayName) else { return }
            presentationMode.wrappedValue.dismiss()
        }
    }

    private func updateUserAction() {
        Task {
            guard let success = try? await viewModel.updateName(displayName), success else { return }
            presentationMode.wrappedValue.dismiss()
        }
    }

    private func signOutAction() {
        Task { await viewModel.signOut() }
    }

    private func deleteUserAction() {
        Task { await viewModel.deleteUser() }
    }
}

struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        UserProfileView(topicsManager: TopicsManager(userManager: .shared), userManager: .shared)
    }
}
