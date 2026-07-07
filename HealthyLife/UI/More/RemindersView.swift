import SwiftUI

struct RemindersView: View {
    @EnvironmentObject private var appState: AppState
    @State private var settings = ReminderSettings()

    var body: some View {
        Form {
            Section("Вес") {
                Toggle("Напоминание о взвешивании", isOn: $settings.weightEnabled)
                Stepper("Время: \(settings.weightHour):\(String(format: "%02d", settings.weightMinute))",
                        value: $settings.weightHour, in: 6...11)
            }
            Section("Приёмы пищи") {
                Toggle("Напоминания о еде", isOn: $settings.mealEnabled)
                Stepper("Завтрак: \(settings.breakfastHour):00", value: $settings.breakfastHour, in: 6...10)
                Stepper("Обед: \(settings.lunchHour):00", value: $settings.lunchHour, in: 11...15)
                Stepper("Ужин: \(settings.dinnerHour):00", value: $settings.dinnerHour, in: 17...21)
            }
            Section("Вода") {
                Toggle("Напоминания о воде", isOn: $settings.waterEnabled)
                Stepper("Каждые \(settings.waterIntervalHours) ч", value: $settings.waterIntervalHours, in: 1...4)
            }
            Section {
                Text("Локальные уведомления будут добавлены в следующем обновлении. Настройки сохраняются на устройстве.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Напоминания")
        .onAppear { settings = appState.reminderSettings }
        .onChange(of: settings) { newValue in
            appState.saveReminders(newValue)
        }
    }
}
