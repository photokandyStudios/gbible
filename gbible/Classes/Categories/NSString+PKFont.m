//
//  NSString+PKFont.m
//  gbible
//
//  Created by Kerri Shotts on 9/3/13.
//  Copyright (c) 2013 photoKandy Studios LLC. All rights reserved.
//

#import "NSString+PKFont.h"

@implementation NSString (PKFont)
- (void) drawInRect:(CGRect)rect withFont:(UIFont *)font withColor:(UIColor *)color usingLigatures:(BOOL)ligatures
{
  if (!font)  return;
  if (!color) return;
  
    NSDictionary *attrs = @{ NSFontAttributeName: font,
                             NSForegroundColorAttributeName: color,
                             NSLigatureAttributeName: @(ligatures?1:0) };
    [self drawInRect:CGRectIntegral(rect) withAttributes:attrs];
}
- (void) drawAtPoint:(CGPoint)aPoint withFont:(UIFont *)font withColor:(UIColor *)color usingLigatures:(BOOL) ligatures
{
  CGPoint point;
  if (!font)  return;
  if (!color) return;

  point = CGPointMake(ceil(aPoint.x), ceil(aPoint.y));
    NSDictionary *attrs = @{ NSFontAttributeName: font,
                             NSForegroundColorAttributeName: color,
                             NSLigatureAttributeName: @(ligatures?1:0) };
    [self drawAtPoint:point withAttributes:attrs];
}

- (CGSize) sizeWithFont: (UIFont *)font usingLigatures:(BOOL)ligatures
{
  CGSize size = CGSizeZero;
  if (!font)  return size;
  
    NSDictionary *attrs = @{ NSFontAttributeName: font,
                             NSLigatureAttributeName: @(ligatures?1:0) };
    size = [self sizeWithAttributes:attrs];
  size.height = ceil(size.height);
  size.width = ceil(size.width);
  return size;
}

- (CGSize) sizeWithFont: (UIFont *)font constrainedToSize: (CGSize)size usingLigatures:(BOOL)ligatures
{
  CGSize aSize = CGSizeZero;
  if (!font)  return aSize;

    NSDictionary *attrs = @{ NSFontAttributeName: font,
                             NSLigatureAttributeName: @(ligatures?1:0) };
    aSize= [self boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
  aSize.height = ceil(aSize.height);
  aSize.width = ceil(aSize.width);
  return aSize;
}

- (CGSize) sizeWithFont: (UIFont *)font constrainedToSize: (CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode usingLigatures:(BOOL)ligatures
{
  CGSize aSize = CGSizeZero;
  if (!font)  return aSize;

    NSDictionary *attrs = @{ NSFontAttributeName: font,
                             NSLigatureAttributeName: @(ligatures?1:0) };
    aSize= [self boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
    
  aSize.height = ceil(aSize.height);
  aSize.width = ceil(aSize.width);
  return aSize;
}

@end
