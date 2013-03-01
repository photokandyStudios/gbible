//
//  UIFont+Utility.m
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

#import "UIFont+Utility.h"

@implementation UIFont (Utility)

+(NSString *)fontForFamilyName: (NSString *)fontName
                withAttributes: (PKFontAttribute)attributes
{
  PKFontAttribute fuzzyAttributes = attributes;
  if ( [fontName rangeOfString:@"Bold"].location != NSNotFound ) fuzzyAttributes |= PKFontBold;
  if ( [fontName rangeOfString:@"Italic"].location != NSNotFound ) fuzzyAttributes |= PKFontItalic;
  NSString *theNewFontName = [[fontName stringByReplacingOccurrencesOfString:@"Bold" withString:@""]
                                        stringByReplacingOccurrencesOfString:@"Italic" withString:@""];
  theNewFontName = [theNewFontName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  
  static NSDictionary *fontMap;
  if (!fontMap)
  {
    fontMap = @{ //family                      //substitutionary string       //normal  //bold  //italic  //bold-italic
                 @"American Typewriter Light": @[ @"AmericanTypewriter%@",    @"-Light", @"", @"-Light", @""],
                 @"American Typewriter":       @[ @"AmericanTypewriter%@",    @"", @"-Bold", @"", @"-Bold" ],
                 @"Arial":                     @[ @"Arial%@MT",               @"", @"-Bold", @"-Italic", @"-BoldItalic" ],
                 @"Avenir Light":              @[ @"Avenir%@",                @"-Light", @"-Roman", @"-LightOblique", @"-Oblique" ],
                 @"Avenir":                    @[ @"Avenir%@",                @"-Roman", @"-Heavy", @"-Oblique", @"-HeavyOblique" ],
                 @"Avenir Heavy":              @[ @"Avenir%@",                @"-Heavy", @"-Black", @"-HeavyOblique", @"-BlackOblique" ],
                 @"Avenir Next Light":         @[ @"AvenirNext%@",            @"-UltraLight", @"-Regular", @"-UltraLightItalic", @"-Italic" ],
                 @"Avenir Next":               @[ @"AvenirNext%@",            @"-Regular", @"-Bold", @"-Italic", @"-BoldItalic" ],
                 @"Avenir Next Heavy":         @[ @"AvenirNext%@",            @"-Bold", @"-Heavy", @"-BoldItalic", @"-HeavyItalic" ],
                 @"Baskerville":               @[ @"Baskerville%@",           @"", @"-Bold", @"-Italic", @"-BoldItalic" ],
                 @"Bodoni 72":                 @[ @"BodoniSvtyTwoITCTT%@",    @"-Book", @"-Bold", @"-BookIta", @"-Bold" ],
                 @"Bodoni 72 Oldstyle":        @[ @"BodoniSvtyTwoOSITCTT%@",  @"-Book", @"-Bold", @"-BookIt", @"-Bold" ],
                 @"Chalkboard Light":          @[ @"ChalkboardSE%@",          @"-Light", @"-Regular", @"-Light", @"-Regular" ],
                 @"Chalkboard":                @[ @"ChalkboardSE%@",          @"-Regular", @"-Bold", @"-Regular", @"-Bold" ],
                 @"Cochin":                    @[ @"Cochin%@",                @"", @"-Bold", @"-Italic", @"-BoldItalic" ],
                 @"Copperplate Light":         @[ @"Copperplate%@",           @"-Light", @"", @"-Light", @"" ],
                 @"Copperplate":               @[ @"Copperplate%@",           @"", @"-Bold", @"", @"-Bold" ],
                 @"Courier":                   @[ @"Courier%@",               @"", @"-Bold", @"-Oblique", @"-BoldOblique" ],
                 @"Courier New":               @[ @"CourierNewPS%@MT",        @"", @"-Bold", @"-Italic", @"-BoldItalic" ],
                 @"Didot":                     @[ @"Didot%@",                 @"", @"-Bold", @"-Italic", @"-Bold" ],
                 @"Euphemia UCAS":             @[ @"EuphemiaUCAS%@",          @"", @"-Bold", @"-Italic", @"-Bold" ],
                 @"Futura Medium":             @[ @"Futura-Medium%@",         @"", @"", @"Italic", @"Italic" ],
                 @"Geeza Pro":                 @[ @"GeezaPro%@",              @"", @"-Bold", @"", @"-Bold" ],
                 @"Georgia":                   @[ @"Georgia%@",               @"", @"-Bold", @"-Italic", @"-BoldItalic" ],
                 @"Gill Sans Light":           @[ @"GillSans%@",              @"-Light", @"", @"-LightItalic", @"-Italic" ],
                 @"Gill Sans":                 @[ @"GillSans%@",              @"", @"-Bold", @"-Italic", @"-BoldItalic" ],
                 @"Helvetica Light":           @[ @"Helvetica%@",             @"-Light", @"", @"-LightOblique", @"-Oblique" ],
                 @"Helvetica":                 @[ @"Helvetica%@",             @"", @"-Bold", @"-Oblique", @"-BoldOblique" ],
                 @"Helvetica Neue Light":      @[ @"HelveticaNeue%@",         @"-Light", @"", @"-LightItalic", @"-Italic" ],
                 @"Helvetica Neue":            @[ @"HelveticaNeue%@",         @"", @"-Bold", @"-Italic", @"-BoldItalic" ],
                 @"Hoefler Text":              @[ @"HoeflerText%@",           @"-Regular", @"-Black", @"-Italic", @"-BlackItalic" ],
                 @"Marion":                    @[ @"Marion%@",                @"-Regular", @"-Bold", @"-Italic", @"-Bold" ],
                 @"Marker Felt":               @[ @"MarkerFelt%@",            @"-Thin", @"-Wide", @"-Thin", @"-Wide" ],
                 @"Noteworthy":                @[ @"Noteworthy%@",            @"-Light", @"-Bold", @"-Light", @"-Bold" ],
                 @"Open Dyslexic":             @[ @"OpenDyslexic%@",          @"-Regular", @"-Bold", @"-Italic", @"-BoldItalic" ],
                 @"Optima":                    @[ @"Optima%@",                @"-Regular", @"-Bold", @"-Italic", @"-BoldItalic" ],
                 @"Palatino":                  @[ @"Palatino%@",              @"-Roman", @"-Bold", @"-Italic", @"-BoldItalic" ],
                 @"Snell Roundhand":           @[ @"SnellRoundhand%@",        @"", @"-Bold", @"", @"-Bold" ],
                 @"Times New Roman":           @[ @"TimesNewRomanPS%@MT",     @"", @"-Bold", @"-Italic", @"-BoldItalic" ],
                 @"Trebuchet MS":              @[ @"TrebuchetMS%@",           @"", @"-Bold", @"-Italic", @"-BoldItalic" ],
                 @"Verdana":                   @[ @"Verdana%@",               @"", @"-Bold", @"-Italic", @"-BoldItalic" ]
               };
  }
  
  NSArray *theFont = [fontMap objectForKey:theNewFontName];
  if (theFont)
  {
    NSString *theSubstitutionary = theFont[0];
    NSString *theSubstitionText = theFont[ (NSUInteger)fuzzyAttributes + 1 ];
    return [NSString stringWithFormat:theSubstitutionary, theSubstitionText];
  }
  else
  {
    // return the original -- just in case (for things like Symbol)
    return fontName;
  }
}

+(NSString *)fontForFamilyName: (NSString *)fontName
{
  return [UIFont fontForFamilyName:fontName withAttributes:PKFontNormal];
}

+(UIFont *)fontWithName:(NSString *)fontName andSize:(CGFloat)fontSize usingFallback: (NSString *)altFontName
{
  UIFont *theFont = [UIFont fontWithName: [UIFont fontForFamilyName:fontName] size:fontSize];
  if (!theFont)
  {
    theFont = [UIFont fontWithName: [UIFont fontForFamilyName:altFontName] size:fontSize];
  }
  if (!theFont)
  {
    theFont = [UIFont fontWithName: [UIFont fontForFamilyName:@"Helvetica"] size:fontSize];
  }
  return theFont;
}

+(UIFont *)fontWithName:(NSString *)fontName andSize:(CGFloat)fontSize
{
  return [UIFont fontWithName:fontName andSize:fontSize usingFallback:@"Helvetica"];
}

-(NSString *)mappableFamilyName
{
  NSString *theFamilyName = self.familyName;
  if ([self.fontName rangeOfString:@"Light"].location != NSNotFound)
  {
    theFamilyName = [theFamilyName stringByAppendingString: @" Light"];
  }
  return theFamilyName;
}

-(BOOL) isItalicized
{
  return [self.fontName rangeOfString:@"Italic"].location != NSNotFound ||
         [self.fontName rangeOfString:@"Oblique"].location != NSNotFound ||
         [self.fontName rangeOfString:@"BookIt"].location != NSNotFound; // Bodoni.
}

-(BOOL) isBolded
{
  return [self.fontName rangeOfString:@"Bold"].location != NSNotFound ||
         [self.fontName rangeOfString:@"Heavy"].location != NSNotFound ||
         [self.fontName rangeOfString:@"Black"].location != NSNotFound;
}

-(UIFont *)boldFont
{
  if (self.isItalicized)
  {
    return [UIFont fontWithName:[ self.mappableFamilyName stringByAppendingString: @" Bold Italic" ] andSize:self.pointSize
                   usingFallback: self.fontName];
  }
  else
  {
    return [UIFont fontWithName:[ self.mappableFamilyName stringByAppendingString: @" Bold" ] andSize:self.pointSize                   usingFallback: self.fontName];
  }
}

-(UIFont *)italicFont
{
  if (self.isBolded)
  {
    return [UIFont fontWithName:[ self.mappableFamilyName stringByAppendingString: @" Bold Italic" ] andSize:self.pointSize                   usingFallback: self.fontName];
  }
  else
  {
    return [UIFont fontWithName:[ self.mappableFamilyName stringByAppendingString: @" Italic" ] andSize:self.pointSize                   usingFallback: self.fontName];
  }
}

-(UIFont *)boldItalicFont
{
  return [UIFont fontWithName:[ self.mappableFamilyName stringByAppendingString: @" Bold Italic" ] andSize:self.pointSize                   usingFallback: self.fontName];
}

-(UIFont *)fontWithSizeDelta:(CGFloat)theDelta
{
  return [self fontWithSize:self.pointSize + theDelta];
}

-(UIFont *)fontWithSizeDeltaPercent:(CGFloat)theDeltaPercent
{
  return [self fontWithSize:self.pointSize * theDeltaPercent];
}

@end
