//
//  UIImage+PKUtility.h
//  gbible
//
//  Created by Kerri Shotts on 7/25/13.
//  Copyright (c) 2013 photoKandy Studios LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (PKUtility)

/** colored images **/
+ (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size;
+ (UIImage *)imageWithColor:(UIColor *)color;
+ (UIImage *)image:(UIImage *)image withColor: (UIColor *)color;
+ (UIImage *)imageNamed:(NSString *)name withColor:(UIColor *)color;

/** masked images **/
+ (UIImage*)maskImage:(UIImage *)image withMask:(UIImage *)maskImage;


@end
