import SwiftUI


struct TopicsView: View {
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var topicsManager: TopicsManager

    @StateObject var viewModel: TopicsVM
    @State private var isShowingCreateTopic = false

    init(topicsManager: TopicsManager, userManager: UserManager) {
        _viewModel = StateObject(wrappedValue: .init(manager: topicsManager, userManager: userManager))
    }
    
    var body: some View {
        contentView
            .navigationDestination(for: Topic.self) { topic in
                TopicView(topic: topic, topicsManager: topicsManager, userManager: userManager)
            }
            .navigationTitle(userManager.isUserAuthenticated ? viewModel.filter.title : .empty)
            .toolbar {
                if userManager.isUserAuthenticated {
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        Button(action: { isShowingCreateTopic = true }) {
                            Image(systemName: "plus.bubble")
                        }
                        filtersMenu
                    }
                }
            }
            .sheet(isPresented: $isShowingCreateTopic) {
                CreateView(mode: .topic(), onSave: { name, _, expirationDays in
                    await viewModel.createTopic(title: name, expirationDays: expirationDays)
                })
            }
    }

    private var contentView: some View {
        ContainerView(state: $viewModel.state) {
            ZStack {
                if userManager.isUserAuthenticated {
                    if viewModel.topics.isEmpty, viewModel.state != .loading {
                        if !NetworkMonitor.isConnected {
                            NoResultsView(title: "Check your Internet connection 💔", buttonTitle: "Refresh") {
                                Task { await viewModel.loadTopics() }
                            }
                        } else if viewModel.filter == .others {
                            NoResultsView(title: "No joined topics yet! 💭",
                                          subtitle: "Another host can share their topic link. When you tap it, Live Questions will open, and you'll be able to join the topic and participate if you like :)") {}
                        } else {
                            NoResultsView(title: "No topics yet! 💭",
                                          buttonTitle: "Create your first topic") {
                                isShowingCreateTopic = true
                            }
                        }
                    } else {
                        TopicsListView()
                            .environmentObject(viewModel)
                    }
                } else {
                    SignInView { Task { await viewModel.signIn() } }
                }
            }
        }
    }

    private var filtersMenu: some View {
        Menu {
            ForEach(TopicsFilter.allCases) { filter in
                Button(action: { viewModel.filterTopics(by: filter) }) {
                    if viewModel.filter == filter {
                        Label(filter.title, systemImage: "checkmark")
                    } else {
                        Text(filter.title)
                    }
                }
            }
        } label: {
            Image(systemName: "line.3.horizontal.decrease")
        }
    }
}

struct TopicsView_Previews: PreviewProvider {
    static var previews: some View {
        let userManager = UserManager()
        let topicsManager = TopicsManager(userManager: userManager)
        TopicsView(topicsManager: topicsManager, userManager: userManager)
    }
}
