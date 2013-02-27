//
//  PKRootViewController.m
//  gbible
//
//  Created by Kerri Shotts on 3/16/12.
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
#import "PKRootViewController.h"
#import "PKBibleViewController.h"
#import "PKAboutViewController.h"
#import "PKSettingsController.h"
#import "PKStrongsController.h"
#import "PKSearchViewController.h"
#import "PKSettings.h"
#import "TestFlight.h"

#import <QuartzCore/QuartzCore.h>

@interface PKRootViewController ()

@end

@implementation PKRootViewController
@synthesize topShadow;
@synthesize bottomShadow;
@synthesize aViewHasFullScreen;
@synthesize ourIndicator;
/**
 *
 * Initialize our main controller. We create a tab bar and include each of our main views in it.
 *
 */
-(id)init
{
  self = [super init];
  
  if (self)
  {
    // I know this is harder to do in code than IB, but for crying out loud - i hate magic!
    aViewHasFullScreen = NO;
    // initialize our tab bar
    PKBibleViewController *bibleViewController    = [[PKBibleViewController alloc] init];
    PKSearchViewController *searchViewController  = [[PKSearchViewController alloc] init];
    PKStrongsController   *strongsViewController  = [[PKStrongsController alloc] init];
    PKAboutViewController *aboutViewController    = [[PKAboutViewController alloc] init];
    PKSettingsController  *settingsViewController = [[PKSettingsController alloc] initWithStyle: UITableViewStyleGrouped];
    
    // Titles
    bibleViewController.title         =   __T(@"Read Bible");
    searchViewController.title        =  __T(@"Search");
    strongsViewController.title       = __T(@"Strong's");
    aboutViewController.title         =   __T(@"About");
    settingsViewController.title      = __T(@"Settings");
    
    // icons
    bibleViewController.tabBarItem    = [[UITabBarItem alloc]
                                         initWithTitle: __T(@"Read Bible") image: [UIImage imageNamed: @"Home.png"] tag: 1];
    strongsViewController.tabBarItem  = [[UITabBarItem alloc]
                                         initWithTitle: __T(@"Strong's")
                                         image: [UIImage imageNamed: @"Magic.png"] tag: 2];
    aboutViewController.tabBarItem    = [[UITabBarItem alloc]
                                         initWithTitle: __T(@"About") image: [UIImage imageNamed: @"Info.png"] tag: 3];
    settingsViewController.tabBarItem = [[UITabBarItem alloc]
                                         initWithTitle: __T(@"Settings")
                                         image: [UIImage imageNamed: @"Gear.png"] tag: 4];
    searchViewController.tabBarItem   = [[UITabBarItem alloc]
                                         initWithTabBarSystemItem: UITabBarSystemItemSearch tag: 5];
    
    if ([bibleViewController.tabBarItem respondsToSelector: @selector(setTitleTextAttributes:forState:)])
    {
      [bibleViewController.tabBarItem setTitleTextAttributes:
       [[NSDictionary alloc] initWithObjectsAndKeys:
        [UIColor whiteColor], UITextAttributeTextColor, nil]
                                                    forState: UIControlStateNormal];
      [strongsViewController.tabBarItem setTitleTextAttributes:
       [[NSDictionary alloc] initWithObjectsAndKeys:
        [UIColor whiteColor], UITextAttributeTextColor, nil]
                                                      forState: UIControlStateNormal];
      [aboutViewController.tabBarItem setTitleTextAttributes:
       [[NSDictionary alloc] initWithObjectsAndKeys:
        [UIColor whiteColor], UITextAttributeTextColor, nil]
                                                    forState: UIControlStateNormal];
      [settingsViewController.tabBarItem setTitleTextAttributes:
       [[NSDictionary alloc] initWithObjectsAndKeys:
        [UIColor whiteColor], UITextAttributeTextColor, nil]
                                                       forState: UIControlStateNormal];
      [searchViewController.tabBarItem setTitleTextAttributes:
       [[NSDictionary alloc] initWithObjectsAndKeys:
        [UIColor whiteColor], UITextAttributeTextColor, nil]
                                                     forState: UIControlStateNormal];
    }
    // navigation controllers
    UINavigationController *navBibleController    =
    [[UINavigationController alloc] initWithRootViewController: bibleViewController];
    UINavigationController *navStrongsController  =
    [[UINavigationController alloc] initWithRootViewController: strongsViewController];
    UINavigationController *navAboutController    =
    [[UINavigationController alloc] initWithRootViewController: aboutViewController];
    UINavigationController *navSettingsController =
    [[UINavigationController alloc] initWithRootViewController: settingsViewController];
    UINavigationController *navSearchController   =
    [[UINavigationController alloc] initWithRootViewController: searchViewController];
    
    navBibleController.navigationBar.barStyle    = UIBarStyleBlack;
    navStrongsController.navigationBar.barStyle  = UIBarStyleBlack;
    navAboutController.navigationBar.barStyle    = UIBarStyleBlack;
    navSettingsController.navigationBar.barStyle = UIBarStyleBlack;
    navSearchController.navigationBar.barStyle   = UIBarStyleBlack;
    // set up our nav image
    UINavigationBar *navBar = [navBibleController navigationBar];
    
    if ([navBar respondsToSelector: @selector(setBackgroundImage:forBarMetrics:)])
    {
      [navBar setTitleTextAttributes: [[NSDictionary alloc] initWithObjectsAndKeys: [UIColor blackColor],
                                       UITextAttributeTextShadowColor,
                                       [UIColor whiteColor], UITextAttributeTextColor, nil]];
      
      navBar = [navSearchController navigationBar];
      [navBar setTitleTextAttributes: [[NSDictionary alloc] initWithObjectsAndKeys: [UIColor blackColor],
                                       UITextAttributeTextShadowColor,
                                       [UIColor whiteColor], UITextAttributeTextColor, nil]];
      
      navBar = [navStrongsController navigationBar];
      [navBar setTitleTextAttributes: [[NSDictionary alloc] initWithObjectsAndKeys: [UIColor blackColor],
                                       UITextAttributeTextShadowColor,
                                       [UIColor whiteColor], UITextAttributeTextColor, nil]];
      
      navBar = [navAboutController navigationBar];
      [navBar setTitleTextAttributes: [[NSDictionary alloc] initWithObjectsAndKeys: [UIColor blackColor],
                                       UITextAttributeTextShadowColor,
                                       [UIColor whiteColor], UITextAttributeTextColor, nil]];
      
      navBar = [navSettingsController navigationBar];
      [navBar setTitleTextAttributes: [[NSDictionary alloc] initWithObjectsAndKeys: [UIColor blackColor],
                                       UITextAttributeTextShadowColor,
                                       [UIColor whiteColor], UITextAttributeTextColor, nil]];
    }
    
    // add them to our view
    [self setViewControllers: [NSArray arrayWithObjects: navBibleController, navSearchController, navStrongsController,
                               navAboutController, navSettingsController, nil]];
    UITabBar *myTabBar = [self tabBar];
    
    if ([myTabBar respondsToSelector: @selector(setBackgroundImage:)])
    {
      [myTabBar setSelectionIndicatorImage: [[UIImage alloc] init]];
    }
    self.delegate = self;
  }
  [TestFlight passCheckpoint: @"ROOTVIEW"];
  return self;
}

-(void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  // add our shadows
  topShadow                     = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"topShadow.png"]];
  bottomShadow                  = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"bottomShadow.png"]];
  
  topShadow.frame               = CGRectMake(0, 44, self.view.bounds.size.width, 15);
  bottomShadow.frame            = CGRectMake(0, self.view.bounds.size.height - 44 - 20, self.view.bounds.size.width, 15);
  
  topShadow.contentMode         = UIViewContentModeScaleToFill;
  bottomShadow.contentMode      = UIViewContentModeScaleToFill;
  
  topShadow.autoresizingMask    = UIViewAutoresizingFlexibleWidth;
  bottomShadow.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
  
  topShadow.layer.opacity       = 0.0f;
  bottomShadow.layer.opacity    = 0.0f;
  
  [self.view addSubview: topShadow];
  [self.view addSubview: bottomShadow];
  
  self.view.backgroundColor = [PKSettings PKBaseUIColor];
  
  self.selectedIndex        = 0;
}

-(void) viewDidAppear: (BOOL) animated
{
  //self.selectedIndex = 0;
}

-(void) showTopShadowWithOpacity: (CGFloat) opacity;
{
  topShadow.layer.opacity = opacity;
}
-(void) showBottomShadowWithOpacity: (CGFloat) opacity;
{
  bottomShadow.layer.opacity = opacity;
}

-(void)viewDidUnload
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  topShadow    = nil;
  bottomShadow = nil;
}

-(void)calcShadowPosition: (UIInterfaceOrientation) toInterfaceOrientation
{
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
  {
    // for iphone we have 44 and 32(?) for the navbar height
    if (toInterfaceOrientation == UIInterfaceOrientationPortrait)
    {
      topShadow.frame = CGRectMake(0, 44, self.view.bounds.size.width, 15);
    }
    else
    {
      topShadow.frame = CGRectMake(0, 32, self.view.bounds.size.width, 15);
    }
  }
  else
  {
    topShadow.frame = CGRectMake(0, 44, self.view.bounds.size.width, 15);
  }
  
  if (aViewHasFullScreen)
  {
    topShadow.frame = CGRectMake(0, 0, self.view.bounds.size.width, 15);
  }
}

-(void)willRotateToInterfaceOrientation: (UIInterfaceOrientation) toInterfaceOrientation duration: (NSTimeInterval) duration
{
  [self calcShadowPosition: toInterfaceOrientation];
}

-(BOOL)shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) interfaceOrientation
{
  return YES;
}

-(void) showWaitingIndicator
{
  if (ourIndicator != nil)
  {
    [ourIndicator removeFromSuperview];
  }
  ourIndicator = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"Wait.png"]];
  
  CGPoint centerPoint = self.view.center;
  CGRect theRect      = CGRectMake(centerPoint.x - 96, centerPoint.y - 96, 192, 192);
  [ourIndicator setFrame: theRect];
  ourIndicator.alpha = 0.25f;
  
  [self.view addSubview: ourIndicator];
  
  [self performSelector: @selector(hideIndicator) withObject: self afterDelay: 0.2f];
}

-(void) showRightSwipeIndicator
{
  if (ourIndicator != nil)
  {
    [ourIndicator removeFromSuperview];
  }
  ourIndicator       = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"Swipe.png"]];
  
  CGPoint centerPoint = self.view.center;
  centerPoint.x      = 0;
  CGRect theRect      = CGRectMake(centerPoint.x - 96, centerPoint.y - 96, 192, 192);
  [ourIndicator setFrame: theRect];
  ourIndicator.alpha = 0.25f;
  
  [self.view addSubview: ourIndicator];
  
  [self performSelector: @selector(hideIndicator) withObject: self afterDelay: 0.2f];
}

-(void) showLeftSwipeIndicator
{
  if (ourIndicator != nil)
  {
    [ourIndicator removeFromSuperview];
  }
  ourIndicator       = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"Swipe.png"]];
  
  CGPoint centerPoint = self.view.center;
  centerPoint.x      = self.view.bounds.size.width;
  CGRect theRect      = CGRectMake(centerPoint.x - 96, centerPoint.y - 96, 192, 192);
  [ourIndicator setFrame: theRect];
  ourIndicator.alpha = 0.25f;
  
  [self.view addSubview: ourIndicator];
  
  [self performSelector: @selector(hideIndicator) withObject: self afterDelay: 0.2f];
}

-(void) hideIndicator
{
  [UIView animateWithDuration: 0.4f animations:
   ^{
     ourIndicator.alpha = 0.0;
   }
                   completion:^(BOOL finished)
   {
     [ourIndicator removeFromSuperview];
     ourIndicator = nil;
   }
   ];
}

@end