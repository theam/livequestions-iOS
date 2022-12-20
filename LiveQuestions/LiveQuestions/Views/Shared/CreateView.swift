import SwiftUI

struct CreateView: View {
    @Environment(\.dismiss) var dismiss

    @State var name = String.empty
    let mode: Mode
    let onSave: (String, Bool, Int) async -> Void

    @State private var isToogleOn = false
    @State private var pickedValue: Int = 30
    @FocusState private var isFocused

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)

                VStack {
                    ZStack(alignment: .bottomTrailing) {
                        TextField(mode.textPlaceholder, text: $name, axis: .vertical)
                            .lineLimit(3 ... 6)
                            .focused($isFocused)
                            .onAppear { isFocused = true }
                            .padding()
                            .padding(.bottom)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(8)
                            .onReceive(name.publisher.collect()) {
                                name = String($0.prefix(mode.charactersLimit))
                            }

                        Text((mode.charactersLimit - name.count).description)
                            .fontWeight(.bold)
                            .padding(7)
                    }
                    .padding(.vertical)

                    if let toggleText = mode.toggleText {
                        Toggle(toggleText, isOn: $isToogleOn)
                            .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                    }

                    if let pickerValues = mode.pickerValues, !mode.isEditing {
                        HStack(alignment: .firstTextBaseline) {
                            Text("Close topic in")

                            Picker("", selection: $pickedValue) {
                                ForEach(pickerValues, id: \.self) {
                                    Text($0.description)
                                }
                            }.offset(y: 1)

                            Text((pickedValue == 1 ? "day" : "days") + " 🔒")

                            Spacer()
                        }
                    }

                    Spacer()

                    Button(action: {
                        Task { await onSave(name, isToogleOn, pickedValue) }
                        dismiss()
                    }) {
                        Text(mode.buttonTitle)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(RoundedButtonStyle())
                    .padding(.bottom, 50)
                }
                .padding(.horizontal)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark.circle.fill")
                        }
                        .tint(.gray)
                    }
                }
            }
            .navigationTitle(mode.title)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct CreateView_Previews: PreviewProvider {
    static var previews: some View {
        CreateView(mode: .question(isEditing: false)) { _, _, _ in }
        CreateView(mode: .topic(isEditing: false)) { _, _, _ in }
    }
}

extension CreateView {
    enum Mode {
        case topic(isEditing: Bool = false)
        case question(isEditing: Bool = false)

        var isEditing: Bool {
            switch self {
            case let .topic(isEditing),
                 let .question(isEditing):
                return isEditing
            }
        }

        var title: String {
            switch self {
            case let .topic(isEditing: isEditing):
                return isEditing ? "Edit Topic" : "New Topic"
            case let .question(isEditing):
                return isEditing ? "Edit Question" : "New Question"
            }
        }

        var textPlaceholder: String {
            switch self {
            case .topic: return "Your topic title here..."
            case .question: return "Your question here..."
            }
        }

        var toggleText: String? {
            switch self {
            case .topic: return nil
            case let .question(isEditing): return isEditing ? nil : "Ask anonymously"
            }
        }

        var pickerValues: [Int]? {
            switch self {
            case .topic: return Array(1 ... 30)
            case .question: return nil
            }
        }

        var buttonTitle: String {
            switch self {
            case let .topic(isEditing):
                return isEditing ? "Edit topic" : "Add topic"
            case let .question(isEditing):
                return isEditing ? "Edit question" : "Add question"
            }
        }

        var charactersLimit: Int {
            switch self {
            case .topic: return 120
            case .question: return 150
            }
        }
    }
}

private extension Binding where Value == String {
    func max(_ limit: Int) -> Self {
        if wrappedValue.count > limit {
            DispatchQueue.main.async {
                wrappedValue = String(wrappedValue.prefix(limit))
            }
        }
        return self
    }
}
