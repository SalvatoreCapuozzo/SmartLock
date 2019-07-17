//
//  SmartLockUITests.swift
//  SmartLockUITests
//
//  Created by Salvatore Capuozzo on 01/07/2019.
//  Copyright © 2019 Salvatore Capuozzo. All rights reserved.
//

import XCTest

class SmartLockUITests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    
    func testCodeAccessEmpty() {
        
        let app = XCUIApplication()
        app.otherElements.containing(.button, identifier:"keypad").children(matching: .button).matching(identifier: "keypad").element(boundBy: 1).tap()
        
        
        app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 1).buttons["Accedi"].tap()
        let alert = app.alerts["Errore"].buttons["Riprova"]
        XCTAssert(alert.exists, "Error Alert Didn't Display")
    }
    
    
    func testCodeAccessWrong() {
        
        let app = XCUIApplication()
        app.otherElements.containing(.button, identifier:"keypad").children(matching: .button).matching(identifier: "keypad").element(boundBy: 1).tap()
        
        app/*@START_MENU_TOKEN@*/.keys["1"]/*[[".keyboards.keys[\"1\"]",".keys[\"1\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app/*@START_MENU_TOKEN@*/.keys["2"]/*[[".keyboards.keys[\"2\"]",".keys[\"2\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app/*@START_MENU_TOKEN@*/.keys["3"]/*[[".keyboards.keys[\"3\"]",".keys[\"3\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app/*@START_MENU_TOKEN@*/.keys["5"]/*[[".keyboards.keys[\"5\"]",".keys[\"5\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()

        app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 1).buttons["Accedi"].tap()
        let alert = app.alerts["Errore"].buttons["Riprova"]
        XCTAssert(alert.exists, "Error Alert Didn't Display")
    }
    
    
    func testCodeAccessCorrect() {
        
        let app = XCUIApplication()
        app.otherElements.containing(.button, identifier:"keypad").children(matching: .button).matching(identifier: "keypad").element(boundBy: 1).tap()
        
        app/*@START_MENU_TOKEN@*/.keys["1"]/*[[".keyboards.keys[\"1\"]",".keys[\"1\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app/*@START_MENU_TOKEN@*/.keys["2"]/*[[".keyboards.keys[\"2\"]",".keys[\"2\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app/*@START_MENU_TOKEN@*/.keys["3"]/*[[".keyboards.keys[\"3\"]",".keys[\"3\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.keys["4"].tap()
        app/*@START_MENU_TOKEN@*/.keys["5"]/*[[".keyboards.keys[\"5\"]",".keys[\"5\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app/*@START_MENU_TOKEN@*/.keys["6"]/*[[".keyboards.keys[\"6\"]",".keys[\"6\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
      
        app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 1).buttons["Accedi"].tap()
        let alert = app.alerts["Accesso"].buttons["Done"]
        XCTAssert(alert.exists, "Access Alert Didn't Display")
    }
   
    

}
