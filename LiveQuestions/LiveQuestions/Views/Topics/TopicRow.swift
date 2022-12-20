import SwiftUI

struct TopicRow: View {
    let showHost: Bool
    let topic: Topic
    let questionsCountColor: Color

    var body: some View {
        ZStack {
            VStack(spacing: 4) {
                headerView
                contentView
            }
            .opacity(topic.isClosed ? 0.6 : 1)

            if topic.isClosed {
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
    }

    private var headerView: some View {
        HStack {
            if showHost {
                Text(topic.host.displayName)
                Text("@" + topic.host.username)
            }

            Spacer()
            Text(topic.createdAt.relativeFormatted)
        }
        .font(.caption)
        .foregroundColor(.gray)
    }

    var questionsCount: String {
        topic.questionsCount == 1 ? "1 Question" : "\(topic.questionsCount) Questions"
    }

    private var contentView: some View {
        VStack(alignment: .leading) {
            Text(topic.title)
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
                .font(.title2)
                .fontWeight(.medium)
                .minimumScaleFactor(0.2)
                .lineLimit(5)
                .padding(.top)
                .padding(.horizontal)

            HStack {
                Text(questionsCount).foregroundColor(questionsCountColor)

                Spacer()

                ShareLink(item: Deeplink.topic(topic.id).url) {
                    Image(systemName: "square.and.arrow.up.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .imageScale(.large)
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.white, .blue)
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .background(Color.white.opacity(0.1))
        .cornerRadius(10)
    }
}

struct TopicRow_Previews: PreviewProvider {
    static var previews: some View {
        List {
            TopicRow(showHost: true, topic: TestOpenTopic, questionsCountColor: AppColor.blue.value)
            TopicRow(showHost: false, topic: TestClosedTopic, questionsCountColor: AppColor.green.value)
        }.listStyle(.plain)
    }
}
