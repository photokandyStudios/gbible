//
//  PKRootViewController.h
//  gbible
//
//  Created by Kerri Shotts on 3/16/12.
//  Copyright (c) 2012 photoKandy Studios LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PKRootViewController : UITabBarController <UITabBarControllerDelegate>

    @property (strong, nonatomic) UIImageView  *topShadow;
    @property (strong, nonatomic) UIImageView *bottomShadow;
    @property BOOL aViewHasFullScreen;
    
    @property (strong, nonatomic) UIImageView *ourIndicator;

    -(id) init;
    
    -(void) showTopShadowWithOpacity: (CGFloat) opacity;
    -(void) showBottomShadowWithOpacity: (CGFloat) opacity;
    -(void)calcShadowPosition:(UIInterfaceOrientation)toInterfaceOrientation;
    
    -(void) showWaitingIndicator;
    -(void) showRightSwipeIndicator;
    -(void) showLeftSwipeIndicator;
    
    -(void) hideIndicator;

@end
