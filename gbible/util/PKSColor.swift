//
//  parseColorString.swift
//  gbible
//
//  Created by Kerri Shotts on 4/9/16.
//  Copyright © 2016 photoKandy Studios LLC. All rights reserved.
//

import Foundation
import UIKit

class PKSColor {
  
  static func color(fromHexString hexString: String)->UIColor? {
    if hexString.hasPrefix("#") {
      return color(fromHexString: hexString.substring(from: hexString.characters.index(hexString.startIndex, offsetBy: 1)))
    }
    
    if hexString.characters.count <= 4 {
      return color(fromHexString:
        hexString.characters.reduce("", {(p, c) -> String in
          return (p + String(c)) + String(c)
        })
      )
    }
    
    if hexString.characters.count < 8 {
      return color(fromHexString: hexString + "FF")
    }

    guard hexString.characters.count >= 8 else {
      return UIColor.white;
    }
    
    var hexComponents = ["","","",""];
    for (index, c) in hexString.characters.enumerated() {
      hexComponents[Int(index / 2)] += String(c);
    }
    
    let convertedComponents = hexComponents.map({i -> Float in Float(Int(i, radix: 16)!)/255})
    
    let (r, g, b, a) = (convertedComponents[0], convertedComponents[1],
                        convertedComponents[2], convertedComponents[3])
    
    return UIColor(colorLiteralRed: r, green: g, blue: b, alpha: a);
  }

  static func color(fromString colorString: String)->UIColor? {
    // parse the color string
    // first split by COMMA
    let colorComponents:[String] = colorString.components(separatedBy: ",")
    
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
      return UIColor.white
    }
  }
}
