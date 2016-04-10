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

class PKSTheme: NSObject {
  
  private let dict: NSDictionary?
  
  init?(withResource resource: String) throws {
    let fileManager = NSFileManager.defaultManager()
    
    guard let pathToResource = NSBundle.mainBundle().pathForResource(resource, ofType: "plist") else { throw ThemeError.FailedToLoadResource }
    
    guard fileManager.fileExistsAtPath(pathToResource) else { throw ThemeError.FailedToLoadResource }
    
    guard let dict = NSDictionary(contentsOfFile: pathToResource) else { throw ThemeError.FailedToLoadResource }
    
    self.dict = dict;
  }
  
  func getValue(forKey key: String)->AnyObject? {
    guard let dict = self.dict else { return nil }
    return dict[key];
  }
  
  func getColor(forKey key: String)->UIColor? {
    guard let colorString:String = getValue(forKey: key) as? String else { return nil }
    
    // parse the color string
    // first split by COMMA
    let colorComponents:[String] = colorString.componentsSeparatedByString(",") ?? [colorString]
    
    // next, we need to convert each component into a corresponding number
    let colorNumberComponents:[CGFloat] = colorComponents.map({s -> CGFloat in CGFloat((s as NSString).floatValue) })
  
    // how we create the color depends upon the number of components
    // 1 == colorWithWhite + 1.0 alpha
    // 2 == colorWithWhite + alpha
    // 3 == RGB Color + 1.0 alpha
    // 4 == RGBA Color
    switch colorNumberComponents.count {
    case 1:
      return UIColor(white: colorNumberComponents[0], alpha: 1.0)
      
    case 2:
      return UIColor(white: colorNumberComponents[0], alpha: colorNumberComponents[1])

    case 3:
      return UIColor(red: colorNumberComponents[0], green: colorNumberComponents[1], blue: colorNumberComponents[2], alpha: 1.0)
      
    case 4:
      return UIColor(red: colorNumberComponents[0], green: colorNumberComponents[1], blue: colorNumberComponents[2], alpha: colorNumberComponents[3])
      
    default:
      return UIColor.whiteColor()
    }
    
  }
  
  var themeName: String? {
    return getValue(forKey:"theme-name") as? String;
  }

}
