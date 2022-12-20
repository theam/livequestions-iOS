import SwiftUI

struct TopicView: View {
    @StateObject var viewModel: TopicVM
    @State private var showNewQuestion = false
    @State private var showTopicQRCode: Topic?
    
    init(topic: Topic, topicsManager: TopicsManager, userManager: UserManager) {
        _viewModel = .init(wrappedValue: .init(topic: topic, manager: topicsManager, userManager: userManager))
    }
    
    var body: some View {
        contentView
            .navigationTitle(viewModel.topic.title)
            .toolbar {
                if !viewModel.topic.shouldJoinFirst, !viewModel.shouldUnblockUserFirst {
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        qrCodeButton
                        newQuestionButton
                        sortingMenu
                    }
                }
            }
            .sheet(isPresented: $showNewQuestion) {
                CreateView(mode: .question(), onSave: { question, isAnonymous, _ in
                    await viewModel.createQuestion(text: question, isAnonymous: isAnonymous)
                })
            }
            .sheet(item: $showTopicQRCode) { topic in
                QRCodeView(topic: topic)
            }
            .task { await viewModel.loadQuestions() }
            .onAppear { viewModel.startObservers() }
            .onDisappear { viewModel.stopObservers() }
    }
    
    private var sortingMenu: some View {
        Menu(content: {
            ForEach(QuestionsSort.allCases) { sort in
                Button(action: { viewModel.sortQuestions(by: sort) }) {
                    if viewModel.sorting == sort {
                        Label(sort.title, systemImage: "checkmark")
                    } else {
                        Text(sort.title)
                    }
                }
            }
        }) { Image(systemName: "line.3.horizontal.decrease") }
    }
    
    private var newQuestionButton: some View {
        Button(action: { showNewQuestion = true }) {
            Image(systemName: "plus.bubble")
        }
        .disabled(viewModel.topic.isClosed)
    }
    
    private var qrCodeButton: some View {
        Button(action: { showTopicQRCode = viewModel.topic }) {
            Label("QR Code", systemImage: "qrcode")
        }
        .disabled(viewModel.topic.isClosed)
    }

    private var contentView: some View {
        ContainerView(state: $viewModel.state) {
            ZStack {
                if viewModel.questions.isEmpty {
                    if viewModel.state == .loading {
                        EmptyView()
                    } else if viewModel.topic.isClosed {
                        NoResultsView(title: viewModel.topic.closedDescription)
                    } else if !NetworkMonitor.isConnected {
                        NoResultsView(title: "Check your Internet connection 💔", buttonTitle: "Refresh") {
                            Task { await viewModel.loadQuestions() }
                        }
                    } else {
                        NoResultsView(title: "No questions yet! 🫣", buttonTitle: "Create your first question") {
                            showNewQuestion = true
                        }
                    }
                } else {
                    QuestionsView().environmentObject(viewModel)
                }

                if viewModel.topic.shouldJoinFirst {
                    overlayView {
                        Button(action: { Task { await viewModel.joinTopic() } }) {
                            Label("Join Topic", systemImage: "person.crop.circle.badge.plus")
                        }
                    }
                } else if viewModel.shouldUnblockUserFirst {
                    overlayView {
                        Button(action: { Task { await viewModel.unblockHost() } }) {
                            Label("Unblock Host", systemImage: "hand.raised.slash.fill")
                        }
                    }
                }
            }
        }
    }

    private func overlayView<Content: View>(button: () -> Content) -> some View {
        ZStack {
            LinearGradient(colors: [.black.opacity(0.2), .black], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            VStack {
                Spacer()
                button()
                .buttonStyle(RoundedButtonStyle())
                .padding(.bottom, 50)
                .padding(.horizontal)
            }
        }
    }
}

struct TopicView_Previews: PreviewProvider {
    static var previews: some View {
        let userManager = UserManager()
        let topicsManager = TopicsManager(userManager: userManager)
        TopicView(topic: TestOpenTopic, topicsManager: topicsManager, userManager: userManager)
    }
}
