//
//  PKSimpleCollectionViewCell.m
//  gbible
//
//  Created by Kerri Shotts on 1/18/13.
//  Copyright (c) 2013 photoKandy Studios LLC. All rights reserved.
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
