//
//  PKLabel.m
//  gbible
//
//  Created by Kerri Shotts on 4/25/12.
//  Copyright (c) 2012 photoKandy Studios LLC. All rights reserved.
//

#import "PKLabel.h"

@implementation PKLabel

    @synthesize frame;
    @synthesize shadowOffset;
    @synthesize tag;
    @synthesize text;
    @synthesize textColor;
    @synthesize backgroundColor;
    @synthesize shadowColor;
    @synthesize font;
    
    -(id) init
    {
        self = [super init];
        if (self)
        {
            shadowColor = nil;
            shadowOffset = CGSizeMake(1.0, 1.0);
            tag = 0;
            text = @"";
            textColor = [UIColor blackColor];
            backgroundColor = nil;
            font = [UIFont fontWithName:@"Helvetica" size:14];
        }
        return self;
    }
    -(id) initWithFrame:(CGRect) theFrame
    {
        self = [self init];
        if (self)
        {
            frame = theFrame;
        }
        return self;
    }
    -(void) draw:(CGContextRef) theCtx
    {
        CGContextSaveGState(theCtx);
        {
            if (backgroundColor)
            {
                CGContextSetFillColorWithColor(theCtx, backgroundColor.CGColor);
                CGContextFillRect(theCtx, frame);
            }

            if (shadowColor)
            {
                CGContextSetFillColorWithColor(theCtx, shadowColor.CGColor);
                CGRect newFrame = frame;
                newFrame.origin.x += shadowOffset.width;
                newFrame.origin.y += shadowOffset.height;
                [text drawInRect:newFrame withFont:font];
            }
            CGContextSetFillColorWithColor(theCtx, textColor.CGColor);
            [text drawInRect:frame withFont:font];
            
        }
        CGContextRestoreGState(theCtx);
    }
    
    -(void) dealloc
    {
        text = nil;
        backgroundColor = nil;
        shadowColor = nil;
        textColor = nil;
        font = nil;
    }

@end
