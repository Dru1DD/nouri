# Nouri 1.0.3 — план

База: ветка `feat/1.0.2` (не смержена в `main`, там hydration reminders + onboarding).
Ветка релиза: `feat/1.0.3` от `feat/1.0.2`. Название (Nouri/Nuori) не трогаем.

Источники: фидбек с тестинга + `docs/research/new/04-founder-decision-memo.md` (D4, P2 как Today-rings, 4.6).
CI в этом релизе нет: проверки только локально (git hooks, не GitHub Actions).

---

## 0. Подготовка

- [ ] Ветка `feat/1.0.3` уже есть; не пересоздавать.
- [ ] `project.yml`: `MARKETING_VERSION: "1.0.3"`, `CURRENT_PROJECT_VERSION` +1, `xcodegen generate`
- [ ] Прогнать `cd NouriKit && swift test` — зелёная база перед изменениями
- [ ] **CI не трогаем / не чиним в 1.0.3.** Удалить или оставить disabled [`.github/workflows/ci.yml`](.github/workflows/ci.yml). Проверки — локально через git hooks (раздел 4.4). GitHub Actions не добавлять.

---

## 1. Напоминания о воде от последнего питья (must)

**Проблема.** `HydrationReminderPlanner.slots` (`NouriKit/Sources/NouriKit/Reminders/Reminders.swift`) строит фиксированную сетку от начала awake-окна. Последнее питьё не учитывается — напоминание приходит через 5 минут после стакана.

**Решение.**
- [ ] В `HydrationReminderPlanner.plan` добавить параметр `lastDrinkAt: Date?`.
- [ ] Первое напоминание = `max(lastDrinkAt + interval, awakeStart)`, дальше шаг `interval` до конца awake-окна. Нет питья сегодня — от начала awake-окна (или `now + interval`, если окно уже началось).
- [ ] `AppModel.rescheduleReminders` — передавать время последнего `FluidEntry` (сегодня). Пересчёт уже вызывается из `addFluid`, `handleRemote` (Watch), `AddWaterIntent` — новых триггеров не нужно.
- [ ] ID уведомления строится из fire time — диффинг `ReminderScheduler.apply` сам удалит старые.

**Попутные баги.**
- [ ] Цель на сегодня выполнена → `guard` возвращает `[]` и для завтра. Утром напоминаний нет, пока не откроешь приложение (BG refresh ≥ 12 ч). Фикс: проверку цели применять только к слотам сегодняшнего дня.
- [ ] Тихие часы внутри дня (start < end, напр. 12:00–14:00) — `awakeWindow` выбрасывает всё утро. Фикс: два окна (startOfDay…quietStart, quietEnd…endOfDay) или фильтр `isInQuietHours` по слотам целого дня.

**Тесты (`ReminderTests`).**
- [ ] Выпил в 10:40, интервал 120 → первое напоминание 12:40, не 10:00/12:00.
- [ ] Цель сегодня выполнена → завтрашние слоты есть.
- [ ] Тихие часы 12–14 → утренние слоты есть, 12–14 пусто.

**Ручная проверка.** Интервал 30 мин в Settings, выпить, проверить pending-уведомления (лог `pendingIDs`), выпить с Watch — пересчёт на iPhone.

---

## 2. Спрятать калории (must)

Memo D4: убрать из главного сценария, код не удалять.

- [ ] `UserPreferences.caloriesEnabled: Bool = false` (дефолт обязателен — SwiftData lightweight migration). Сеттер в `NouriStore`, поле в `AppModel`, отправка на Watch через существующий `publishSettings`.
- [ ] Settings: тоггл «Track calories» (секция Goals). Цель калорий и «Calorie Presets» — только при включённом.
- [ ] За флагом спрятать:
  - [ ] `DashboardView.caloriesSection`
  - [ ] kcal в `ActivityRow`, `DeleteUndoBanner`, `UndoBanner` (для напитков — только мл)
  - [ ] `HistoryView` — строка kcal
  - [ ] `FluidForm` — поле «Calories (kcal)» (значение по `beverage.defaultCalories` продолжает писаться молча)
  - [ ] Watch: `CaloriesPage` убрать из свайпа; `DrinkView` — подпись «≈ kcal»
  - [ ] Тексты Health в onboarding и Settings: «water» вместо «water and calories»
- [ ] HealthKit: dietaryEnergy запрашивать только при включённом флаге (решить — см. открытые вопросы).
- [ ] UI-тесты, которые жмут `add-kcal`/`food-*` — включать флаг через launch argument или убрать.

---

## 3. Онбординг (must)

**Баг.** `OnboardingView` — page `TabView`, свайп пролистывает шаги мимо `advance()`: цель и напоминания не сохраняются.
- [ ] Отключить свайп (обычный `switch step` вместо page `TabView`) или сохранять на `onChange(of: step)`.

**Полировка («production ready»).**
- [ ] Прогресс (точки / «2 of 4»), кнопка Skip справа сверху, Back.
- [ ] Первый экран — welcome: что делает Nouri одной фразой (вода + лекарства, без калорий), иконка приложения вместо SF Symbol.
- [ ] Порядок шагов (memo 4.6):
  1. Welcome
  2. Цель воды
  3. Первое лекарство (опционально, «Add later») — переиспользовать форму из `MedicationsView`
  4. Уведомления — один системный запрос, тоггл hydration reminders + интервал
  5. Apple Health (опционально)
  6. Виджет / complication — короткая инструкция, лучше скриншот
- [ ] Единый layout шага: крупная иллюстрация, заголовок, 1–2 строки текста, контрол, primary-кнопка снизу.
- [ ] Локализация новых строк (EN/RU/UK) в `Localization/Localizable.xcstrings`.
- [ ] UI-тест: пройти онбординг до конца + Skip.

---

## 4. Виджеты (must)

**4.1 «…» вместо значений.**
- [ ] Воспроизвести в симуляторе (`systemSmall`, крупный Dynamic Type тоже).
- [ ] Гипотеза: диф 1.0.2 положил три `.bordered` кнопки `+100/+250/+500` в `systemSmall` — не влезают. Варианты: одна кнопка `+250` в small; три кнопки — только в `systemMedium` (добавить family). `.minimumScaleFactor` на значениях.
- [ ] Плейсхолдер/redacted: проверить, что `getSnapshot`/`load` не падает в `.placeholder` на реальном устройстве (App Group в entitlements widget-extension).

**4.2 Кнопки не срабатывают.**
- [ ] Диагностика на устройстве: `Logger` в `AddWaterIntent.perform()`; резолвится ли `@Dependency AppModel` при фоновом запуске приложения; вызывается ли `WidgetCenter.reloadAllTimelines` после записи.
- [ ] Если `LiveActivityIntent` + `@Dependency` ненадёжен — fallback: обычный `AppIntent`, пишет напрямую в `NouriStore` (App Group) и перезагружает таймлайны. Sync на Watch и экспорт в Health — при следующем открытии приложения (`refreshExternal`/диффинг). Ограничение записать в коде комментарием.
- [ ] Виджет лекарств: `widgetURL` → экран доз (сейчас тап просто открывает дашборд). Кнопка «Taken» для ближайшей дозы в `systemSmall` — опционально, тем же механизмом, что вода.

**4.3 Watch: Today-кольца + круглые кнопки по углам (must).**

Сейчас `HydrationView` / `MedicationStatusView` на Watch — `.accessoryCircularCapacity` + `drop.fill` / системный синий. Так выглядит **Water Reminder**. Копировать нельзя.

Циферблат и экран приложения — разный бюджет пикселей. Кнопки в углах **на complication circular не влезают** (слот ~36–44 pt). Их место — **Watch-приложение** (и при возможности Smart Stack `accessoryRectangular`).

**Циферблат — `TodayWidget` (P2), тот же `DayProvider`:**
- [ ] `accessoryCircular` / `accessoryCorner`: **концентрические кольца** как Activity (внешнее = лекарства, внутреннее = вода). Центр: `2/3` или `66%`. Не системный `GaugeStyle.accessoryCircularCapacity`.
- [ ] `accessoryRectangular` (Smart Stack): кольца слева; справа next dose + литры; **две круглые кнопки** — `+250` и Taken ближайшей дозы (если платформа даёт App Intent на watchOS widget; иначе только тап → приложение).
- [ ] `accessoryInline`: `66% · 2/3`.
- [ ] Отдельные Hydration / Medications complications оставить, перекрасить той же палитрой (без синей капли-gauge).

**Watch-приложение — `WaterPage` (и meds, если есть доза):**
- [ ] Центр: те же два кольца (или одно, если лекарств нет).
- [ ] **Четыре круглые кнопки по углам** (не bordered-rect как сейчас): например TL напиток (последний / picker), TR `+250`, BL `+100`, BR `+500` или Taken. Цель — быстрый лог одним тапом, визуально не Water Reminder.
- [ ] Digital Crown custom amount оставить (уже есть).

**Палитра:**
- [ ] Вода: градиент cyan → teal. Лекарства: violet → indigo. Трек — приглушённый, как Activity.
- [ ] Пресеты, не color picker: Settings → Appearance (Default / Ocean / Midnight / High Contrast). `UserPreferences` + `SettingsSnapshot`.

**a11y:** кольца не цвет-only; кнопки ≥44 pt на Watch app; VoiceOver на каждое кольцо и каждую кнопку.

**4.4 Git hooks без Node (must) — не Husky.**

Husky тянет `package.json` / `npm install` в чистый Swift-репозиторий. Не подходит.

Выбранный подход: ** Lefthook** (`brew install lefthook`) + `lefthook.yml` в корне. Бинарь, без Node. Запасной вариант, если не ставить brew-tool: `git config core.hooksPath scripts/githooks` и два shell-скрипта (тот же контракт).

- [ ] `commit-msg`: Conventional Commits regex. Типы: `feat`, `fix`, `chore`, `docs`, `test`, `refactor`, `style`, `perf`. Пример: `feat(reminders): schedule from last drink`.
- [ ] `pre-commit`: `cd NouriKit && swift test`.
- [ ] `pre-push`: `xcodebuild build … Nouri` на iOS Simulator, `CODE_SIGNING_ALLOWED=NO`. UI-тесты на хук не вешать.
- [ ] README: `brew install lefthook && lefthook install`. GitHub Actions не восстанавливать.

---

## 5. Метрики (P3) и что отложить

P2 закрыт в **4.3**.

**5.1 Что логировать в 1.0.3 — локально, без SDK (must для беты).**

Совпадает с memo §9: никаких названий лекарств, мл, точного времени, Health. Только счётчики и поверхности.

- [ ] `AnalyticsStore` в App Group (UserDefaults или маленькая SwiftData entity). Вызовы только из `AppModel` (не из View).
- [ ] События: `first_open`, `onboarding_done`, `med_added` (порядковый номер), `water_logged` / `dose_logged` (поверхность: phone / watch / widget / notification), `complication_seen` (тип виджета).
- [ ] Settings → Data → «Share beta stats»: Share Sheet с JSON. Обновить `docs/privacy.html` и `PrivacyInfo.xcprivacy`, если что-то уходит с устройства **только по явному шарингу**.

Это закрывает выборку 12–50 человек без сервера.

**5.2 Если нужен живой дашборд — не писать свой бэк в 1.0.3.**

Свой бэк + БД имеет смысл позже (кастомные воронки, TestFlight-коды). Сейчас это задержка релиза и смена privacy-политики («we collect nothing»).

Бесплатные / indie-friendly варианты, если всё же нужен remote:

| Сервис | Зачем | Почему подходит / нет |
| --- | --- | --- |
| **Aptabase** | продукт-события, простой дашборд | Open source, бесплатный cloud для инди (~1M events), свой SDK лёгкий. Лучший кандидат, если local-export надоест |
| **TelemetryDeck** | те же события, privacy-first | Заточен под Apple, без IDFA; free tier. Хорошая альтернатива Aptabase |
| **PostHog Cloud** | воронки, если позже вырастете | Щедрый free; тяжелее, чем нужно на 50 человек |
| **GoatCounter / Plausible (self-host)** | лендинг, не приложение | Для `docs/index.html`, не для Watch-тапов |
| Firebase / Amplitude / Mixpanel | — | Не брать: SDK, privacy nutrition, конфликт с текущей политикой |

Правила, если подключать Aptabase/TelemetryDeck: opt-in в онбординге; UUID инсталляции, не Apple ID; никаких `amountML` / имён доз; EU-регион если есть.

**5.3 Не в 1.0.3**

- [ ] **P1.** Повтор напоминания о дозе. Следующая версия.
- [ ] Свой бэк для метрик — только если Aptabase/TelemetryDeck не хватит после первой беты.

---

## 6. Релиз

- [ ] `swift test` + UI-тесты зелёные (локально; CI нет)
- [ ] Ручной прогон на устройстве: онбординг с нуля, вода с Watch/виджета, напоминания за день, **Today complication на циферблате** рядом с Water Reminder — не путать визуально
- [ ] What's New для TestFlight (без слова «calories»)
- [ ] `docs/index.html`, README — убрать калории из описания (memo D4); упомянуть Lefthook как dev-tool
- [ ] PR `feat/1.0.3` → `main` (заодно влить 1.0.2)

---

## Открытые вопросы

- 1.0.2 уже в TestFlight? От этого зависит, нужна ли миграция для тестировщиков с пройденным онбордингом.
- Калории: только флаг (по умолчанию off) или убрать из UI совсем? Запрашивать ли Health dietaryEnergy при выключенном флаге?
- Какие iPhone-виджеты «не работают» — Home Screen вода или ожидалась кнопка Taken у лекарств / lock screen? Watch-дизайн закрыт в 4.3.
- P1 — следующая версия. P2 = 4.3. P3 в 1.0.3 = локальные счётчики + Share Sheet; remote (Aptabase) — только если явно решим после беты.
