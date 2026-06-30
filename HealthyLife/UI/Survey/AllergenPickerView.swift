import SwiftUI

struct AllergenPickerView: View {
    @Binding var selected: Set<String>

    private let allergens: [(String, String)] = [
        ("gluten", "Глютен"), ("lactose", "Лактоза"), ("nuts", "Орехи"),
        ("peanuts", "Арахис"), ("eggs", "Яйца"), ("fish", "Рыба"),
        ("shellfish", "Морепродукты"), ("soy", "Соя"), ("celery", "Сельдерей"),
        ("mustard", "Горчица"), ("sesame", "Кунжут"), ("sulfites", "Сульфиты")
    ]

    var body: some View {
        List(allergens, id: \.0) { id, name in
            Button {
                if selected.contains(id) { selected.remove(id) } else { selected.insert(id) }
            } label: {
                HStack {
                    Text(name)
                    Spacer()
                    if selected.contains(id) {
                        Image(systemName: "checkmark").foregroundStyle(AppTheme.primary)
                    }
                }
            }
        }
        .navigationTitle("Аллергены")
    }
}
