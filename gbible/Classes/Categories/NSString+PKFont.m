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
  if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
  {
    NSDictionary *attrs = @{ NSFontAttributeName: font,
                             NSForegroundColorAttributeName: color,
                             NSLigatureAttributeName: @(ligatures?1:0) };
    [self drawInRect:rect withAttributes:attrs];
  }
  else
  {
    [color setFill];
    [self drawInRect:rect withFont:font];
  }
}
- (void) drawAtPoint:(CGPoint)point withFont:(UIFont *)font withColor:(UIColor *)color usingLigatures:(BOOL) ligatures
{
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
  if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
  {
    NSDictionary *attrs = @{ NSFontAttributeName: font,
                             NSLigatureAttributeName: @(ligatures?1:0) };
    return [self sizeWithAttributes:attrs];
  }
  else
  {
    return [self sizeWithFont:font];
  }
  return CGSizeZero;
}

- (CGSize) sizeWithFont: (UIFont *)font constrainedToSize: (CGSize)size usingLigatures:(BOOL)ligatures
{
  if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
  {
    NSDictionary *attrs = @{ NSFontAttributeName: font,
                             NSLigatureAttributeName: @(ligatures?1:0) };
    return [self boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
  }
  else
  {
    return [self sizeWithFont:font constrainedToSize:size];
  }
  return CGSizeZero;
}

- (CGSize) sizeWithFont: (UIFont *)font constrainedToSize: (CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode usingLigatures:(BOOL)ligatures
{
  if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
  {
    NSDictionary *attrs = @{ NSFontAttributeName: font,
                             NSLigatureAttributeName: @(ligatures?1:0) };
    return [self boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
    
  }
  else
  {
    return [self sizeWithFont:font constrainedToSize:size lineBreakMode:lineBreakMode];
  }
  return CGSizeZero;
}

@end
