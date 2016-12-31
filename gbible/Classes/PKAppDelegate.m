//
//  PKAppDelegate.m
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
#import "PKAppDelegate.h"
#import "PKBibleBooksController.h"
#import "PKHistoryViewController.h"
#import "PKNotesViewController.h"
#import "PKHighlightsViewController.h"
//#import "PKRootViewController.h"
#import "PKBibleViewController.h"
//#import "iOSHierarchyViewer.h"
#import "PKSettings.h"
#import "NSString+FontAwesome.h"
#import "iRate.h"
#import "PKSearchViewController.h"
#import "PKStrongsController.h"
#import "UIFont+Utility.h"
#import "AccessibleSegmentedControl.h"
#import "APIKeys.h"
#import "UIImage+PKUtility.h"
#import "UIColor-Expanded.h"
#import "SVProgressHUD.h"
#import "NSObject+PKGCD.h"
#import "GTScrollNavigationBar.h"

#import <QuartzCore/QuartzCore.h>

#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>


@implementation PKAppDelegate


static PKAppDelegate * _instance;

+(void) initialize
{
  [iRate sharedInstance].promptAtLaunch = NO;
}

/**
 *
 * returns the global instance of PKAppDelegate (for singleton properties)
 *
 */
+(id) instance
{
  @synchronized(self) {
    if (!_instance)
    {
      _instance = [[self alloc] init];
    }
  }
  return _instance;
}

+(PKAppDelegate *)sharedInstance
{
  return ((PKAppDelegate *)[self instance]);
}

-(void)applyProxyToView: (UIView *)theView
{
 
  // do we have subviews?
  if ( theView.subviews.count > 0 )
  {
    for ( UIView *aView in theView.subviews )
    {
      [self applyProxyToView:aView];
    }
  }
  
  [theView setNeedsDisplay];
  [theView setNeedsLayout];
}


+(void) applyThemeToUIBarButtonItem: (UIBarButtonItem *)b
{
  if (b.tag == 498)
    return;
  
  b.tintColor = [PKSettings PKTintColor];
}

+(void) applyThemeToUINavigationBar: (UINavigationBar *)nba
{
  
    nba.barStyle = [PKSettings PKBarStyle];
    nba.titleTextAttributes = @{ NSForegroundColorAttributeName: [PKSettings PKTextColor],
                                 NSFontAttributeName: [UIFont fontWithName:PKSettings.interfaceFont size:20]
                                 };
  
}

+(void) applyThemeToUISearchBar: (UISearchBar *)sba
{
    sba.barTintColor = [PKSettings PKSecondaryPageColor];
}

-(void)updateAppearanceForTheme
{
  self.window.tintColor = [PKSettings PKTintColor];
  
  // and then update everything we possibly can that might be on screen
  if ([[UIBarButtonItem class] respondsToSelector: @selector(appearance)])
  {
    
    NSMutableArray *va = [[NSMutableArray alloc] initWithArray:
                          @[ _bibleBooksViewController, _notesViewController,
                          _highlightsViewController, _historyViewController,
                          _searchViewController, _strongsViewController ] ];
      [va addObject:_bibleBooksViewController];
      [va addObject:_bibleViewController];
    for ( UIViewController * nb in va )
    {
      [PKAppDelegate applyThemeToUINavigationBar:nb.navigationController.navigationBar];
      
      if ([nb respondsToSelector:@selector(updateAppearanceForTheme)])
      {
        [nb performSelector:@selector(updateAppearanceForTheme)];
      }
    }
  }
  [SVProgressHUD setBackgroundColor:[PKSettings PKHUDBackgroundColor]];
  [SVProgressHUD setForegroundColor:[PKSettings PKHUDForegroundColor]];
  [SVProgressHUD setFont:[UIFont fontWithName:PKSettings.interfaceFont size:16]];
  [SVProgressHUD setSuccessImage:[UIImage imageNamed:@"CheckMark-30" withColor:[PKSettings PKHUDForegroundColor]]];

  // update our proxies
  if ([[UIBarButtonItem class] respondsToSelector: @selector(appearance)])
    [PKAppDelegate applyThemeToUIBarButtonItem:[UIBarButtonItem appearance]];
  if ([[UINavigationBar class] respondsToSelector: @selector(appearance)]) {
    UINavigationBar* nba = [UINavigationBar appearance];
    [PKAppDelegate applyThemeToUINavigationBar:nba];
  }
  if ([[UISearchBar class] respondsToSelector: @selector(appearance)])
    [PKAppDelegate applyThemeToUISearchBar:[UISearchBar appearance]];
  
  
  [self.rootViewController setNeedsStatusBarAppearanceUpdate];
}

/**
 *
 * Do all the application startup. We open our databases, load our settings, and create all
 * our views.
 */
-(BOOL)application: (UIApplication *) application didFinishLaunchingWithOptions: (NSDictionary *) launchOptions
{
  _instance = self;
  
 
  //open our databases...
  _database   = [PKDatabase instance];
  
  //and get our settings
  _mySettings = [PKSettings instance];
  [_mySettings reloadSettings];
  
  if ([_mySettings usageStats] == YES)
  {
    [Fabric with:@[[Crashlytics class]]];
  }
  
  // init our icloud container
  [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
  
  [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
  
  self.window = [[UIWindow alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
  // define our "top-level" controller -- this is the one above the navigation panel
  _bibleViewController = [[PKBibleViewController alloc] initWithStyle: UITableViewStylePlain];
  // define an array that houses all our navigation panels.
  
  _bibleBooksViewController = [[PKBibleBooksController alloc] initWithCollectionViewLayout:[UICollectionViewFlowLayout new]];
  _highlightsViewController = [[PKHighlightsViewController alloc] init];
  _notesViewController = [[PKNotesViewController alloc] init];
  _historyViewController = [[PKHistoryViewController alloc] init];
  _searchViewController = [[PKSearchViewController alloc] initWithStyle:UITableViewStylePlain];
  _strongsViewController = [[PKStrongsController alloc] initWithStyle:UITableViewStylePlain];
  NSArray *navViewControllers         = @[ _bibleBooksViewController, _highlightsViewController,
                                           _notesViewController,
                                           _strongsViewController, _searchViewController,
                                           _historyViewController
                                           ];
  
  UINavigationController *segmentedNavBarController =
  [[UINavigationController alloc] init];
  segmentedNavBarController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
  self.segmentController = [[SegmentsController alloc]
                            initWithNavigationController: segmentedNavBarController viewControllers: navViewControllers];
  
    self.segmentedControl  = [[AccessibleSegmentedControl alloc]
                              initWithItems: @[ [UIImage imageNamed:@"Books-30" withColor:[PKSettings PKTintColor]],
                                                [UIImage imageNamed:@"Tag-30" withColor:[PKSettings PKTintColor]],
                                                [UIImage imageNamed:@"Pencil-30" withColor:[PKSettings PKTintColor]],
                                                [UIImage imageNamed:@"Strongs-30" withColor:[PKSettings PKTintColor]],
                                                [UIImage imageNamed:@"Search-30" withColor:[PKSettings PKTintColor]],
                                                [UIImage imageNamed:@"History-30" withColor:[PKSettings PKTintColor]]
                              ]];

  self.segmentedControl.segmentAccessibilityLabels = @[ __T(@"Goto"), __T(@"Highlights"), __T(@"Notes"),
                                                        __T(@"Strong's"), __T(@"Search"), __T(@"History")];
  [self.segmentedControl setTitleTextAttributes:@{ NSFontAttributeName: [UIFont fontWithName:kFontAwesomeFamilyName size:20] } forState:UIControlStateNormal];
  [self.segmentedControl addTarget: self.segmentController
                            action: @selector(indexDidChangeForSegmentedControl:)
                  forControlEvents: UIControlEventValueChanged];
  
  self.segmentedControl.selectedSegmentIndex = 0;
  
  if ([self.segmentedControl respondsToSelector: @selector(setApportionsSegmentWidthsByContent:)])
  {
    self.segmentedControl.apportionsSegmentWidthsByContent = YES;
  }
  self.segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  
  CGRect scFrame = segmentedNavBarController.view.bounds;
  scFrame.origin.y            = 5;
  scFrame.size.height         = 34;
  self.segmentedControl.frame = scFrame;
  
  [self.segmentController indexDidChangeForSegmentedControl: _segmentedControl];
  
  // define our ZUII
  //UINavigationController *NC = [[UINavigationController alloc] initWithRootViewController:_bibleViewController];
  UINavigationController *NC = [[UINavigationController alloc] initWithNavigationBarClass:[GTScrollNavigationBar class] toolbarClass:nil];
  [NC setViewControllers:@[ _bibleViewController ] animated:NO];
  
  ZUUIRevealController *revealController = [[ZUUIRevealController alloc]
                                            initWithFrontViewController: NC
                                            rearViewController: segmentedNavBarController];
  
  self.rootViewController        = revealController;
  self.window.rootViewController = self.rootViewController;
  self.window.backgroundColor    = [UIColor blackColor]; // [PKSettings PKBaseUIColor];

  [self updateAppearanceForTheme];

  [self.window makeKeyAndVisible];
  
  
  // since we alter the brightness, get the value now
  _brightness = [[UIScreen mainScreen] brightness];
  
  return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
  return YES;
}

/**
 *
 * Not used
 *
 */
-(void)applicationWillResignActive: (UIApplication *) application
{
  // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary
  // interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the
  // transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method
  // to pause the game.
  // and restore the brightness
  //[[UIScreen mainScreen] setBrightness: _brightness];
}

/**
 *
 * Save settings when we go to the background
 *
 */
-(void)applicationDidEnterBackground: (UIApplication *) application
{
  // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information
  // to restore your application to its current state in case it is terminated later.
  // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user
  // quits.
  
  // and restore the brightness
  //[[UIScreen mainScreen] setBrightness: _brightness];
  
  [_bibleViewController saveTopVerse];
  
  // save our settings
  [[PKSettings instance] saveSettings];
}

/**
 *
 * Not used
 *
 */
-(void)applicationWillEnterForeground: (UIApplication *) application
{
  // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on
  // entering the background.
  _brightness = [[UIScreen mainScreen] brightness];
}

/**
 *
 * Not used
 *
 */
-(void)applicationDidBecomeActive: (UIApplication *) application
{
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously
  // in the background, optionally refresh the user interface.
  //[iOSHierarchyViewer start];
  
  [_bibleViewController resignFirstResponder];
  __weak typeof(_bibleViewController) weakBVC = _bibleViewController;
  [self performBlockAsynchronouslyInForeground:^(void)
  {
    [weakBVC becomeFirstResponder];
  }];
}

/**
 *
 * Save settings when we terminate
 *
 */
-(void)applicationWillTerminate: (UIApplication *) application
{
  // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  // and restore the brightness
//  [[UIScreen mainScreen] setBrightness: _brightness];
  [[PKSettings instance] saveSettings];
}

@end
