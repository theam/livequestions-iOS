import SwiftUI

struct QuestionsView: View {
    enum AlertType {
        case block(Question)
        case delete(Question)
        case none
    }
    
    @EnvironmentObject private var viewModel: TopicVM

    @State private var showAlert = false
    @State private var alertType: AlertType = .none
    @State private var editQuestion: Question?

    private var questionsCountDescription: String {
        viewModel.topic.isMine ? "Wow, \(viewModel.questions.count) questions were asked 🤩." : "\(viewModel.questions.count) questions were asked."
    }

    var body: some View {
        List {
            Section {
                ForEach(viewModel.questions) { question in
                    QuestionRow(question: question,
                                hasLiked: viewModel.hasLiked(question: question),
                                background: viewModel.backgroundColor(for: question.id),
                                isTopicClosed: viewModel.topic.isClosed,
                                onLikeSelection: viewModel.likeOrUnlike(question:))
                        .listRowBackground(Color.clear)
                        .swipeActions(edge: .trailing) {
                            if question.isMine {
                                editButton(for: question)
                            }
                            if viewModel.canDelete(question: question) {
                                deleteButton(for: question)
                            }
                        }
                        .swipeActions(edge: .leading) {
                            if question.isMine {
                                statusButton(for: question)
                            } else {
                                blockButton(for: question)
                            }
                        }
                        .contextMenu {
                            if question.isMine {
                                editButton(for: question)
                                statusButton(for: question)
                            } else {
                                blockButton(for: question)
                            }
                            
                            if viewModel.canDelete(question: question) {
                                deleteButton(for: question)
                            }
                        }
                        .listRowSeparator(.hidden)
                }
            } header: {
                Group {
                    if viewModel.topic.isClosed {
                        Text(viewModel.topic.closedDescription)
                    } else if viewModel.questions.count > 1 {
                        Text(questionsCountDescription)
                    } else {
                        EmptyView()
                    }
                }
                .textCase(nil)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white.opacity(0.2))
                .cornerRadius(8)
                .padding(.bottom)
                .hidden(viewModel.questions.count <= 1 && !viewModel.topic.isClosed)
            }
        }
        .refreshable { await viewModel.loadQuestions() }
        .listStyle(.grouped)
        .alert(isPresented: $showAlert, content: presentAlert)
        .sheet(item: $editQuestion) { question in
            CreateView(
                name: question.text,
                mode: .question(isEditing: true),
                onSave: { text, _, _ in await viewModel.changeQuestionText(question, text: text) }
            )
        }
    }
    
    private func presentAlert() -> Alert {
        switch alertType {
        case let .delete(question):
            return Alert(title: Text("Are you sure you want to delete this question?"),
                         primaryButton: .destructive(Text("Delete"), action: { Task { await viewModel.deleteQuestion(question) }}),
                         secondaryButton: .cancel())
        case let .block(question):
            return Alert(title: Text("Are you sure you want to block this question?"),
                         primaryButton: .destructive(Text("Block"), action: { Task { await viewModel.blockQuestion(question) }}),
                         secondaryButton: .cancel())
        case .none:
            return Alert(title: Text(""))
        }
    }
    
    private func blockButton(for question: Question) -> some View {
        Button(action: {
            alertType = .block(question)
            showAlert = true
        }) {
            Label("Block and report question", systemImage: "hand.raised")
        }
        .tint(.blue)
    }

    private func editButton(for question: Question) -> some View {
        Button(action: { editQuestion = question }) {
            Label("Edit", systemImage: "applepencil")
        }
        .disabled(viewModel.topic.isClosed)
    }

    private func statusButton(for question: Question) -> some View {
        Button(action: { Task { await viewModel.answerOrUnanswer(question: question) } }) {
            if question.status == .unanswered {
                Label("Mark as answered", systemImage: "checkmark.bubble")
            } else {
                Label("Mark as unanswered", systemImage: "bubble.left")
            }
        }
        .disabled(viewModel.topic.isClosed)
        .tint(question.status == .unanswered ? .green : .gray)
    }

    private func deleteButton(for question: Question) -> some View {
        Button(action: {
            alertType = .delete(question)
            showAlert = true
        }) {
            Label("Delete", systemImage: "trash")
        }
        .disabled(viewModel.topic.isClosed)
        .tint(.red)
    }
}
