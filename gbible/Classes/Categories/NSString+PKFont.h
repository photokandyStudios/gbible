//
//  NSString+PKFont.h
//  gbible
//
//  Created by Kerri Shotts on 9/3/13.
//  Copyright (c) 2013 photoKandy Studios LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (PKFont)
- (void) drawInRect:(CGRect)rect withFont:(UIFont *)font withColor:(UIColor *)color usingLigatures:(BOOL)ligatures;
- (void) drawAtPoint:(CGPoint)point withFont:(UIFont *)font withColor:(UIColor *)color usingLigatures:(BOOL) ligatures;
- (CGSize) sizeWithFont: (UIFont *)font usingLigatures:(BOOL)ligatures;
- (CGSize) sizeWithFont: (UIFont *)font constrainedToSize: (CGSize)size usingLigatures:(BOOL)ligatures;
- (CGSize) sizeWithFont: (UIFont *)font constrainedToSize: (CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode usingLigatures:(BOOL)ligatures;
@end
