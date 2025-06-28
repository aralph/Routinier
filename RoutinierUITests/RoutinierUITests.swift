//
//  RoutinierUITests.swift
//  RoutinierUITests
//

import XCTest

final class RoutinierUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    
    func addTestRoutine(app: XCUIApplication) {
        // Tap "Add Routine" button
        app.buttons["Add Routine"].tap()

        // Fill in the fields
        let nameField = app.textFields["Name"]
        XCTAssertTrue(nameField.exists)
        nameField.tap()
        nameField.typeText("Test Routine")

        let descriptionField = app.textFields["Description"]
        XCTAssertTrue(descriptionField.exists)
        descriptionField.tap()
        descriptionField.typeText("A simple test")

        // Confirm save
        app.buttons["Save"].tap()
    }
    
    func cleanStateNoTestRoutines(app: XCUIApplication) {
        // Clean state: If "Test Routine" exists, delete it
        let testRoutine = app.staticTexts["Test Routine"]
        if testRoutine.waitForExistence(timeout: 1) {
            testRoutine.swipeLeft()
            let deleteButton = app.buttons["Delete"]
            if deleteButton.waitForExistence(timeout: 1) {
                deleteButton.tap()
            }
        }
    }
    
    @MainActor
    func testLaunchPerformance() throws {
        let threshold: TimeInterval = 5.0 // seconds
        let app = XCUIApplication()

        let startTime = Date()
        app.launch()
        let launchTime = Date().timeIntervalSince(startTime)

        print("Launch time: \(launchTime) seconds")
        XCTAssertLessThan(launchTime, threshold, "App launch took too long: \(launchTime) seconds")
    }
    
    func testAddRoutineFlow() throws {
        let app = XCUIApplication()
        app.launch()
        
        cleanStateNoTestRoutines(app: app)

        addTestRoutine(app: app)

        // Check if it appears in the list
        let routineCell = app.staticTexts["Test Routine"]
        XCTAssertTrue(routineCell.waitForExistence(timeout: 2))
        
        // Clean up: swipe to delete
        routineCell.swipeLeft()
        let deleteButton = app.buttons["Delete"]
        XCTAssertTrue(deleteButton.exists)
        deleteButton.tap()
    }

    func testSwipeToEditAndDelete() throws {
        let app = XCUIApplication()
        app.launch()
        
        addTestRoutine(app: app)

        let routineCell = app.staticTexts["Test Routine"]
        XCTAssertTrue(routineCell.exists)

        // Swipe left to reveal edit and delete
        routineCell.swipeLeft()

        let editButton = app.buttons["Edit"]
        XCTAssertTrue(editButton.exists)

        let deleteButton = app.buttons["Delete"]
        XCTAssertTrue(deleteButton.exists)
    }
}
