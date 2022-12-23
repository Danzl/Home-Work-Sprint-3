//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Danzl Wa on 23.12.2022.
//

import XCTest

class MovieQuizUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        app = XCUIApplication()
        app.launch()
        continueAfterFailure = false
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        app.terminate()
        app = nil
    }
    
    func testYesButton() {
        let firstPoster = app.images["Poster"]
        
        app.buttons["Да"].tap()
        
        let indexLabel = app.staticTexts["Index"]
        let secondPoster = app.images["Poster"]
        
        sleep(5)
        
        XCTAssertTrue(indexLabel.label == "2/10")
        XCTAssertFalse(firstPoster == secondPoster)
    }
    
    func testNoButton() {
        let firstPoster = app.images["Poster"]
        
        app.buttons["No"].tap()
        
        let indexLabel = app.staticTexts["Index"]
        let secondPoster = app.images["Poster"]
        
        sleep(5)
        
        XCTAssertTrue(indexLabel.label == "2/10")
        XCTAssertFalse(firstPoster == secondPoster)
    }
    
    func testAlert() {
        var taps = 0
        while taps < 10 {
            sleep(3)
            app.buttons["Yes"].tap()
            taps += 1
        }
        sleep(2)
        
        let alert = app.alerts["Game results"]
        XCTAssertTrue(alert.exists)
        XCTAssertTrue(alert.buttons.firstMatch.label == "Сыграть еще раз")
        XCTAssertTrue(alert.label == "Этот раунд окончен!")
    }
    
    func testAlertDismiss() {
        var taps = 0
        while taps < 10 {
            sleep(3)
            app.buttons["No"].tap()
            taps += 1
        }
        sleep(2)
        
        let alert = app.alerts["Game results"]
        alert.buttons.firstMatch.tap()
        sleep(2)
        
        let indexLabel = app.staticTexts["Index"]
        XCTAssertFalse(alert.exists)
        XCTAssertTrue(indexLabel.label == "1/10")
    }
}
