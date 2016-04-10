//
//  gbibleTests.swift
//  gbibleTests
//
//  Created by Kerri Shotts on 4/9/16.
//  Copyright © 2016 photoKandy Studios LLC. All rights reserved.
//

import XCTest
@testable import gbible

class PKSThemeTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCanMakeWhiteColor() {

      let whiteColor = UIColor(colorLiteralRed:1.0, green: 1.0, blue: 1.0, alpha: 1.0)
      
      XCTAssertEqual(gbible.PKSColor.color(fromString: "1.0"), UIColor.whiteColor())
      XCTAssertEqual(gbible.PKSColor.color(fromString: "1.0, 1.0"), UIColor.whiteColor())
      XCTAssertEqual(gbible.PKSColor.color(fromString: "1.0, 1.0, 1.0"), whiteColor)
      XCTAssertEqual(gbible.PKSColor.color(fromString: "1.0, 1.0, 1.0, 1.0"), whiteColor)

      XCTAssertEqual(gbible.PKSColor.color(fromHexString: "#FFF"), whiteColor)
      XCTAssertEqual(gbible.PKSColor.color(fromHexString: "#FFFF"), whiteColor)
      XCTAssertEqual(gbible.PKSColor.color(fromHexString: "#FFFFFF"), whiteColor)
      XCTAssertEqual(gbible.PKSColor.color(fromHexString: "#FFFFFFFF"), whiteColor)

      XCTAssertEqual(gbible.PKSColor.color(fromHexString: "FFF"), whiteColor)
      XCTAssertEqual(gbible.PKSColor.color(fromHexString: "FFFF"), whiteColor)
      XCTAssertEqual(gbible.PKSColor.color(fromHexString: "FFFFFF"), whiteColor)
      XCTAssertEqual(gbible.PKSColor.color(fromHexString: "FFFFFFFF"), whiteColor)
    }
  
  func testCanMakeRedColor() {
    let redColor = UIColor(colorLiteralRed: 1.0, green: 0, blue: 0, alpha: 1.0);
    
    XCTAssertEqual(gbible.PKSColor.color(fromString: "1.0, 0.0, 0.0"), redColor)
    XCTAssertEqual(gbible.PKSColor.color(fromString: "1.0, 0.0, 0.0, 1.0"), redColor)
    
    XCTAssertEqual(gbible.PKSColor.color(fromHexString: "#F00"), redColor)
    XCTAssertEqual(gbible.PKSColor.color(fromHexString: "#F00F"), redColor)
    XCTAssertEqual(gbible.PKSColor.color(fromHexString: "#FF0000"), redColor)
    XCTAssertEqual(gbible.PKSColor.color(fromHexString: "#FF0000FF"), redColor)

  }
  
  
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
          XCTAssertEqual(gbible.PKSColor.color(fromString: "1.0"), UIColor.whiteColor())
        }
    }
    
}
