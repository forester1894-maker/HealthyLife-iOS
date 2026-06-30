# Healthy Life — iOS (mac)

Порт Android-приложения **Healthy Life** для iPhone.  
Проект собирается **только на Mac** с установленным **Xcode 15+**.

## Путь к проекту

```
~/Desktop/Healthy Life mac/HealthyLife.xcodeproj
```

## Что уже есть

- Активация лицензии (тот же сервер, что и Android)
- Согласие с дисклеймером
- Опрос (5 шагов): заболевание, параметры, сопутствующие, калории, ГВ/менопауза/аллергены
- Выбор любимых продуктов (база `foods.json` ~20 000 продуктов)
- 4 вкладки: **Сегодня**, **План**, **Дневник**, **Ещё**
- Логика калорий, ГВ, менопаузы (как в Android)

## Сборка без Mac — GitHub Actions

Проект настроен для автосборки в облаке GitHub (бесплатно для публичных репозиториев).

### Шаг 1 — загрузить на GitHub

1. Войдите на [github.com](https://github.com/login).
2. Создайте репозиторий **HealthyLife-iOS** (Public или Private).
3. Загрузите содержимое папки `Healthy Life mac` (или выполните `git push`).

### Шаг 2 — запустить сборку

После push в ветку `main` автоматически запустится workflow **iOS Build**.

- Откройте вкладку **Actions** в репозитории.
- Дождитесь зелёной галочки (~5–10 мин).
- Скачайте артефакт **HealthyLife-iOS-simulator** (zip с `.app` для симулятора).

### Шаг 3 — установка на iPhone (опционально)

Сборка для симулятора **не ставится на реальный iPhone**. Для `.ipa` нужны секреты Apple в GitHub → Settings → Secrets:

| Секрет | Описание |
|--------|----------|
| `APPLE_CERTIFICATE_BASE64` | Сертификат `.p12` в base64 |
| `APPLE_CERTIFICATE_PASSWORD` | Пароль от `.p12` |
| `APPLE_PROVISIONING_PROFILE_BASE64` | Профиль `.mobileprovision` в base64 |
| `APPLE_TEAM_ID` | Team ID из Apple Developer |
| `KEYCHAIN_PASSWORD` | Любой пароль для временного keychain |

Затем: **Actions → iOS Build → Run workflow** (ручной запуск job `build-ipa`).

### Лимиты GitHub Actions

- Публичный репо: ~2000 мин/мес бесплатно.
- Один прогон iOS ≈ 5–10 мин на `macos-14`.

---

## Сборка на Mac

1. Скопируйте папку `Healthy Life mac` на Mac (или откройте с флешки/облака).
2. Откройте `HealthyLife.xcodeproj` в Xcode.
3. **Signing & Capabilities** → выберите свой Apple ID / Team.
4. Подключите iPhone или выберите симулятор.
5. **Product → Run** (⌘R).

## Настройки API

В `HealthyLife/Info.plist`:

| Ключ | Описание |
|------|----------|
| `LICENSE_BASE_URL` | Сервер лицензий (`http://213.176.94.59:8080`) |
| `LICENSE_APP_KEY` | Ключ приложения |
| `YANDEX_API_KEY` | Для AI-советника (когда будет добавлен) |
| `YANDEX_FOLDER_ID` | Folder ID Yandex Cloud |

Коды доступа выдаёт Telegram-бот: [@HealthyLifePlan_bot](https://t.me/HealthyLifePlan_bot)

## Bundle ID

`com.nutriheal.app.ios` — отдельный от Android (`com.nutriheal.app`).

## Что ещё можно доработать (для полного 1:1)

- AI-чат с Yandex GPT
- Полный движок лечебного питания (30 вариантов блюд, compliance)
- Дневник питания с записью приёмов пищи
- Push-напоминания
- Иконка приложения (сейчас placeholder)
- Публикация в App Store (нужен Apple Developer Program, $99/год)

## Структура

```
Healthy Life mac/
├── HealthyLife.xcodeproj
├── README.md
└── HealthyLife/
    ├── App/          — точка входа, навигация, состояние
    ├── Models/       — UserProfile, enums
    ├── Domain/       — NutritionCalculator, WeeklyPlanGenerator
    ├── Data/         — лицензия, профиль, база продуктов
    ├── UI/           — экраны SwiftUI
    ├── Theme/        — цвета (#2E7D32)
    ├── Resources/    — foods.json
    └── Info.plist
```

## Важно

- С Windows собрать iOS-приложение **нельзя** — нужен Mac.
- HTTP к серверу лицензий разрешён через `NSAppTransportSecurity` в Info.plist (для продакшена лучше HTTPS).
