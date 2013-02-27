//
//  PKSimpleCollectionViewCell.m
//  gbible
//
//  Created by Kerri Shotts on 1/18/13.
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
#import "PKSimpleCollectionViewCell.h"
#import "PKSettings.h"
#import "UIColor-Expanded.h"

@implementation PKSimpleCollectionViewCell

@synthesize label;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(5,5, frame.size.width-10, frame.size.height-10)];
        self.label.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        self.label.textAlignment = UITextAlignmentCenter;
        self.label.font = [UIFont boldSystemFontOfSize:50.0];
        self.label.backgroundColor = [UIColor clearColor];
        self.label.textColor = [PKSettings PKTextColor];
        self.label.font = [UIFont fontWithName:@"Helvetica-Bold" size:16];
        self.label.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:label];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)dodrawRect:(CGRect)rect
{
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextSaveGState(context);
  
  UIColor *theColor = self.backgroundColor;
  UIColor *backgroundStartColor = [theColor colorByMultiplyingByRed:1.1 green:1.1 blue:1.1 alpha:1.0];
  UIColor *backgroundEndColor = [theColor colorByMultiplyingByRed:0.9 green:0.9 blue:0.9 alpha:1.0];

  // draw our background
/*  CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
  CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
 
  CGContextSaveGState(context);
  CGContextAddRect(context, rect);
  CGContextClip(context);
  
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[] = { 0.0, 1.0 };

 
  NSArray *colors = @[ (id)[backgroundStartColor CGColor], (id)[backgroundEndColor CGColor]];

  CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, 
      (__bridge CFArrayRef) colors, locations);
  
  CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
 
  CGGradientRelease(gradient);
  CGColorSpaceRelease(colorSpace);*/
  
  // draw the edges
  [backgroundStartColor set];
  /* Set the width for the line */
  CGContextSetLineWidth(context,2.f);
  CGContextBeginPath(context);
  CGContextMoveToPoint(context,rect.origin.x, rect.origin.y);
  CGContextAddLineToPoint(context,rect.origin.x, rect.origin.y + rect.size.height);
  CGContextMoveToPoint(context,rect.origin.x, rect.origin.y);
  CGContextAddLineToPoint(context,rect.origin.x + rect.size.width, rect.origin.y );
  /* Use the context's current color to draw the line */
  CGContextStrokePath(context);

  [backgroundEndColor set];
  CGContextBeginPath(context);
  CGContextMoveToPoint(context,rect.origin.x + rect.size.width, rect.origin.y);
  CGContextAddLineToPoint(context,rect.origin.x + rect.size.width, rect.origin.y + rect.size.height);
  CGContextAddLineToPoint(context,rect.origin.x, rect.origin.y + rect.size.height );
  /* Use the context's current color to draw the line */
  CGContextStrokePath(context);
  
  CGContextRestoreGState(context);

  // do our regular drawing (for subviews and such)
  [super drawRect: rect];
}

@end
