import SwiftUI

struct AiAdvisorView: View {
    @EnvironmentObject private var appState: AppState
    @State private var input = ""
    @State private var isSending = false

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        MedicalDisclaimerBanner()
                        if appState.aiMessages.isEmpty {
                            Text("Задайте вопрос о питании, продуктах или вашем плане. Отвечает Yandex AI (DeepSeek V4 Flash).")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .padding(.bottom, 8)
                        }
                        ForEach(appState.aiMessages) { msg in
                            bubble(msg)
                                .id(msg.id)
                        }
                    }
                    .padding()
                }
                .onChange(of: appState.aiMessages.count) { _ in
                    if let last = appState.aiMessages.last {
                        withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                    }
                }
            }

            HStack {
                TextField("Ваш вопрос…", text: $input, axis: .vertical)
                    .lineLimit(1...4)
                    .padding(10)
                    .background(AppTheme.container)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                Button {
                    Task { await send() }
                } label: {
                    Image(systemName: isSending ? "hourglass" : "paperplane.fill")
                }
                .disabled(input.trimmingCharacters(in: .whitespaces).isEmpty || isSending)
            }
            .padding()
            .background(.white)
        }
        .background(AppTheme.background)
        .navigationTitle("ИИ-советник")
    }

    private func bubble(_ msg: ChatMessage) -> some View {
        HStack {
            if msg.role == "user" { Spacer(minLength: 40) }
            VStack(alignment: msg.role == "user" ? .trailing : .leading, spacing: 4) {
                Text(msg.content)
                    .font(.subheadline)
                    .padding(12)
                    .background(msg.role == "user" ? AppTheme.primary.opacity(0.15) : Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                if let badge = msg.modelBadge {
                    Text(badge).font(.caption2).foregroundStyle(.secondary)
                }
            }
            if msg.role != "user" { Spacer(minLength: 40) }
        }
    }

    private func send() async {
        let text = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        input = ""
        isSending = true
        defer { isSending = false }
        await appState.sendAiMessage(text)
    }
}
