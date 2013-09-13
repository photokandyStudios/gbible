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
  
  if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
  {
    NSDictionary *attrs = @{ NSFontAttributeName: font,
                             NSForegroundColorAttributeName: color,
                             NSLigatureAttributeName: @(ligatures?1:0) };
    [self drawInRect:CGRectIntegral(rect) withAttributes:attrs];
  }
  else
  {
    [color setFill];
    [self drawInRect:CGRectIntegral(rect) withFont:font];
  }
}
- (void) drawAtPoint:(CGPoint)aPoint withFont:(UIFont *)font withColor:(UIColor *)color usingLigatures:(BOOL) ligatures
{
  CGPoint point;
  if (!font)  return;
  if (!color) return;

  point = CGPointMake(ceil(aPoint.x), ceil(aPoint.y));
  if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
  {
    NSDictionary *attrs = @{ NSFontAttributeName: font,
                             NSForegroundColorAttributeName: color,
                             NSLigatureAttributeName: @(ligatures?1:0) };
    [self drawAtPoint:point withAttributes:attrs];
  }
  else
  {
    [color setFill];
    [self drawAtPoint:point withFont:font];
  }
}

- (CGSize) sizeWithFont: (UIFont *)font usingLigatures:(BOOL)ligatures
{
  CGSize size = CGSizeZero;
  if (!font)  return size;
  
  if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
  {
    NSDictionary *attrs = @{ NSFontAttributeName: font,
                             NSLigatureAttributeName: @(ligatures?1:0) };
    size = [self sizeWithAttributes:attrs];
  }
  else
  {
    size = [self sizeWithFont:font];
  }
  size.height = ceil(size.height);
  size.width = ceil(size.width);
  return size;
}

- (CGSize) sizeWithFont: (UIFont *)font constrainedToSize: (CGSize)size usingLigatures:(BOOL)ligatures
{
  CGSize aSize = CGSizeZero;
  if (!font)  return aSize;

  if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
  {
    NSDictionary *attrs = @{ NSFontAttributeName: font,
                             NSLigatureAttributeName: @(ligatures?1:0) };
    aSize= [self boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
  }
  else
  {
    aSize= [self sizeWithFont:font constrainedToSize:size];
  }
  aSize.height = ceil(aSize.height);
  aSize.width = ceil(aSize.width);
  return aSize;
}

- (CGSize) sizeWithFont: (UIFont *)font constrainedToSize: (CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode usingLigatures:(BOOL)ligatures
{
  CGSize aSize = CGSizeZero;
  if (!font)  return aSize;

  if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
  {
    NSDictionary *attrs = @{ NSFontAttributeName: font,
                             NSLigatureAttributeName: @(ligatures?1:0) };
    aSize= [self boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
    
  }
  else
  {
    aSize= [self sizeWithFont:font constrainedToSize:size lineBreakMode:lineBreakMode];
  }
  aSize.height = ceil(aSize.height);
  aSize.width = ceil(aSize.width);
  return aSize;
}

@end
