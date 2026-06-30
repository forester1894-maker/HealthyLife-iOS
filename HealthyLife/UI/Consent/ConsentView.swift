import SwiftUI

struct ConsentView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Важно")
                    .font(.title.bold())

                Text("Приложение не заменяет консультацию врача. Рекомендации носят информационный характер и основаны на общих принципах лечебного питания.")
                    .foregroundStyle(.secondary)

                VStack(alignment: .leading, spacing: 8) {
                    Label("Не является медицинским изделием", systemImage: "exclamationmark.triangle")
                    Label("При обострении обратитесь к врачу", systemImage: "heart.text.square")
                    Label("Данные хранятся только на устройстве", systemImage: "lock.shield")
                }
                .font(.subheadline)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.disclaimerBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                Button("Принимаю и продолжаю") {
                    appState.acceptConsent()
                }
                .buttonStyle(PrimaryButtonStyle())
            }
            .padding(24)
        }
        .background(AppTheme.background)
    }
}
