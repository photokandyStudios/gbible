//
//  PKLabel.h
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
#import <UIKit/UIKit.h>

@interface PKLabel : NSObject

@property CGRect frame;
@property CGSize shadowOffset;
@property int tag;
@property int secondTag;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, strong) UIColor *shadowColor;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) NSString *trait;

-(id)   init;
-(id)   initWithFrame: (CGRect) theFrame;
-(void) draw: (CGContextRef) theCtx;
-(void) dealloc;

@end