//
//  UIImage+PKUtility.m
//  gbible
//
//  Created by Kerri Shotts on 7/25/13.
//  Copyright (c) 2013 photoKandy Studios LLC. All rights reserved.
//

#import "UIImage+PKUtility.h"

@implementation UIImage (PKUtility)


+ (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size andRoundedCornerRadius: (CGFloat)radius{
  // from stackoverflow.com/questions/.../how-to-get-a-color-image-in-iphone-sdk‎
  //Create a context of the appropriate size
  UIGraphicsBeginImageContext(size);
  CGContextRef currentContext = UIGraphicsGetCurrentContext();

  //Build a rect of appropriate size at origin 0,0
  CGRect fillRect = CGRectMake(0,0,size.width,size.height);

  // first portion of if inspired by https://github.com/piotrbernad/FlatUI/blob/master/FlatUI/Classess/UIImage%2BAdditions.m
  if (radius > 0)
  {
    UIBezierPath *roundedRect = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0,0,size.width, size.height) cornerRadius:radius];
    [color setFill];
    [roundedRect fill];
  }
  else
  {
    //Set the fill color
    CGContextSetFillColorWithColor(currentContext, color.CGColor);
    //Fill the color
    CGContextFillRect(currentContext, fillRect);
  }

  //Snap the picture and close the context
  UIImage *retval = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();

  return retval;
}
+ (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size
{
  return [UIImage imageWithColor:color andSize:size andRoundedCornerRadius:0.0];
}
+ (UIImage *)imageWithColor:(UIColor *)color
{
  return [UIImage imageWithColor:color andSize:CGSizeMake(1.0, 1.0)];
}


+ (UIImage*)maskImage:(UIImage *)image withMask:(UIImage *)maskImage
{
/*    //http://www.abdus.me/ios-programming-tips/how-to-mask-image-in-ios-an-image-masking-technique/
    CGImageRef imgRef = [image CGImage];
    CGImageRef maskRef = [maskImage CGImage];
    CGImageRef actualMask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                              CGImageGetHeight(maskRef),
                                              CGImageGetBitsPerComponent(maskRef),
                                              CGImageGetBitsPerPixel(maskRef),
                                              CGImageGetBytesPerRow(maskRef),
                                              CGImageGetDataProvider(maskRef), NULL, false);
    CGImageRef masked = CGImageCreateWithMask(imgRef, actualMask);
    return [UIImage imageWithCGImage:masked];
*/
// http://iosdevelopertips.com/cocoa/how-to-mask-an-image.html
    CGImageRef maskRef = maskImage.CGImage; 

    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
        CGImageGetHeight(maskRef),
        CGImageGetBitsPerComponent(maskRef),
        CGImageGetBitsPerPixel(maskRef),
        CGImageGetBytesPerRow(maskRef),
        CGImageGetDataProvider(maskRef), NULL, false);

    CGImageRef maskedImageRef = CGImageCreateWithMask([image CGImage], mask);
    UIImage *maskedImage = [UIImage imageWithCGImage:maskedImageRef scale:maskImage.scale orientation:maskImage.imageOrientation];

    CGImageRelease(mask);
    CGImageRelease(maskedImageRef);

    // returns new image with mask applied
    return maskedImage;

}

+ (UIImage *)image:(UIImage *)image withColor: (UIColor *)color
{
  CGSize imgSize = CGSizeMake(image.size.width * image.scale, image.size.height * image.scale);
  return [UIImage maskImage:[UIImage imageWithColor:color andSize:imgSize] withMask:image];
}
+ (UIImage *)imageNamed:(NSString *)name withColor:(UIColor *)color
{
  return [UIImage image:[UIImage imageNamed:name] withColor:color];
}



@end
