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
#import "TestFlight.h"
#import "NSString+FontAwesome.h"
#import "PSTCollectionView.h"
#import "iRate.h"
#import "PKSearchViewController.h"
#import "PKStrongsController.h"
#import <Parse/Parse.h>
#import "UIFont+Utility.h"
#import "AccessibleSegmentedControl.h"
#import "Helpshift.h"
#import "APIKeys.h"

#import <QuartzCore/QuartzCore.h>

@implementation PKAppDelegate

/*
@synthesize window = _window;
@synthesize database;
@synthesize mySettings;
@synthesize rootViewController;
@synthesize bibleViewController;
@synthesize bibleBooksViewController;
@synthesize notesViewController;
@synthesize historyViewController;
@synthesize highlightsViewController;
@synthesize segmentController;
@synthesize segmentedControl;
@synthesize searchViewController;
@synthesize strongsViewController;
@synthesize brightness;
@synthesize splash;
*/

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
  NSLog (@"%@", [theView class]);
  
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
  [b setTintColor: [PKSettings PKPageColor]];
  [b setTitleTextAttributes:@{
    UITextAttributeTextColor: [PKSettings PKBarButtonTextColor],
    UITextAttributeTextShadowColor: [UIColor clearColor],
    UITextAttributeTextShadowOffset: [NSValue valueWithCGSize:  CGSizeMake(0,-1)],
    UITextAttributeFont: [UIFont fontWithName:PKSettings.boldInterfaceFont size:13]
    }
                   forState:UIControlStateNormal];

}

+(void) applyThemeToUINavigationBar: (UINavigationBar *)nba
{
  nba.barStyle = UIBarStyleBlackOpaque;
  nba.tintColor = [PKSettings PKNavigationColor];
  [nba setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
  
  nba.titleTextAttributes = @{ UITextAttributeTextColor: [PKSettings PKNavigationTextColor],
                               UITextAttributeTextShadowColor: [UIColor blackColor],
    UITextAttributeFont: [UIFont fontWithName:PKSettings.boldInterfaceFont size:20]
                               };
}

+(void) applyThemeToUISearchBar: (UISearchBar *)sba
{
  sba.tintColor = [PKSettings PKNavigationColor];
}

+(void) applyThemeToUISegmentedControl: (UISegmentedControl *)sca
{
  sca.tintColor = [PKSettings PKNavigationColor];
}

-(void)updateAppearanceForTheme
{
  // update our proxies
  if ([[UIBarButtonItem class] respondsToSelector: @selector(appearance)])
    [PKAppDelegate applyThemeToUIBarButtonItem:[UIBarButtonItem appearance]];
  if ([[UINavigationBar class] respondsToSelector: @selector(appearance)])
    [PKAppDelegate applyThemeToUINavigationBar:[UINavigationBar appearance]];
  if ([[UISearchBar class] respondsToSelector: @selector(appearance)])
    [PKAppDelegate applyThemeToUISearchBar:[UISearchBar appearance]];
  if ([[UISegmentedControl class] respondsToSelector: @selector(appearance)])
    [PKAppDelegate applyThemeToUISegmentedControl:[UISegmentedControl appearance]];
  
  // and then update everything we possibly can that might be on screen
  if ([[UIBarButtonItem class] respondsToSelector: @selector(appearance)])
  {
    
    [PKAppDelegate applyThemeToUISegmentedControl:_segmentedControl];
    
    NSMutableArray *va = [[NSMutableArray alloc] initWithArray:
                          @[ _bibleBooksViewController, _notesViewController,
                          _highlightsViewController, _historyViewController,
                          _searchViewController, _strongsViewController ] ];
    if (_bibleBooksViewController.navigationController.visibleViewController)
      [va addObject:_bibleBooksViewController.navigationController.visibleViewController];
    if (_bibleViewController.navigationController.visibleViewController)
      [va addObject:_bibleViewController.navigationController.visibleViewController];
    for ( UIViewController * nb in va )
    {
      UINavigationItem * ni = nb.navigationItem;
      if (ni.leftBarButtonItems)
      {
        for ( UIBarButtonItem* b in ni.leftBarButtonItems )
        {
          [PKAppDelegate applyThemeToUIBarButtonItem:b];
        }
      }
      if (ni.rightBarButtonItems)
      {
        for ( UIBarButtonItem* b in ni.rightBarButtonItems )
        {
          [PKAppDelegate applyThemeToUIBarButtonItem:b];
        }
      }
      if (ni.leftBarButtonItem)
        [PKAppDelegate applyThemeToUIBarButtonItem:ni.leftBarButtonItem];
      if (ni.rightBarButtonItem)
        [PKAppDelegate applyThemeToUIBarButtonItem:ni.rightBarButtonItem];
      if (ni.backBarButtonItem)
        [PKAppDelegate applyThemeToUIBarButtonItem:ni.backBarButtonItem];
      if (nb.presentingViewController.navigationItem.backBarButtonItem)
        [PKAppDelegate applyThemeToUIBarButtonItem:nb.presentingViewController.navigationItem.backBarButtonItem];
      //if (nb != bibleViewController)
      //{
      [PKAppDelegate applyThemeToUINavigationBar:nb.navigationController.navigationBar];
      if ([nb respondsToSelector:@selector(updateAppearanceForTheme)])
      {
        [nb performSelector:@selector(updateAppearanceForTheme)];
      }
      //}
    }
  }
  
}

/**
 *
 * Do all the application startup. We open our databases, load our settings, and create all
 * our views.
 */
-(BOOL)application: (UIApplication *) application didFinishLaunchingWithOptions: (NSDictionary *) launchOptions
{
  _instance = self;
  
  // set up parse
  [Parse setApplicationId:PARSE_APPLICATION_ID
                clientKey:PARSE_CLIENT_KEY];
  
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert |
                                                                          UIRemoteNotificationTypeBadge];
  
  //open our databases...
  _database   = [PKDatabase instance];
  
  //and get our settings
  _mySettings = [PKSettings instance];
  [_mySettings reloadSettings];
  
  if ([_mySettings usageStats] == YES)
  {
    [TestFlight takeOff: TESTFLIGHT_API_KEY];
    [Helpshift installForAppID:HELPSHIFT_APP_ID domainName:HELPSHIFT_DOMAIN apiKey:HELPSHIFT_API_KEY];
  
  }
  
  self.window = [[UIWindow alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
  // define our "top-level" controller -- this is the one above the navigation panel
  _bibleViewController = [[PKBibleViewController alloc] initWithStyle: UITableViewStylePlain];
  // define an array that houses all our navigation panels.
  
  _bibleBooksViewController = [[PKBibleBooksController alloc] initWithCollectionViewLayout:[PSUICollectionViewFlowLayout new]];
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
  /*
   if ([segmentedNavBarController.navigationBar respondsToSelector: @selector(setBackgroundImage:forBarMetrics:)])
   {
   [segmentedNavBarController.navigationBar setTitleTextAttributes: [[NSDictionary alloc] initWithObjectsAndKeys: [UIColor
   blackColor],
   UITextAttributeTextShadowColor,
   [UIColor whiteColor], UITextAttributeTextColor,
   [UIFont fontWithName:kFontAwesomeFamilyName size:20], UITextAttributeFont,
   nil]];
   }
   */
  [self updateAppearanceForTheme];
  
  
  self.segmentController = [[SegmentsController alloc]
                            initWithNavigationController: segmentedNavBarController viewControllers: navViewControllers];
  
  //  self.segmentedControl  = [[UISegmentedControl alloc]
  //                            initWithItems: @[ __T(@"Goto"), __T(@"Highlights"), __T(@"Notes"),
  //                                            __T(@"History"), __T(@"Search"), __T(@"Strong's")]];
  self.segmentedControl  = [[AccessibleSegmentedControl alloc]
                            initWithItems: @[ [NSString fontAwesomeIconStringForIconIdentifier:@"icon-book"],
                            [NSString fontAwesomeIconStringForIconIdentifier:@"icon-star"],
                            [NSString fontAwesomeIconStringForIconIdentifier:@"icon-comment"],
                            [NSString fontAwesomeIconStringForIconIdentifier:@"icon-magic"],
                            [NSString fontAwesomeIconStringForIconIdentifier:@"icon-search"],
                            [NSString fontAwesomeIconStringForIconIdentifier:@"icon-time"]
                            ]];
  self.segmentedControl.segmentAccessibilityLabels = @[ __T(@"Goto"), __T(@"Highlights"), __T(@"Notes"),
                                                        __T(@"Strong's"), __T(@"Search"), __T(@"History")];
  [self.segmentedControl setTitleTextAttributes:@{ UITextAttributeFont: [UIFont fontWithName:kFontAwesomeFamilyName size:20] } forState:UIControlStateNormal];
  self.segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
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
  UINavigationController *NC = [[UINavigationController alloc] initWithRootViewController:_bibleViewController];
  ZUUIRevealController *revealController = [[ZUUIRevealController alloc]
                                            initWithFrontViewController: NC
                                            rearViewController: segmentedNavBarController];
  
  self.rootViewController        = revealController;
  self.window.rootViewController = self.rootViewController;
  self.window.backgroundColor    = [UIColor blackColor]; // [PKSettings PKBaseUIColor];
  
  // Add imageView overlay with fade out and zoom in animation
  // inspired by https://gist.github.com/1026439 and https://gist.github.com/3798781
  
  self.splash = [[UIImageView alloc] initWithFrame: self.window.frame];
  
  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
  { switch ([[UIApplication sharedApplication] statusBarOrientation])
    {
      case UIInterfaceOrientationLandscapeLeft:
      case UIInterfaceOrientationLandscapeRight:
        
        if ([UIScreen mainScreen].scale == 2)
        {
          _splash.image = [UIImage imageNamed: @"Default-Landscape@2x~ipad.png"];
        }
        else
        {
          _splash.image = [UIImage imageNamed: @"Default-Landscape~ipad.png"];
        }
        [_splash setFrame: CGRectMake(0, 0, 1024, 748)];
        break;
        
      case UIInterfaceOrientationPortrait:
      case UIInterfaceOrientationPortraitUpsideDown:
        
        if ([UIScreen mainScreen].scale == 2)
        {
          _splash.image = [UIImage imageNamed: @"Default-Portrait@2x~ipad.png"];
        }
        else
        {
          _splash.image = [UIImage imageNamed: @"Default-Portrait~ipad.png"];
        }
        [_splash setFrame: CGRectMake(0, 0, 768, 1004)];
        break;
    }
  }
  else
  {
    // we're an iPhone or iPod touch. No rotation for you.
    if ([UIScreen mainScreen].scale == 2)
    {
      // are we a 3.5in? or a 4?
      if ([UIScreen mainScreen].bounds.size.height == 568.0f)
      {
        // 4 inch iPhone 5
        _splash.image = [UIImage imageNamed: @"Default-568h@2x.png"];
        [_splash setFrame: CGRectMake(0, 0, 320, 548)];
      }
      else
      {
        _splash.image = [UIImage imageNamed: @"Default@2x.png"];
        [_splash setFrame: CGRectMake(0, 0, 320, 460)];
      }
    }
    else
    {
      _splash.image = [UIImage imageNamed: @"Default.png"];
      [_splash setFrame: CGRectMake(0, 0, 320, 460)];
    }
  }
  
  [self.window.rootViewController.view addSubview: _splash];
  [self.window.rootViewController.view bringSubviewToFront: _splash];
  
  PKWaitDelay(2, {
    [UIView transitionWithView: self.window
                      duration: 1.00f
                       options: UIViewAnimationOptionCurveEaseInOut
                    animations:^(void) {
                      _splash.alpha = 0.0f;
                    }
                    completion:^(BOOL finished) {
                      [_splash removeFromSuperview];
                    }
     ];
  }
              );
  
  [self.window makeKeyAndVisible];
  
  [TestFlight passCheckpoint: @"APPLICATION_START"];
  
  // since we alter the brightness, get the value now
  _brightness = [[UIScreen mainScreen] brightness];

  // check for notifications; and handle if necessary
  NSDictionary *notificationPayload = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
  if (notificationPayload)
  {
    if ([[notificationPayload objectForKey:@"origin"] isEqualToString:@"helpshift"]) {
      [[Helpshift sharedInstance] handleNotification:notificationPayload withController:self.rootViewController];
    }
    else
    {
      // should be some other notification, like a new Bible :-)
      UIAlertView *anAlert = [[UIAlertView alloc] initWithTitle:__T(@"Notice") message:[notificationPayload objectForKey:@"alert"] delegate:nil cancelButtonTitle:__T(@"OK") otherButtonTitles: nil];
      [anAlert show];
    }
  }
  
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
  [[UIScreen mainScreen] setBrightness: _brightness];
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
  [[UIScreen mainScreen] setBrightness: _brightness];
  
  // attempt to fix issue #36
  NSArray *indexPaths        = [_bibleViewController.tableView indexPathsForVisibleRows];
  
  if ([indexPaths count] > 0)
  {
    [PKSettings instance].topVerse = [[indexPaths objectAtIndex: 0] row] + 1;
  }
  
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
  PKWaitDelay(0.5,
              [_bibleViewController becomeFirstResponder];
              );
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
  [[UIScreen mainScreen] setBrightness: _brightness];
  [[PKSettings instance] saveSettings];
}

/**
 *
 * Receive 3rd party notifications
 *
 */
-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
  [[Helpshift sharedInstance] registerDeviceToken:deviceToken];

 // Store the deviceToken in the current Installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
 // and register for a channel
  [currentInstallation addUniqueObject:@"BibleNotifications" forKey:@"channels"];
  [currentInstallation saveInBackground];
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
  if ([[userInfo objectForKey:@"origin"] isEqualToString:@"helpshift"]) {
    [[Helpshift sharedInstance] handleNotification:userInfo withController:self.rootViewController];
  }
  else
  {
    // should be some other notification, like a new Bible :-)
    UIAlertView *anAlert = [[UIAlertView alloc] initWithTitle:__T(@"Notice") message:[userInfo objectForKey:@"alert"] delegate:nil cancelButtonTitle:__T(@"OK") otherButtonTitles: nil];
    [anAlert show];
  }
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
  NSLog( @"Failed to register for remote notifications: %@", [error localizedDescription]);
}
@end