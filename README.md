# Nouri

A small daily health tracker for iPhone and Apple Watch. Nouri tracks three things: fluids, calories and medication reminders. Logging an entry should take a couple of seconds.

- iPhone: Today dashboard with quick-add, custom entries, calorie presets, medications, hydration activity dashboard, 30-day history and settings (including hydration reminders, export and delete-all).
- Apple Watch: one metric per screen (water, calories, medications), swiped horizontally. Quick-add (+100/+250/+500), Digital Crown custom amounts, and today's doses with Taken/Skip.
- Widgets and complications: Hydration (with interactive +100/+250/+500 on the iPhone Home Screen small widget) and Medications status.
- Medication reminders and optional hydration reminders are local notifications (Taken / Snooze / Skip for doses; +100 / +250 / +500 for hydration).

The app uses only Apple frameworks: SwiftUI, SwiftData, HealthKit, WidgetKit, WatchConnectivity, UserNotifications, BackgroundTasks, App Intents and Charts. It has no third-party dependencies.

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
    DaySummary.swift          Daily totals, progress, activity feed, HydrationStats
    Beverage.swift, Formatting.swift
  Persistence/                SwiftData @Models + NouriStore (the only SwiftData user)
  Sync/                       SyncRecord wire format, SyncEngine, WatchConnectivity transport
  Reminders/                  ReminderPlanner, HydrationReminderPlanner, ReminderScheduler
  Health/                     HealthService protocol + HealthKitService (iOS)
  App/AppModel.swift          @Observable façade used by both apps
  App/AddWaterIntent.swift    LiveActivityIntent for widgets / Shortcuts
Nouri/                        iPhone app: App/AppDelegate wiring + SwiftUI views
NouriWatch/                   Watch app: quick actions + medications
Widgets/                      One widget source set, compiled into both widget extensions
NouriUITests/                 Critical-flow UI tests
```

**Data flow.** A view (or widget intent / notification action) calls an intent on `AppModel`, for example `addFluid(250)`. `AppModel` then:
1. writes through `NouriStore`, which returns a `SyncRecord`,
2. publishes the record to the paired device,
3. mirrors it to HealthKit (iPhone),
4. reschedules reminders (medication and hydration),
5. reloads widget timelines and recomputes `today`, which views observe.

Views contain no business logic and never query SwiftData. Both apps use the same `AppModel`. Platform differences come from injected optional services: the Watch has no `HealthService`, and its `ReminderScheduler` only handles snoozes (`plansReminders: false`). Time comes from injected `now`/`calendar` closures, so tests are deterministic.

## Persistence decision

Nouri keeps **SwiftData** as the local store, behind `NouriStore`:

- App Group `group.com.dru1dd.nouri` shares one store between the iPhone app and iOS widgets (Watch has its own container with the same group ID on-device).
- Soft deletes + `updatedAt` support LWW sync and CloudKit-compatible schemas later (defaults on attributes, no unique constraints).
- In-memory containers power unit and UI tests.
- Alternatives (raw SQLite, Core Data stack rewrite, Realm) were rejected: they add dependencies or migration cost without fixing a demonstrated SwiftData failure mode.

## Hydration reminders

Interval + quiet hours (defaults: every 2 hours, quiet 22:00–08:00). One-shot `hydrate.*` notifications share the pending budget with medication `dose.*` reminders (meds first). Reminders are skipped when today’s hydration already meets the goal. Enabling reminders requests notification permission. Actions log water through `AppModel.addFluid`.

## Interactive widgets

The Home Screen small hydration widget uses `AddWaterIntent` (`LiveActivityIntent`) so writes run in the **app process** through `AppModel` (Watch sync + HealthKit + timeline reload). Root causes of a “dead” Add button are usually missing App Group / signing on device, or the app never launching so `AppDependencyManager` never registers `AppModel` — not missing business logic in the extension.

## Data model

| Entity | Purpose |
| --- | --- |
| `FluidEntry` | id, amountML, beverage, calories, timestamp. Soft drinks count toward hydration and calories. |
| `FoodEntry` | id, name, calories, timestamp. |
| `Medication` | id, name, dosage, unit, notes, isActive, schedule JSON. |
| `MedicationLog` | medicationID, doseKey, scheduledTime, takenAt, status. |
| `CaloriePreset` | Named calorie shortcuts. |
| `UserPreferences` | Goals, hydration reminder settings, onboarding flag. |

Every synced entity has `updatedAt` and a soft-delete `deletedAt`.

## Notifications, sync, HealthKit, accessibility

Unchanged core design from prior releases: one-shot dose reminders with Taken/Snooze/Skip; event-based LWW WatchConnectivity sync; HealthKit export via `HKMetadataKeySyncIdentifier`; VoiceOver-friendly progress rows and Dynamic Type.

**Delete All Data** soft-deletes syncable entities, resets prefs, clears managed notifications, publishes deletions to the Watch, and optionally re-exports deletions to HealthKit (checkbox). **Export Data** writes a local JSON file.

## Localization

English (source), Russian, Ukrainian and Polish via String Catalogs. New UI strings should be filled in after a catalog-emitting build (`SWIFT_EMIT_LOC_STRINGS=YES`).

## Privacy

`PrivacyInfo.xcprivacy` in the iPhone and Watch apps: no tracking, no collected data types, UserDefaults `CA92.1`. See `docs/privacy.html`.

## Tests

- `NouriKit/Tests` (Swift Testing, run on macOS): hydration, calories, schedules, reminders (dose + hydration), store, sync, AppModel (undo, edit, delete-all, reminder settings), HydrationStats.
- `NouriUITests`: quick-add, undo, edit water/food, swipe-delete undo, medications, activity dashboard.

## Known limitations

- If the app isn't opened for a long time and background refresh isn't granted, the planned reminder window can run out.
- Medication / hydration times follow local wall-clock time after time-zone changes.
- Configuration is edited on the iPhone; the Watch mirrors it.
- Watch entries reach the iPhone when WatchConnectivity delivers them. No iCloud sync yet.
- Beverage calorie defaults are rough estimates.
- Automatic "missed" medication logs aren't stored.
- Privacy policy contact email still needs a real address before App Store submission.
- `DEVELOPMENT_TEAM`, App Store screenshots, and App Store Connect privacy labels are manual.

## Recommended next steps

1. CloudKit-backed SwiftData for multi-device backup.
2. Fill RU/UK/PL translations for newly emitted String Catalog keys after shipping this release.
3. App Store Connect: screenshots, privacy URL, support URL, age rating, TestFlight.
