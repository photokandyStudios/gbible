//
//  PKAboutViewController.m
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
#import "PKAboutViewController.h"
#import "ZUUIRevealController.h"
#import "PKRootViewController.h"
#import "PKSettings.h"
#import "PKAppDelegate.h"

@interface PKAboutViewController ()

@end

@implementation PKAboutViewController

@synthesize aboutWebView;

-(id)init
{
  self = [super init];
  
  if (self)
  {
    // Custom initialization
    [self.navigationItem setTitle: __T(@"About")];
  }
  return self;
}

-(void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  [TestFlight passCheckpoint: @"ABOUT"];
  CGRect theRect = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
  self.aboutWebView = [[UIWebView alloc] initWithFrame: theRect];
  [self.view addSubview: self.aboutWebView];
  
  // LOCALIZATION SUPPORT FOR ABOUT
  // First, obtain the language
  // Second, try to load "about-language.html"; for English, this would be about-en.html.
  // Third, if that particular file doesn't exist, fall back to about.html
  NSURL *theURL;
  NSString *language = [[NSLocale preferredLanguages] objectAtIndex: 0];
  NSString *path     = [[NSBundle mainBundle] pathForResource: [NSString stringWithFormat: @"about-%@", language] ofType: @"html"];
  
  if (path)
  {
    theURL = [NSURL fileURLWithPath: path isDirectory: NO];
  }
  else
  {
    theURL = [NSURL fileURLWithPath: [[NSBundle mainBundle] pathForResource: @"about" ofType: @"html"] isDirectory: NO];
  }
  [self.aboutWebView loadRequest: [NSURLRequest requestWithURL: theURL]];
  
  self.aboutWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  
  if ([self.aboutWebView respondsToSelector: @selector(scrollView)])
  {
    self.aboutWebView.scrollView.delegate = self;
  }
  self.view.autoresizesSubviews = YES;
  
  UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc]
                                          initWithTarget: self action: @selector(didReceiveRightSwipe:)];
  UISwipeGestureRecognizer *swipeLeft  = [[UISwipeGestureRecognizer alloc]
                                          initWithTarget: self action: @selector(didReceiveLeftSwipe:)];
  swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
  swipeLeft.direction  = UISwipeGestureRecognizerDirectionLeft;
  [swipeRight setNumberOfTouchesRequired: 1];
  [swipeLeft setNumberOfTouchesRequired: 1];
  [self.aboutWebView addGestureRecognizer: swipeRight];
  [self.aboutWebView addGestureRecognizer: swipeLeft];
  
}

-(void)viewDidUnload
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  aboutWebView = nil;
}

-(BOOL)shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) interfaceOrientation
{
  return YES;
}


-(void) viewDidAppear: (BOOL) animated
{
  [super viewDidAppear: animated];
}

-(void) didRotateFromInterfaceOrientation: (UIInterfaceOrientation) fromInterfaceOrientation
{
  [super didRotateFromInterfaceOrientation: fromInterfaceOrientation];
}


-(void) didReceiveRightSwipe: (UISwipeGestureRecognizer *) gestureRecognizer
{
  CGPoint p = [gestureRecognizer locationInView: self.aboutWebView];
  
  if (p.x < 75)
  {
    // show the sidebar, if not visible
    ZUUIRevealController *rc = [PKAppDelegate sharedInstance].rootViewController;
    
    if ([rc currentFrontViewPosition] == FrontViewPositionLeft)
    {
      [rc revealToggle: nil];
      return;
    }
  }
}

-(void) didReceiveLeftSwipe: (UISwipeGestureRecognizer *) gestureRecognizer
{
  // hide the sidebar, if visible
  ZUUIRevealController *rc = [PKAppDelegate sharedInstance].rootViewController;
  
  if ([rc currentFrontViewPosition] == FrontViewPositionRight)
  {
    [rc revealToggle: nil];
    return;
  }
}

@end