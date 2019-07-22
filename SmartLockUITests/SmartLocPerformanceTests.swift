//
//  SmartLocPerformanceTests.swift
//  SmartLockUITests
//
//  Created by Federica Ventriglia on 22/07/2019.
//  Copyright © 2019 Salvatore Capuozzo. All rights reserved.
//


import XCTest

class SmartLockPerformanceTests: XCTestCase {
    
    static var testCount = testInvocations.count
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
        SmartLockUITests.testCount -= 1
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        if SmartLockUITests.testCount == 0 {
            print("Finishing Up Tests -- Tear Down and Exit")
        }
        super.tearDown()
    }

    func testPerformanceOfApp() {
        self.measure {
            XCUIApplication().launch()
            XCUIApplication().otherElements.containing(.textField, identifier:"Inserisci condomino da cercare").children(matching: .textField).matching(identifier: "Inserisci condomino da cercare").element(boundBy: 1).tap()
        }
    }
    
    func testPerformanceMeasureMetrics() {
        self.measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
            startMeasuring()
//            print(app.debugDescription)
            XCUIApplication().otherElements.containing(.textField, identifier:"Inserisci condomino da cercare").children(matching: .textField).matching(identifier: "Inserisci condomino da cercare").element(boundBy: 1).tap()
            stopMeasuring()
        }
    }
    
    
}

