//
//  UIImage+PKColor.m
//  gbible
//
//  Created by Kerri Shotts on 7/17/13.
//  Copyright (c) 2013 photoKandy Studios LLC. All rights reserved.
//

#import "UIImage+PKColor.h"

// from stackoverflow.com/questions/.../how-to-get-a-color-image-in-iphone-sdk‎
@implementation UIImage (PKColor)

+ (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size {
  //Create a context of the appropriate size
  UIGraphicsBeginImageContext(size);
  CGContextRef currentContext = UIGraphicsGetCurrentContext();

  //Build a rect of appropriate size at origin 0,0
  CGRect fillRect = CGRectMake(0,0,size.width,size.height);

  //Set the fill color
  CGContextSetFillColorWithColor(currentContext, color.CGColor);

  //Fill the color
  CGContextFillRect(currentContext, fillRect);

  //Snap the picture and close the context
  UIImage *retval = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();

  return retval;
}

+ (UIImage *)imageWithColor:(UIColor *)color
{
  return [UIImage imageWithColor:color andSize:CGSizeMake(1.0, 1.0)];
}

@end
