//
//  PKAppDelegate.h
//  gbible
//
//  Created by Kerri Shotts on 3/12/12.
//  Copyright (c) 2012 photoKandy Studios LLC. All rights reserved.
//

// ============================ LICENSE ============================
//
// The code that is not otherwise licensed or is owned by photoKandy
// Studios LLC is hereby licensed under a CC BY-NC-SA 3.0 license.
// That is, you may copy the code and use it for non-commercial uses
// under the same license. For the entire license, see
// http://creativecommons.org/licenses/by-nc-sa/3.0/.
//
// Furthermore, you may use the code in this app for your own
// personal or educational use. However you may NOT release a
// competing app on the App Store without prior authorization and
// significant code changes. If authorization is granted, attribution
// must be kept, but you must also add in your own attribution. You
// must also use your own API keys (TestFlight, Parse, etc.) and you
// must provide your own support. As the code is released for non-
// commercial purposes, any directly competing app based on this code
// must not require payment of any form (including ads).
//
// Attribution must be visual and be of the form:
//
//   Portions of this code from Greek Interlinear Bible,
//   (C) photokandy Studios LLC and Kerri Shotts, released
//   under a CC BY-NC-SA 3.0 license.
//
// NOTE: The graphical assets are not covered under the above license.
// They are copyright their respective owners. Any third party code
// (such as that under the Third Party section) are licensed under
// their respective licenses.
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

@property (strong, nonatomic) UIImageView *splash;

@property CGFloat brightness;

+(id) instance;
+(PKAppDelegate *) sharedInstance;
-(void)updateAppearanceForTheme;

+(void) applyThemeToUIBarButtonItem: (UIBarButtonItem *)b;
+(void) applyThemeToUINavigationBar: (UINavigationBar *)nba;
+(void) applyThemeToUISearchBar: (UISearchBar *)sba;
+(void) applyThemeToUISegmentedControl: (UISegmentedControl *)sca;


@end