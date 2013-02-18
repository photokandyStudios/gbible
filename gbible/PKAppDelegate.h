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
#import "PKBibleViewController.h"
#import "PKBibleBooksController.h"
#import "PKNotesViewController.h"
#import "PKHistoryViewController.h"
#import "PKHighlightsViewController.h"
#import "PKStrongsController.h"
#import "PKSearchViewController.h"
@interface PKAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) PKDatabase *database;
@property (strong, nonatomic) PKSettings *mySettings;
@property (strong, nonatomic) ZUUIRevealController *rootViewController;
@property (strong, nonatomic) PKBibleViewController *bibleViewController;
@property (strong, nonatomic) PKBibleBooksController *bibleBooksViewController;
@property (strong, nonatomic) PKNotesViewController *notesViewController;
@property (strong, nonatomic) PKHistoryViewController *historyViewController;
@property (strong, nonatomic) PKHighlightsViewController *highlightsViewController;
@property (strong, nonatomic) PKSearchViewController *searchViewController;
@property (strong, nonatomic) PKStrongsController *strongsViewController;
@property (strong, nonatomic) SegmentsController *segmentController;
@property (strong, nonatomic) UISegmentedControl *segmentedControl;

@property CGFloat brightness;

+(id) instance;
+(PKAppDelegate *) sharedInstance;
-(void)updateAppearanceForTheme;

+(void) applyThemeToUIBarButtonItem: (UIBarButtonItem *)b;
+(void) applyThemeToUINavigationBar: (UINavigationBar *)nba;
+(void) applyThemeToUISearchBar: (UISearchBar *)sba;
+(void) applyThemeToUISegmentedControl: (UISegmentedControl *)sca;

@end