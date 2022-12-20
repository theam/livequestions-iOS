import SwiftUI

struct QuestionRow: View {
    let question: Question
    let hasLiked: Bool
    let background: Color
    let isTopicClosed: Bool
    let onLikeSelection: (Question) async -> Void
    var isAnswered: Bool { question.status == .answered }

    var body: some View {
        ZStack {
            VStack(spacing: 4) {
                headerView
                contentView.disabled(isTopicClosed)
            }
            .opacity(isAnswered ? 0.6 : 1)

            if isAnswered {
                VStack(alignment: .trailing) {
                    Spacer()
                    HStack(alignment: .bottom) {
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .background(Color.black.clipShape(Circle()))
                            .font(.title)
                            .offset(y: 6)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }

    private var headerView: some View {
        HStack {
            if !question.isAnonymous {
                Text(question.creator.displayName)
                Text("@" + question.creator.username)
            }

            Spacer()
            Text(question.createdAt.relativeFormatted)
        }
        .font(.caption)
        .foregroundColor(.gray)
    }

    private var contentView: some View {
        VStack(alignment: .leading) {
            Text(question.text)
                .foregroundColor(.black)
                .multilineTextAlignment(.leading)
                .font(.largeTitle)
                .fontWeight(.medium)
                .minimumScaleFactor(0.2)
                .lineLimit(5)
                .padding()

            HStack {
                Spacer()
                likeButton
            }
        }
        .frame(
            maxWidth: .infinity,
            minHeight: 80,
            maxHeight: 160
        )
        .background(background)
        .cornerRadius(10)
    }

    @ViewBuilder
    private var likeButton: some View {
        Button(action: { Task { await onLikeSelection(question) } }) {
            HStack {
                if hasLiked {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                } else {
                    Image(systemName: "heart")
                        .foregroundColor(.black)
                }

                Text(question.likes.count.description)
                    .foregroundColor(.black)
            }
            .font(.footnote)
            .fontWeight(.semibold)
            .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
            .background(Color.black.opacity(0.1))
            .cornerRadius(12)
            .padding([.trailing, .bottom], 10)
        }
    }
}

struct QuestionRow_Previews: PreviewProvider {
    static var previews: some View {
        List {
            QuestionRow(question: TestAnsweredQuestion, hasLiked: true, background: AppColor.blue.value, isTopicClosed: false, onLikeSelection: { _ in
            })
            QuestionRow(question: TestUnansweredQuestion, hasLiked: true, background: AppColor.blue.value, isTopicClosed: false, onLikeSelection: { _ in
            })
        }.listStyle(.plain)
    }
}
