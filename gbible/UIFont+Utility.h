//
//  UIFont+Utility.h
//  gbible
//
//  Created by Kerri Shotts on 2/28/13.
//  Copyright (c) 2013 photoKandy Studios LLC. All rights reserved.
//

// ============================ LICENSE ============================
//
// The code that is not otherwise licensed or is owned by photoKandy
// Studios LLC is hereby licensed under a CC BY-NC-SA 3.0 license.
// That is, you may copy the code and use it for non-commercial uses
// under the same license. For the entire license, see
// http://creativecommons.org/licenses/by-nc-sa/3.0/.
//
// Furthermore, you may use the code in this app for your own
// personal or educational use. However you may NOT release a
// competing app on the App Store without prior authorization and
// significant code changes. If authorization is granted, attribution
// must be kept, but you must also add in your own attribution. You
// must also use your own API keys (TestFlight, Parse, etc.) and you
// must provide your own support. As the code is released for non-
// commercial purposes, any directly competing app based on this code
// must not require payment of any form (including ads).
//
// Attribution must be visual and be of the form:
//
//   Portions of this code from Greek Interlinear Bible,
//   (C) photokandy Studios LLC and Kerri Shotts, released
//   under a CC BY-NC-SA 3.0 license.
//
// NOTE: The graphical assets are not covered under the above license.
// They are copyright their respective owners. Any third party code
// (such as that under the Third Party section) are licensed under
// their respective licenses.
//

// UIFont+Utility.[h|m] is (C) Kerri Shotts 2013, and released under an MIT license.

#import <UIKit/UIKit.h>

/**
 *
 * PKFontNormal = no modifications to the font; i.e., -Regular, -Roman, -Book, etc.
 * PKFontBold   = bold font desired (if possible); i.e., -Bold, -Black, -Heavy, etc.
 * PKFontItalic = italic font desired (if possible); i.e., -Italic, -Oblique, etc.
 *
 */
typedef enum {
  PKFontNormal = 0,
  PKFontBold   = 1 << 0,
  PKFontItalic = 1 << 1
} PKFontAttribute;

@interface UIFont (Utility)

/**
 *
 * Returns a string usable for [UIFont fontWithName:size:] based upon the supplied fontName
 * and attributes. 
 *
 * For example:
 *
 *     [UIFont fontForFamilyName: @"Helvetica" withAttributes: PKFontBold] ==> "Helvetica-Bold"
 *
 * In addition, if the font name has the word "Bold" or "Italic" (or both), the attributes will
 * be used as well, so:
 *
 *     [UIFont fontForFamilyName: @"Helvetica Bold" withAttributes: PKFontNormal] ==> "Helvetica-Bold"
 *
 * If a font does not support the desired attributes, the nearest rendition is used. In this
 * case if a font supports bold but not italic, and we request a bold, italic font, the result
 * will be a bold font instead. Likewise, the reverse is true -- if a font only supports italic,
 * and we request a bold, italic font, we'll get italic back instead. 
 *
 * For fonts not supported by the mapping matrix, the original font name is returned (minus the
 * "Bold" and "Italic" attributes). This is used to support "Symbol" and other fonts with only
 * one style. 
 *
 */
+(NSString *)fontForFamilyName: (NSString *)fontName withAttributes: (PKFontAttribute)attributes;

/**
 *
 * Convenience method if you're not going to use the attributes parameter above.
 *
 */
+(NSString *)fontForFamilyName: (NSString *)fontName;

/**
 *
 * Returns a font with the specified fontName (using the above fontForFamilyName:withAttributes method)
 * and if the font is not found, uses the altFontName (using the same method above). If no font is yet
 * found, Helvetica is returned.
 *
 * THIS MEANS THAT YOU WILL NEVER BE PRINTING TEXT WITH A NIL FONT! :-)
 *
 */
+(UIFont *)fontWithName:(NSString *)fontName andSize:(CGFloat)fontSize usingFallback: (NSString *)altFontName;

/**
 *
 * If you have no desire to specify a fallback font, use this method instead.
 * It's also nearly able to drop-in to your code -- just replace "size:" with "andSize:". 
 *
 * For example:
 *
 *     [UIFont fontWithName:@"Helvetica" size:20]
 *
 * becomes
 *
 *     [UIFont fontWithName:@"Helvetica" andSize:20]
 *
 */
+(UIFont *)fontWithName:(NSString *)fontName andSize:(CGFloat)fontSize;

/**
 *
 * Takes the family name of a font instance and tweaks it a bit
 * to return a family name that is semi-orthogonal to the mapping
 * table. Not quite, though, so expect some weirdness.
 *
 */
-(NSString *)mappableFamilyName;

/**
 *
 * Returns YES if the font is italicized.
 *
 */
-(BOOL) isItalicized;

/**
 *
 * Returns YES if the font is bolded.
 *
 */
-(BOOL) isBolded;

/**
 *
 * Returns the bold equivalent of the font instance.
 *
 */
-(UIFont *)boldFont;

/**
 *
 * Returns the italicized equivalent of the font instance.
 *
 */
-(UIFont *)italicFont;

/**
 *
 * Returns the bolded and italicized equivalent of the font instance.
 *
 */
-(UIFont *)boldItalicFont;

/**
 *
 * Returns a font with a new size that is larger or smaller than
 * the original. For example a delta of 6 would return a font 6pts
 * larger than the original.
 *
 */
-(UIFont *)fontWithSizeDelta:(CGFloat)theDelta;

/**
 *
 * Returns a font with the size multiplied by the Delta Percent.
 * For example, if the value is 1.25, the font will be 1.25 times
 * larger than the original.
 *
 */
-(UIFont *)fontWithSizeDeltaPercent:(CGFloat)theDeltaPercent;

@end
