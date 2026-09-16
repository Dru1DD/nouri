import XCTest

/// Critical journeys. The app runs with `-ui-testing`: in-memory store and an
/// in-memory notification center, so runs are isolated and need no permission prompts.
@MainActor
final class NouriUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUp() async throws {
        continueAfterFailure = false
        app = XCUIApplication()
        // Fixed locale so formatted numbers ("2,000", "0.25") are predictable.
        app.launchArguments = ["-ui-testing", "-AppleLocale", "en_US", "-AppleLanguages", "(en)"]
        app.launch()
    }

    private func value(of id: String) -> String {
        app.descendants(matching: .any)[id].value as? String ?? ""
    }

    private func waitForValue(_ id: String, containing text: String) {
        let element = app.descendants(matching: .any)[id]
        let predicate = NSPredicate(format: "value CONTAINS %@", text)
        let found = expectation(for: predicate, evaluatedWith: element)
        wait(for: [found], timeout: 5)
    }

    func testAddWaterUpdatesDashboard() {
        XCTAssertTrue(value(of: "hydration-total").contains("0.00 / 2.50 L"))
        app.buttons["add-water-250"].tap()
        waitForValue("hydration-total", containing: "0.25 / 2.50 L")
        waitForValue("hydration-total", containing: "10 percent")
        XCTAssertTrue(app.staticTexts["Water"].exists)
    }

    func testAddCaloriesUpdatesDashboard() {
        app.buttons["add-kcal-500"].tap()
        waitForValue("calories-total", containing: "500 / 2,000 kcal")
    }

    func testCustomCalories() {
        app.buttons["add-kcal-custom"].tap()
        let field = app.textFields["food-calories"]
        XCTAssertTrue(field.waitForExistence(timeout: 3))
        field.tap()
        field.typeText("320")
        app.buttons["food-save"].tap()
        waitForValue("calories-total", containing: "320 / 2,000 kcal")
    }

    private func createMedication(named name: String) {
        app.buttons["Add a medication reminder"].tap()
        app.buttons["add-medication"].tap()
        let nameField = app.textFields["medication-name"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 3))
        nameField.tap()
        nameField.typeText(name)
        app.buttons["medication-save"].tap()
        XCTAssertTrue(app.staticTexts[name].waitForExistence(timeout: 3))
    }

    func testCreateMedicationSchedulesReminders() {
        createMedication(named: "Vitamin D")
        // Default time is 08:00 daily → 13 or 14 reminders over the 14-day window.
        let count = app.staticTexts["reminder-count"]
        XCTAssertTrue(count.waitForExistence(timeout: 3))
        let predicate = NSPredicate(format: "label MATCHES '^1[34] upcoming reminders scheduled$'")
        wait(for: [expectation(for: predicate, evaluatedWith: count)], timeout: 5)
    }

    func testMarkMedicationTakenUpdatesStatus() {
        createMedication(named: "Vitamin D")
        app.navigationBars.buttons.element(boundBy: 0).tap()  // back to dashboard
        let taken = app.buttons["dose-taken-Vitamin D"]
        XCTAssertTrue(taken.waitForExistence(timeout: 3))
        taken.tap()
        waitForValue("medications-total", containing: "1 / 1 taken")
        XCTAssertFalse(taken.exists)
    }

    func testUndoQuickAdd() {
        app.buttons["add-water-500"].tap()
        waitForValue("hydration-total", containing: "0.50 / 2.50 L")
        let shot = XCTAttachment(screenshot: app.screenshot())
        shot.name = "undo-banner"
        shot.lifetime = .keepAlways
        add(shot)
        app.buttons["undo-add"].tap()
        waitForValue("hydration-total", containing: "0.00 / 2.50 L")
    }

    func testEditEntryAmount() {
        app.buttons["add-water-250"].tap()
        app.buttons.containing(NSPredicate(format: "label CONTAINS 'Water'")).firstMatch.tap()
        let amount = app.textFields["fluid-amount"]
        XCTAssertTrue(amount.waitForExistence(timeout: 3))
        amount.tap()
        amount.press(forDuration: 1.2)
        if app.menuItems["Select All"].waitForExistence(timeout: 2) { app.menuItems["Select All"].tap() }
        amount.typeText("400")
        app.buttons["fluid-save"].tap()
        waitForValue("hydration-total", containing: "0.40 / 2.50 L")
    }
}
