import SwiftUI

struct ActivationView: View {
    @EnvironmentObject private var appState: AppState
    @State private var code = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Image(systemName: "leaf.circle.fill")
                    .font(.system(size: 72))
                    .foregroundStyle(AppTheme.primary)

                Text("Healthy Life")
                    .font(.largeTitle.bold())
                Text("Лечебное питание")
                    .foregroundStyle(.secondary)

                if appState.autoTrialInProgress {
                    ProgressView("Подключаем пробный доступ на \(AppConfig.autoTrialDays) дня…")
                        .padding()
                } else if appState.trialExpiredNotice {
                    trialExpiredCard
                } else if AppConfig.autoTrialEnabled {
                    Text("Пробный доступ на \(AppConfig.autoTrialDays) дня активируется автоматически при первом запуске.")
                        .multilineTextAlignment(.center)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                } else {
                    Text("Введите код доступа из Telegram-бота @HealthyLifePlan_bot")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                }

                if !AppConfig.autoTrialEnabled || appState.trialExpiredNotice {
                    TextField("NH-XXXX-XXXX", text: $code)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()
                        .padding()
                        .background(AppTheme.container)
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                    if let errorMessage {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                            .font(.footnote)
                    }

                    Button(isLoading ? "Проверка…" : "Активировать") {
                        Task { await activate() }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(code.trimmingCharacters(in: .whitespaces).isEmpty || isLoading)
                }

                Link("Получить код в Telegram", destination: URL(string: "https://t.me/HealthyLifePlan_bot")!)
                    .font(.subheadline)
            }
            .padding(24)
        }
        .background(AppTheme.background)
    }

    private var trialExpiredCard: some View {
        VStack(spacing: 12) {
            Text("Пробный период завершён")
                .font(.headline)
                .foregroundStyle(AppTheme.warning)
            Text("Получите код в Telegram @HealthyLifePlan_bot или введите купленный код ниже.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .cardStyle()
    }

    private func activate() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            try await appState.licenseService.activate(code: code)
            await appState.onActivated()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
