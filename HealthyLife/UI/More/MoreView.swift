import SwiftUI

struct MoreView: View {
    @EnvironmentObject private var appState: AppState
    @State private var showResetConfirm = false

    var body: some View {
        NavigationStack {
            List {
                Section("Профиль") {
                    if let profile = appState.profile, let disease = DiseaseCatalog.byId(profile.diseaseId) {
                        LabeledContent("Заболевание", value: disease.nameRu)
                        LabeledContent("Возраст", value: "\(profile.age)")
                        LabeledContent("Пол", value: profile.gender.labelRu)
                    }
                    NavigationLink("Пройти опрос заново") {
                        SurveyView()
                            .onDisappear {
                                if let p = appState.profile {
                                    appState.saveProfile(p)
                                }
                            }
                    }
                }

                Section("Поддержка") {
                    Link("Telegram-бот", destination: URL(string: "https://t.me/HealthyLifePlan_bot")!)
                    Link("Скачать APK (Android)", destination: URL(string: "https://disk.yandex.ru/d/pMy7h-yl9fRQWg")!)
                }

                Section {
                    Button("Сбросить профиль", role: .destructive) {
                        showResetConfirm = true
                    }
                    Button("Выйти из аккаунта (лицензия)", role: .destructive) {
                        Task {
                            await appState.licenseService.deactivate()
                            await appState.onActivated()
                        }
                    }
                }
            }
            .navigationTitle("Ещё")
            .alert("Сбросить профиль?", isPresented: $showResetConfirm) {
                Button("Отмена", role: .cancel) {}
                Button("Сбросить", role: .destructive) {
                    appState.clearProfile()
                }
            } message: {
                Text("Все данные опроса будут удалены с устройства.")
            }
        }
    }
}
