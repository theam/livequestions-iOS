import SwiftUI

struct TopicsListView: View {
    enum AlertType {
        case block(User)
        case delete(Topic)
        case close(Topic)
        case none
    }
    
    @EnvironmentObject private var viewModel: TopicsVM

    @State private var showAlert = false
    @State private var alertType: AlertType = .none
    @State private var editTopic: Topic?
    @State private var showTopicQRCode: Topic?

    var body: some View {
        List(viewModel.topics) { topic in
            NavigationLink(value: topic) {
                TopicRow(showHost: !topic.isMine, topic: topic, questionsCountColor: BackgroundColorProvider.color(itemId: topic.id))
            }
            .listRowBackground(Color.clear)
            .contextMenu {
                qrCodeButton(for: topic)
                shareButton(for: topic)
                if topic.isMine {
                    editButton(for: topic).disabled(topic.isClosed)
                    if topic.isOpen {
                        statusButton(for: topic)
                    }
                    deleteButton(for: topic)
                } else {
                    blockButton(for: topic.host)
                }
            }
            .buttonStyle(PlainButtonStyle())
            .swipeActions(edge: .trailing) {
                if topic.isMine {
                    editButton(for: topic).disabled(topic.isClosed)
                    deleteButton(for: topic)
                }
            }
            .swipeActions(edge: .leading) {
                if topic.isOpen {
                    qrCodeButton(for: topic)
                }
                if topic.isMine, topic.isOpen {
                    statusButton(for: topic)
                }
                if !topic.isMine {
                    blockButton(for: topic.host)
                }
            }
            .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
        .refreshable { try? await viewModel.refreshTopics() }
        .sheet(item: $editTopic) { topic in
            CreateView(
                name: topic.title,
                mode: .topic(isEditing: true),
                onSave: { title, _, _ in await viewModel.changeTopicTitle(topic, title: title) }
            )
        }
        .sheet(item: $showTopicQRCode) { topic in
            QRCodeView(topic: topic)
        }
        .alert(isPresented: $showAlert, content: presentAlert)
    }
    
    private func presentAlert() -> Alert {
        switch alertType {
        case let .close(topic):
            return Alert(title: Text("Are you sure you want to close this topic?"),
                         message: Text("You can not reopen a topic after it's closed."),
                         primaryButton: .destructive(Text("Close"), action: { Task { await viewModel.updateTopicStatus(topic, status: .closed) }}),
                         secondaryButton: .cancel())
        case let .delete(topic):
            return Alert(title: Text("Are you sure you want to delete topic?"),
                         primaryButton: .destructive(Text("Delete"), action: { Task { await viewModel.deleteTopic(topic) }}),
                         secondaryButton: .cancel())
        case let .block(user):
            return Alert(title: Text("Are you sure you want to block this user?"),
                         primaryButton: .destructive(Text("Block"), action: { Task { await viewModel.blockUser(user) }}),
                         secondaryButton: .cancel())
        case .none:
            return Alert(title: Text(""))
        }
    }
    
    private func blockButton(for user: User) -> some View {
        Button(action: {
            alertType = .block(user)
            showAlert = true
        }) {
            Label("Block and report user", systemImage: "hand.raised")
        }
        .tint(.blue)
    }
    
    private func qrCodeButton(for topic: Topic) -> some View {
        Button(action: { showTopicQRCode = topic }) {
            Label("QR Code", systemImage: "qrcode")
        }
        .tint(.green)
    }

    private func shareButton(for topic: Topic) -> some View {
        ShareLink(item: Deeplink.topic(topic.id).url) {
            Label("Share", systemImage: "square.and.arrow.up")
        }
    }

    private func editButton(for topic: Topic) -> some View {
        Button(action: { editTopic = topic }) {
            Label("Edit", systemImage: "applepencil")
        }
    }

    private func statusButton(for topic: Topic) -> some View {
        Button(action: {
            alertType = .close(topic)
            showAlert = true
        }) {
            Label("Close", systemImage: "lock")
        }
        .tint(.blue)
    }

    private func deleteButton(for topic: Topic) -> some View {
        Button(action: {
            alertType = .delete(topic)
            showAlert = true
        }) {
            Label("Delete", systemImage: "trash")
        }
        .tint(.red)
    }
}
