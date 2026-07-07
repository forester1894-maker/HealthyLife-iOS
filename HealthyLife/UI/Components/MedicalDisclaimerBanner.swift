import SwiftUI

struct MedicalDisclaimerBanner: View {
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "cross.case.fill")
                .foregroundStyle(AppTheme.warning)
            Text("Это информационное приложение. Не заменяет консультацию врача или диетолога. Лечение — только по назначению специалиста.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .background(AppTheme.warning.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
