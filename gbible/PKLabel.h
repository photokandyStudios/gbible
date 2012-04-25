//
//  PKLabel.h
//  gbible
//
//  Created by Kerri Shotts on 4/25/12.
//  Copyright (c) 2012 photoKandy Studios LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PKLabel : NSObject

    @property CGRect frame;
    @property CGSize shadowOffset;
    @property int tag;
    @property (nonatomic, strong) NSString * text;
    @property (nonatomic, strong) UIColor * textColor;
    @property (nonatomic, strong) UIColor * backgroundColor;
    @property (nonatomic, strong) UIColor * shadowColor;
    @property (nonatomic, strong) UIFont * font;
    
    -(id) init;
    -(id) initWithFrame:(CGRect) theFrame;
    -(void) draw:(CGContextRef) theCtx;
    -(void) dealloc;

@end
