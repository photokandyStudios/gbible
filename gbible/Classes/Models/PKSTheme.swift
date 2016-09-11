//
//  PKSTheme.swift
//  gbible
//
//  Created by Kerri Shotts on 4/9/16.
//  Copyright © 2016 photoKandy Studios LLC. All rights reserved.
//

import UIKit

enum ThemeError: ErrorType {
  case FailedToLoadResource
}

@objc class PKSTheme: NSObject {
  
  private let dict: NSDictionary?
  
  init(withResource resource: String) throws {
    let fileManager = NSFileManager.defaultManager()
    
    guard let pathToResource = NSBundle.mainBundle().pathForResource(resource, ofType: "plist") else { throw ThemeError.FailedToLoadResource }
    
    guard fileManager.fileExistsAtPath(pathToResource) else { throw ThemeError.FailedToLoadResource }
    
    guard let dict = NSDictionary(contentsOfFile: pathToResource) else { throw ThemeError.FailedToLoadResource }
    
    self.dict = dict;
  }
  
  func getValue(forKey key: String)->AnyObject? {
    guard let dict = self.dict else { return nil }
    return dict.valueForKey(key)
  }
  
  func getColor(forKey key: String)->UIColor {
    let colorString = getString(forKey: key)
    if let color = (colorString.substringToIndex(colorString.startIndex.advancedBy(1)) == "#"
                    ? PKSColor.color(fromHexString: colorString)
                    : PKSColor.color(fromString: colorString)) {
      return color
    }
    return UIColor.whiteColor()
  }
  
  func getString(forKey key: String)->String {
    if let s = getValue(forKey: key) as? String {
      return s
    }
    return ""
  }
  
  func getNumber(forKey key: String)->NSNumber {
    if let n = getValue(forKey: key) as? NSNumber {
      return n
    }
    return 0
  }
  
  func getStringArray(forKey key: String)->[String] {
    if let a = getValue(forKey: key) as? [String] {
      return a
    }
    return []
  }
  
  func getNumberArray(forKey key: String)->[NSNumber] {
    if let a = getValue(forKey: key) as? [NSNumber] {
      return a
    }
    return []
  }
  
  func getColorInArray(forKey key: String, atIndex: Int) -> UIColor {
    if let color = PKSColor.color(fromString:self.getStringArray(forKey: key)[atIndex]) {
      return color
    } else {
      return UIColor.whiteColor()
    }
  }
  
  
  lazy var themeName: String = self.getString(forKey:"theme-name")
  lazy var themeIndex: Int = Int(self.getNumber(forKey:"theme-index"))
  
  lazy var tintColor: UIColor = self.getColor(forKey:"tint-color")
  lazy var sidebarSelectionColor: UIColor = self.getColor(forKey:"sidebar-selection-color")
  lazy var sidebarPageColor: UIColor = self.getColor(forKey:"sidebar-page-color")
  lazy var sidebarTextColor: UIColor = self.getColor(forKey:"sidebar-text-color")
  lazy var navigationColor: UIColor = self.getColor(forKey:"navigation-color")
  lazy var navigationTextColor: UIColor = self.getColor(forKey:"navigation-text-color")
  lazy var barButtonTextColor: UIColor = self.getColor(forKey:"bar-button-text-color")
  lazy var selectionColor: UIColor = self.getColor(forKey:"selection-color")
  lazy var wordSelectColor: UIColor = self.getColor(forKey:"word-select-color")
  lazy var secondaryPageColor: UIColor = self.getColor(forKey:"secondary-page-color")
  lazy var pageColor: UIColor = self.getColor(forKey:"page-color")
  lazy var textColor: UIColor = self.getColor(forKey:"text-color")
  lazy var strongsColor: UIColor = self.getColor(forKey:"strongs-color")
  lazy var morphologyColor: UIColor = self.getColor(forKey:"morphology-color")
  lazy var interlinearColor: UIColor = self.getColor(forKey:"interlinear-color")
  lazy var annotationColor: UIColor = self.getColor(forKey:"annotation-color")
  lazy var lightShadowColor: UIColor = self.getColor(forKey:"light-shadow-color")
  lazy var hudBackgroundColor: UIColor = self.getColor(forKey:"hud-background-color")
  lazy var hudForegroundColor: UIColor = self.getColor(forKey:"hud-foreground-color")
  lazy var baseUIColor: UIColor = self.getColor(forKey:"base-ui-color")

  lazy var statusBarStyle: String = self.getString(forKey:"status-bar-style")
  
  lazy var highlightYellowColor: UIColor = self.getColorInArray(forKey: "highlight-colors", atIndex: Int(self.getNumber(forKey:"yellow-highlight-index")))
  lazy var highlightGreenColor: UIColor = self.getColorInArray(forKey: "highlight-colors", atIndex: Int(self.getNumber(forKey:"green-highlight-index")))
  lazy var highlightBlueColor: UIColor = self.getColorInArray(forKey: "highlight-colors", atIndex: Int(self.getNumber(forKey:"blue-highlight-index")))
  lazy var highlightPinkColor: UIColor = self.getColorInArray(forKey: "highlight-colors", atIndex: Int(self.getNumber(forKey:"pink-highlight-index")))
  lazy var highlightMagentaColor: UIColor = self.getColorInArray(forKey: "highlight-colors", atIndex: Int(self.getNumber(forKey:"magenta-highlight-index")))
  
  lazy var highlightNames: [String] = self.getStringArray(forKey: "highlight-names")
  lazy var highlightColors: [String] = self.getStringArray(forKey: "highlight-colors")
  
}
