//
//  PKHotLabel.h
//  gbible
//
//  Created by Kerri Shotts on 1/1/13.
//  Copyright (c) 2013 photoKandy Studios LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PKHotLabelDelegate.h"

typedef BOOL (^PKCompareBlock)(NSString * theWord);

@interface PKHotLabel : UILabel
{
@private
  NSMutableArray *hotWords;
  NSMutableArray *hotWordsRect;
}

@property (nonatomic, assign) id <PKHotLabelDelegate> delegate;
@property (nonatomic, strong) UIColor *hotColor;
@property (nonatomic, strong) UIColor *hotBackgroundColor;
@property (nonatomic, strong) NSString *hotWord;

@property (nonatomic, strong) UIFont *hotFont;
@property BOOL boldFontWhenhot;

@property (nonatomic, strong) PKCompareBlock hotComparator;

-(NSString *)wordFromPoint: (CGPoint) thePoint;

@end