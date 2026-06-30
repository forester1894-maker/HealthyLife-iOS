# Загрузка на GitHub (Windows)

## 1. Войдите на GitHub
Откройте https://github.com/login и войдите в аккаунт.

## 2. Создайте репозиторий
1. https://github.com/new
2. Repository name: `HealthyLife-iOS`
3. Public (бесплатные Actions) или Private
4. **Не** добавляйте README / .gitignore — репозиторий должен быть пустым
5. Create repository

## 3. Загрузите код (PowerShell)

Замените `ВАШ_ЛОГИН` на свой GitHub-логин и выполните:

```powershell
$env:Path = "C:\Program Files\Git\bin;C:\Program Files\Git\cmd;" + $env:Path
cd "C:\Users\Asus\Desktop\Healthy Life mac"
git remote add origin https://github.com/ВАШ_ЛОГИН/HealthyLife-iOS.git
git push -u origin main
```

При запросе логина:
- **Username** — ваш логин GitHub
- **Password** — Personal Access Token (не пароль от аккаунта)

### Как получить токен
1. GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Generate new token → scope `repo`
3. Скопируйте токен и вставьте как пароль при `git push`

## 4. Проверьте сборку
1. Откройте репозиторий → вкладка **Actions**
2. Должен запуститься workflow **iOS Build**
3. Через ~5–10 мин скачайте артефакт **HealthyLife-iOS-simulator**

## Важно
- Сборка для **симулятора** — на реальный iPhone не ставится
- Для `.ipa` на iPhone нужен Apple Developer ($99/год) и секреты в GitHub (см. README.md)
