# Contributing to Nouri

Thanks for helping out! Bug reports, fixes, translations and small features are all welcome.

## Before you start

- For anything bigger than a bug fix, open an issue first so we can agree on the approach.
- Looking for something to do? Check issues labeled [`good first issue`](https://github.com/Dru1DD/nouri/labels/good%20first%20issue) or [`help wanted`](https://github.com/Dru1DD/nouri/labels/help%20wanted), or the "Recommended next steps" in the [README](README.md#recommended-next-steps).

## Setup

See [Running](README.md#running) in the README. You need Xcode 26+ and the iOS/watchOS 26 simulators. The simulator works out of the box, with no Apple Developer account needed.

**Running on your own device:** set your `DEVELOPMENT_TEAM` in `project.yml` and rename the App Group `group.com.dru1dd.nouri` (in `project.yml` and `NouriStore.appGroup`) to one registered on your account. Keep these changes local and don't include them in your PR.

## Making changes

1. Fork the repo and create a branch from `main`.
2. Follow the existing architecture (see [Architecture](README.md#architecture)):
   - business logic goes in `NouriKit`, and views only call `AppModel` intents;
   - no third-party dependencies, only Apple frameworks;
   - inject time (`now`/`calendar`) instead of calling `Date()` directly.
3. Add or update tests. Domain logic belongs in `NouriKit/Tests`.
4. User-facing strings go in the String Catalogs (see [Localization](README.md#localization)). Leave translations empty if you don't speak the language.
5. If you changed targets or settings, edit `project.yml`, run `xcodegen generate` and commit the regenerated `Nouri.xcodeproj`. Don't edit the project file by hand.

## Before opening a PR

```sh
cd NouriKit && swift test
xcodebuild test -project Nouri.xcodeproj -scheme Nouri -destination 'platform=iOS Simulator,name=iPhone 17'
```

CI runs the same checks on every PR and must pass before merging. Keep PRs focused on one change and describe what you changed and why. For UI changes, include screenshots.

## License

By contributing, you agree that your contributions are licensed under the [Apache License 2.0](LICENSE).
