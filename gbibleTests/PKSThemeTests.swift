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
    
  func testCanCreateTheme() {
    let theme = try? gbible.PKSTheme(withResource: "theme-0")
    XCTAssertNotNil(theme)
  }
  
  func testMissingTheme() {
    let theme = try? gbible.PKSTheme(withResource: "theme-bookerdo")
    XCTAssertNil(theme)
  }
  
  func testCanGetName() {
    do {
      let theme = try gbible.PKSTheme(withResource: "theme-0")
      XCTAssertEqual(theme.themeName, "Book")
      // make sure it works twice
      XCTAssertEqual(theme.themeName, "Book")

    } catch {
      XCTFail()
    }
  }
  
  func testCanRetrieveColor() {
    do {
      let theme = try gbible.PKSTheme(withResource: "theme-0")
      let tintColor = UIColor(colorLiteralRed: 0.1921568627, green: 0.6549019608, blue: 0.9450980392, alpha: 1.0)
      XCTAssertEqual(theme.getColor(forKey:"tint-color"), tintColor)
    } catch {
      XCTFail()
    }
  }
  
  func testCanGetNumber() {
    do {
      let theme = try gbible.PKSTheme(withResource: "theme-0")
      XCTAssertEqual(theme.getNumber(forKey:"green-highlight-index"), 1)
    } catch {
      XCTFail()
    }
  }
  
  func testCanGetValInStrAr() {
    do {
      let theme = try gbible.PKSTheme(withResource: "theme-0")
      let a = theme.getStringArray(forKey: "highlight-names")
      XCTAssertEqual(a[0], "yellow")
    } catch {
      XCTFail()
    }
  }

}
