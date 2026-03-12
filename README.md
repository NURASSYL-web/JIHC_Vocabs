# Lexora Solutions (Flutter)

Мобильное приложение для изучения слов по учебникам **Solutions 3rd Edition**.
Интерфейс на русском языке, контент слов: **EN + RU + KZ + A1 definition + example**.

## Реализовано

- Onboarding + вход + пошаговая регистрация (3 шага)
- Выбор группы и книги (Elementary / Pre-Intermediate / Intermediate)
- Bottom navigation: Home, Units, Discovery, Profile
- Экран Unit со словами и карточками
- Flashcards режим (знаю / сложно / позже)
- Мини-тесты (MCQ, matching, definition, fill in the blank, listening demo)
- Профиль с прогрессом, XP, уровнем, streak, achievements
- Discovery: слово дня, random words, challenge, советы
- Разделы weak words / favorite words / leaderboard
- Teacher/Admin dashboard (demo UX)
- Light/Dark mode

## Структура проекта

- `lib/main.dart` — точка входа
- `lib/src/app.dart` — MaterialApp + app scope
- `lib/src/models/models.dart` — модели домена
- `lib/src/data/demo_content.dart` — demo данные по unit
- `lib/src/state/app_controller.dart` — состояние и бизнес-логика
- `lib/src/ui/screens.dart` — все экраны приложения
- `lib/src/ui/theme.dart` — светлая/тёмная темы

## Запуск

```bash
flutter pub get
flutter run
```

## Тест

```bash
flutter test
```

## Firebase интеграция (следующий шаг)

Для продакшена замените demo state на Firebase:
- Auth: Firebase Authentication
- Data: Cloud Firestore
- Media/audio: Firebase Storage
- Push: Firebase Cloud Messaging
- Offline cache: Hive/Isar

Текущий код уже разделен так, чтобы эту миграцию сделать без полного переписывания UI.
