//
//  PKTextView.h
//  gbible
//
//  Created by Kerri Shotts on 2/3/13.
//  Copyright (c) 2013 photoKandy Studios LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PKTextViewDelegate.h"

@interface PKTextView : UITextView

@property (nonatomic, assign) id <PKTextViewDelegate> actionDelegate;

@end
