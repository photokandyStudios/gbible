//
//  PKLabel.m
//  gbible
//
//  Created by Kerri Shotts on 4/25/12.
//  Copyright (c) 2012 photoKandy Studios LLC. All rights reserved.
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
// ====================================================================
//
// NOTE: THIS FILE IN PARTICULAR IS LICENSED UNDER THE MIT LICENSE.
//
// ====================================================================
#import "PKLabel.h"
#import "UIFont+Utility.h"

@implementation PKLabel

-(id) init
{
  self = [super init];
  
  if (self)
  {
    _shadowColor     = nil;
    _shadowOffset    = CGSizeMake(1.0, 1.0);
    _tag             = 0;
    _text            = @"";
    _textColor       = [UIColor blackColor];
    _backgroundColor = nil;
    _font            = [UIFont fontWithName: @"Helvetica" size: 14];
    _trait        = @"";
  }
  return self;
}

-(id) initWithFrame: (CGRect) theFrame
{
  self = [self init];
  
  if (self)
  {
    _frame = theFrame;
  }
  return self;
}

-(void) draw: (CGContextRef) theCtx
{
  UIFont *theFont = _font;
  // just for kicks
  //if ([text rangeOfString:@"/"].location != NSNotFound) theFont = font.italicFont;
  
  CGContextSaveGState(theCtx);
  {
    if (_backgroundColor)
    {
      CGContextSetFillColorWithColor(theCtx, _backgroundColor.CGColor);
      CGContextFillRect(theCtx, _frame);
    }
    
    if (_shadowColor)
    {
      CGContextSetFillColorWithColor(theCtx, _shadowColor.CGColor);
      CGRect newFrame = _frame;
      newFrame.origin.x += _shadowOffset.width;
      newFrame.origin.y += _shadowOffset.height;
      [_text drawInRect: newFrame withFont: theFont];
    }
    CGContextSetFillColorWithColor(theCtx, _textColor.CGColor);
    [_text drawInRect: _frame withFont: theFont];
  }
  CGContextRestoreGState(theCtx);
}

-(void) dealloc
{
  _text            = nil;
  _backgroundColor = nil;
  _shadowColor     = nil;
  _textColor       = nil;
  _font            = nil;
  _trait        = nil;
}

@end