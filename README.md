# Nouri

A small daily health tracker for iPhone and Apple Watch. Nouri tracks three things: fluids, calories and medication reminders. Logging an entry should take a couple of seconds.

- iPhone: a one-screen dashboard with quick-add buttons, custom entries, calorie presets, medications, a 30-day history and settings.
- Apple Watch: one metric per screen (water, calories, medications), swiped horizontally. Each page opens on a large ring; scrolling down reveals the quick-add buttons (💧 +100/+250/+500, 🔥 +100/+250/+500, presets) or today's doses with Taken/Skip.
- Widgets and complications: Hydration (💧 %) and Medications (💊 2/3 + next dose) for the iPhone Home/Lock Screen, the Watch face and the Smart Stack.
- Medication reminders are local notifications with **Taken / Snooze 10 min / Skip** actions.

The app uses only Apple frameworks: SwiftUI, SwiftData, HealthKit, WidgetKit, WatchConnectivity, UserNotifications and BackgroundTasks. It has no third-party dependencies.

## Running

Requirements: Xcode 26+, the iOS 26 simulator, and the watchOS 26 simulator (`xcodebuild -downloadPlatform watchOS`).

```sh
open Nouri.xcodeproj            # scheme "Nouri" (iPhone + embedded Watch app), "NouriWatch"

# Domain/unit tests: fast, run on macOS, no simulator needed
cd NouriKit && swift test

# Everything, including UI tests
xcodebuild test -project Nouri.xcodeproj -scheme Nouri -destination 'platform=iOS Simulator,name=iPhone 17'
```

The project is generated from `project.yml` with [XcodeGen](https://github.com/yonaskolb/XcodeGen). The generated `Nouri.xcodeproj` is committed, so you only need XcodeGen (`brew install xcodegen && xcodegen generate`) if you change targets or settings. XcodeGen is a development tool only and is not an app dependency.

To run on a device, set your `DEVELOPMENT_TEAM` in `project.yml`. Then register the App Group `group.com.dru1dd.nouri` (or rename it in `project.yml` and `NouriStore.appGroup`) and enable HealthKit.

## Architecture

```text
NouriKit/                     Swift package: everything shared by iPhone, Watch and widgets
  Domain/                     Pure value types and rules (no frameworks beyond Foundation)
    MedicationSchedule.swift  TimeOfDay, schedule → DoseOccurrence, DoseStatus
    DaySummary.swift          Daily totals, progress, activity feed
    Beverage.swift, Formatting.swift
  Persistence/                SwiftData @Models + NouriStore (the only SwiftData user)
  Sync/                       SyncRecord wire format, SyncEngine, WatchConnectivity transport
  Reminders/                  ReminderPlanner (pure), ReminderScheduler (diffing), notification clients
  Health/                     HealthService protocol + HealthKitService (iOS)
  App/AppModel.swift          @Observable façade used by both apps
Nouri/                        iPhone app: App/AppDelegate wiring + SwiftUI views
NouriWatch/                   Watch app: quick actions + medications
Widgets/                      One widget source set, compiled into both widget extensions
NouriUITests/                 Critical-flow UI tests
```

**Data flow.** A view calls an intent on `AppModel`, for example `addFluid(250)`. `AppModel` then:
1. writes through `NouriStore`, which returns a `SyncRecord`,
2. publishes the record to the paired device,
3. mirrors it to HealthKit (iPhone),
4. reschedules reminders (medication changes),
5. reloads widget timelines and recomputes `today`, which views observe.

Views contain no business logic and never query SwiftData. Both apps use the same `AppModel`. Platform differences come from injected optional services: the Watch has no `HealthService`, and its `ReminderScheduler` only handles snoozes (`plansReminders: false`). Time comes from injected `now`/`calendar` closures, so tests are deterministic.

The only protocols are the three seams that have more than one implementation: `SyncTransport` (WatchConnectivity / loopback in tests), `NotificationClient` (system / in-memory) and `HealthService`. Persistence tests run against a real in-memory SwiftData container, so the store has no protocol.

## Data model

| Entity | Purpose |
| --- | --- |
| `FluidEntry` | id, amountML, beverage, calories, timestamp. A soft drink counts toward both hydration and calories. |
| `FoodEntry` | id, name, calories, timestamp. |
| `Medication` | id, name, dosage, unit, notes, isActive, and a `MedicationSchedule` (times[], weekdays, start/end dates) stored as JSON so it can change without a schema migration. |
| `MedicationLog` | What actually happened: medicationID, doseKey, scheduledTime, takenAt, status (`taken`/`skipped`/`missed`). It is kept separate from the definition. |
| `CaloriePreset` | "Breakfast · 450 kcal", etc. |
| `UserPreferences` | Daily goals. |

Every synced entity has `updatedAt` and a soft-delete `deletedAt`. None of them has a unique constraint, and every attribute has a default, which keeps the schema CloudKit-compatible for later.

**Dose identity.** A dose is identified by `doseKey = medicationID | local date | HH:mm`. It is independent of time zone, so a dose you logged at 08:00 in Kyiv still shows as taken after you fly to London that day.

**Dose status** is derived as follows:
- `taken` or `skipped` if a log says so.
- Otherwise `upcoming` before the scheduled time.
- `due` for 1 hour after it.
- `missed` after that.

Nouri doesn't write "missed" records in the background. The value exists in the log enum for explicit use.

## Time handling

- Days are `Calendar.dateInterval(of: .day)` in the current calendar and time zone, so 23- and 25-hour DST days work.
- Schedules are wall-clock times. Occurrences are resolved with `Calendar.nextDate(... matchingPolicy: .nextTime, repeatedTimePolicy: .first)`:
  - a 02:30 dose on a spring-forward day fires at 03:00,
  - a 01:30 dose on a fall-back day fires once.
- The app refreshes and replans on launch, on foreground, on `NSSystemTimeZoneDidChange`, and on `significantTimeChangeNotification` (midnight, clock change).
- Tests cover midnight boundaries, time-zone changes, and both DST transitions (`America/New_York`).

## Notifications

- `ReminderPlanner` is pure. It lists the next unresolved future doses as **one-shot** requests: 14 days ahead, capped at 60 because iOS allows 64 pending requests per app. Request IDs are deterministic (`dose.<doseKey>`).
- `ReminderScheduler.apply(plan)` is idempotent:
  - it removes pending `dose.*` requests that are no longer planned,
  - it re-adds every planned request (adding an existing identifier replaces it rather than duplicating it).
  - Relaunching the app or editing a medication never creates duplicates.
- One-shot requests, rather than repeating triggers, let Nouri:
  - skip doses already taken early,
  - support weekdays and start/end dates,
  - remove a dose's notification once you resolve it.
- Actions:
  - **Taken / Skip** writes a `MedicationLog`, clears that dose's pending and delivered notifications, syncs and replans.
  - **Snooze** adds `snooze.<doseKey>` for 10 minutes later. The planner never touches snoozes.
- Replanning happens:
  - on launch and foreground,
  - on time-zone and clock changes,
  - after every notification action (the app is woken in the background),
  - in a `BGAppRefreshTask` roughly twice a day, which keeps the 14-day window topped up.
- Notification permission is requested only when you save your first medication. If it's denied, the Medications screen shows a warning with a link to Settings.
- **Watch:** only the iPhone plans dose reminders (`AppModel(plansReminders: false)` on the Watch), and watchOS mirrors them to the Watch, so no reminder fires twice.
  - The Watch app still registers the same category and a notification delegate, so **Taken / Skip / Snooze** work wherever the system delivers the tap. Taken/Skip sync to the iPhone like any Watch entry; Snooze schedules a one-off local notification on the Watch.
  - When a dose resolved on one device arrives on the other, that device clears its pending and delivered notifications for the dose.
- **Delegate threading:** both apps implement the completion-handler variants of `UNUserNotificationCenterDelegate` and call the handler on the main thread. The `async` variants finish off the main thread and crash with "Call must be made on main thread".

## iPhone ↔ Watch sync

Sync is event-based, idempotent and last-writer-wins:

- **Entries and dose logs** (`SyncMessage.record`) go over `WCSession.transferUserInfo`. The OS queues them, they survive app termination and the counterpart being unreachable, and they arrive in order.
- **Settings** (goals, medications, presets, including soft deletions) go over `updateApplicationContext` as a single `SettingsSnapshot`, because only the latest state matters. The iPhone owns configuration and the Watch mirrors it.
- **Backfill:** on its first activation, the Watch sends `backfillRequest`. The iPhone replies with the last 3 days of records plus a snapshot.
- **Idempotency:** a record is applied only if its `updatedAt` is strictly newer than the stored one. Duplicate or stale deliveries are no-ops. Deletions are upserts with `deletedAt`, so a late "create" can't bring a deleted entry back.
- **Conflicts:** if both devices log the same dose while offline, the two logs merge into one (matched by `doseKey`) and the later action wins. Local writes always stamp a version newer than the stored one.

`SyncTests` uses an in-process loopback transport to cover:
- a Watch entry reaching the iPhone (flow 5),
- offline queueing,
- duplicate delivery,
- conflicting dose events,
- snapshot deletions,
- backfill.

## Quick fixes: undo, time, editing

- After every quick add, a banner ("Added 250 ml · Water · **Undo**") stays for 5 seconds; the Watch shows an "Undo +250 ml" row. Undo soft-deletes the entry, so it syncs like any deletion. VoiceOver announces the banner.
- The custom drink/food forms have a **Time** picker (past only), so entries can be logged after the fact. Future times are clamped to now.
- Tapping an entry in *Recent Activity* opens it for editing (amount, drink type, calories, name, time). Edits are LWW upserts and sync to the other device.

## Localization

English (source), Russian, Ukrainian and Polish, all via String Catalogs:
- `Localization/Localizable.xcstrings`: shared by the iPhone app, Watch app and both widget extensions.
- `NouriKit/Sources/NouriKit/Resources/Localizable.xcstrings`: beverage names, dose statuses, notification title and action buttons (`bundle: .module`).
- `Nouri/InfoPlist.xcstrings`: HealthKit permission texts.

Numbers, dates and times use the user's locale. Reminder counts use plural variants (one/few/many). Notification text is localized when the reminder is scheduled, so it follows the language at that moment.

To add strings: build with `SWIFT_EMIT_LOC_STRINGS=YES` (Xcode does this automatically) and fill in the new keys in the catalog. Strings passed around as `String` must be created with `String(localized:)`; only literals are localized automatically by SwiftUI.

## Privacy

`PrivacyInfo.xcprivacy` in the iPhone and Watch apps: no tracking, no collected data types (nothing leaves the user's devices), and the `UserDefaults` required-reason API declared with `CA92.1`.

## HealthKit

The app requests only `dietaryWater` and `dietaryEnergyConsumed`, both read and write, and only when you tap **Settings → Connect Apple Health**.

- **Export (iPhone only):** every fluid and food entry is saved with `HKMetadataKeySyncIdentifier` (the entry id) and `HKMetadataKeySyncVersion` (`updatedAt`).
  - Re-exports replace the existing sample instead of duplicating it.
  - Deleting an entry deletes its sample.
  - Entries logged on the Watch are exported when they reach the iPhone.
- **Import:** today's totals from *other* sources (Nouri's own source is excluded) appear as a separate "N ml more in Apple Health from other apps" line. They are never merged into or overwrite Nouri entries.
- If you deny access, or Health isn't available, the app works exactly the same without these lines.

## Accessibility

- Progress rows are single VoiceOver elements, for example "Hydration, 1.65 / 2.50 L, 66 percent of goal".
- Quick-add buttons have spoken labels, for example "Add 250 milliliters".
- Dose status always shows text and an icon (✓ Taken, ⏰ Upcoming, ⚠ Missed), never color alone.
- All text uses Dynamic Type styles.
- Tap targets are standard bordered buttons and 44 pt weekday toggles.
- There are no custom animations.

## Tests

- `NouriKit/Tests` (Swift Testing, 53 tests, run in well under a second on macOS):
  - hydration, calories, presets, beverage calories,
  - schedules (weekdays, start/end dates, multiple doses, multiple medications),
  - dose status (upcoming/due/missed/taken/skipped), snooze,
  - notification planning and diffing against an in-memory notification center,
  - dates: midnight, time zones, DST,
  - SwiftData store behavior,
  - sync: duplicates, offline delivery, conflicts, backfill,
  - `AppModel` flows: undo, backdating, editing, and the Watch notification mode.
- `NouriUITests` covers:
  - add 250 ml, and the dashboard updates;
  - add 500 kcal and a custom calorie amount;
  - create a medication, and reminders are scheduled;
  - mark a dose Taken, and the status updates;
  - undo a quick add;
  - edit an entry's amount.

  The app launches with `-ui-testing`, which uses an in-memory store and an in-memory notification center. Flow 5 (Watch → iPhone) can't be driven by XCUITest across two simulators, so `SyncTests.watchEntryReachesPhone` and friends cover it at the engine level.

## Known limitations

- If the app isn't opened, no notification action is used and iOS never grants background refresh for more than about 14 days, reminders stop at the end of the planned window.
- Medication times follow local wall-clock time. After a time-zone change, the next reminders move to the new local time. There is no "keep home time zone" option.
- Configuration (medications, goals, presets) is edited on the iPhone only. The Watch mirrors it.
- Watch entries reach the iPhone only when WatchConnectivity delivers them, which can take a while. There is no iCloud sync.
- Widgets are read-only (tapping opens the app). Interactive widget buttons would need a sync hand-off from the extension process.
- Beverage calorie defaults are rough estimates meant only to prefill the field.
- Automatic "missed" logs aren't stored. Missed status is computed.
- The Watch has no custom-amount entry.

## Recommended next steps

1. App Intents: "Log 250 ml water" for Siri, Shortcuts, the Action button, and interactive widget and Control Center buttons.
2. A CloudKit-backed SwiftData container for multi-device and backup. The schema is already compatible.
3. Push the next reminders when the app is backgrounded, and add a "reminders paused" warning when the planned window is nearly used up.
4. Watch custom amounts with the Digital Crown, and a Watch-side medication reminder for users without an iPhone nearby.
5. Caffeine and macronutrients: extend `FluidRecord`/`FoodRecord`. The sync format is Codable and tolerant of new optional fields.
6. History detail and simple weekly trends. Swift Charts only if they prove useful.
7. More languages: add a column to the three String Catalogs.
