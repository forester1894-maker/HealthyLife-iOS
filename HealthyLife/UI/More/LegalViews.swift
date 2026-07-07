import SwiftUI

struct PrivacyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Политика конфиденциальности")
                    .font(.title2.bold())

                Group {
                    Text("1. Какие данные хранятся")
                    Text("Профиль опроса, план питания, записи дневника и веса хранятся локально на вашем устройстве.")
                    Text("2. Передача на сервер")
                    Text("На сервер лицензий передаётся только идентификатор устройства и токен сессии для проверки доступа. Данные о здоровье на сервер не отправляются.")
                    Text("3. ИИ-советник")
                    Text("При использовании ИИ-советника текст вопроса и краткий контекст профиля отправляются в Yandex Cloud (если API настроен).")
                    Text("4. Удаление данных")
                    Text("Вы можете удалить профиль в разделе «Ещё» — данные будут стёрты с устройства.")
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
            .padding()
        }
        .background(AppTheme.background)
        .navigationTitle("Конфиденциальность")
    }
}

struct DisclaimerView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                MedicalDisclaimerBanner()
                Text("Отказ от ответственности")
                    .font(.title2.bold())
                Text("""
                Приложение Healthy Life предоставляет информационные рекомендации по питанию и образу жизни при различных заболеваниях.

                Оно не является медицинским изделием, не ставит диагноз и не назначает лечение.

                Перед изменением рациона, началом диеты или физической нагрузки обязательно проконсультируйтесь с врачом или дипломированным диетологом.

                Разработчик не несёт ответственности за решения, принятые пользователем на основе информации из приложения.
                """)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
            .padding()
        }
        .background(AppTheme.background)
        .navigationTitle("Дисклеймер")
    }
}
