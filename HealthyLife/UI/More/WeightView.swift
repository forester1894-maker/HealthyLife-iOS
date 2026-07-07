import SwiftUI

struct WeightView: View {
    @EnvironmentObject private var appState: AppState
    @State private var weightText = ""
    @State private var note = ""

    var body: some View {
        List {
            Section("Новая запись") {
                TextField("Вес, кг", text: $weightText)
                    .keyboardType(.decimalPad)
                TextField("Заметка (необязательно)", text: $note)
                Button("Сохранить") { save() }
                    .disabled(Float(weightText.replacingOccurrences(of: ",", with: ".")) == nil)
            }

            Section("История") {
                if appState.weightEntries.isEmpty {
                    Text("Записей пока нет").foregroundStyle(.secondary)
                } else {
                    ForEach(appState.weightEntries) { entry in
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(String(format: "%.1f", entry.weightKg)) кг")
                                .font(.headline)
                            Text(entry.dateIso).font(.caption).foregroundStyle(.secondary)
                            if let note = entry.note, !note.isEmpty {
                                Text(note).font(.caption)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Вес")
        .onAppear {
            if let w = appState.profile?.weightKg {
                weightText = String(format: "%.1f", w)
            }
        }
    }

    private func save() {
        let normalized = weightText.replacingOccurrences(of: ",", with: ".")
        guard let kg = Float(normalized) else { return }
        appState.addWeight(kg, note: note.isEmpty ? nil : note)
        if var profile = appState.profile {
            profile.weightKg = kg
            appState.saveProfile(profile)
        }
        note = ""
    }
}
