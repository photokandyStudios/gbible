//
//  PKTextViewDelegate.h
//  gbible
//
//  Created by Kerri Shotts on 2/3/13.
//  Copyright (c) 2013 photoKandy Studios LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PKTextView;

@protocol PKTextViewDelegate <NSObject>

@required

-(void)pickVerse;
-(void)showVerse;
-(void)defineStrongs;

@end