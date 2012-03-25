//
//  PKAppDelegate.h
//  gbible
//
//  Created by Kerri Shotts on 3/12/12.
//  Copyright (c) 2012 photoKandy Studios LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PKConstants.h"
#import "PKSettings.h"
#import "PKDatabase.h"
#import "SegmentsController.h"
#import "ZUUIRevealController.h"

@interface PKAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) PKDatabase *database;
@property (strong, nonatomic) PKSettings *mySettings;
@property (strong, nonatomic) ZUUIRevealController *rootViewController;
@property (strong, nonatomic) SegmentsController *segmentController;
@property (strong, nonatomic) UISegmentedControl *segmentedControl;

@end
