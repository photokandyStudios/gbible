//
//  PKAboutViewController.m
//  gbible
//
//  Created by Kerri Shotts on 3/16/12.
//  Copyright (c) 2012 photoKandy Studios LLC. All rights reserved.
//

#import "PKAboutViewController.h"
#import "ZUUIRevealController.h"
#import "PKRootViewController.h"
#import "PKSettings.h"

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
  
  UIBarButtonItem *changeReference = [[UIBarButtonItem alloc]
                                      initWithImage: [UIImage imageNamed: @"Listb.png"]
                                      style: UIBarButtonItemStylePlain
                                      target: self.parentViewController.parentViewController.parentViewController
                                      action: @selector(revealToggle:)];
  
  changeReference.accessibilityLabel    = __T(@"Go to passage");
  self.navigationItem.leftBarButtonItem = changeReference;
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

-(void)calculateShadows
{
  if ([self.aboutWebView respondsToSelector: @selector(scrollView)])
  {
    CGFloat topOpacity       = 0.0f;
    CGFloat theContentOffset = (self.aboutWebView.scrollView.contentOffset.y);
    
    if (theContentOffset > 15)
    {
      theContentOffset = 15;
    }
    topOpacity = (theContentOffset / 15) * 0.5;
    
    [( (PKRootViewController *)self.parentViewController.parentViewController ) showTopShadowWithOpacity: topOpacity];
    
    CGFloat bottomOpacity = 0.0f;
    
    theContentOffset = self.aboutWebView.scrollView.contentSize.height - self.aboutWebView.scrollView.contentOffset.y -
    self.aboutWebView.scrollView.bounds.size.height;
    
    if (theContentOffset > 15)
    {
      theContentOffset = 15;
    }
    bottomOpacity = (theContentOffset / 15) * 0.5;
    
    [( (PKRootViewController *)self.parentViewController.parentViewController ) showBottomShadowWithOpacity: bottomOpacity];
  }
  else
  {
    [( (PKRootViewController *)self.parentViewController.parentViewController ) showTopShadowWithOpacity: 0.5];
    [( (PKRootViewController *)self.parentViewController.parentViewController ) showBottomShadowWithOpacity: 0.5];
  }
}

-(void) viewDidAppear: (BOOL) animated
{
  [super viewDidAppear: animated];
  [self calculateShadows];
}

-(void) didRotateFromInterfaceOrientation: (UIInterfaceOrientation) fromInterfaceOrientation
{
  [super didRotateFromInterfaceOrientation: fromInterfaceOrientation];
  [self calculateShadows];
}

-(void) scrollViewDidScroll: (UIScrollView *) scrollView
{
  [self calculateShadows];
}

-(void) didReceiveRightSwipe: (UISwipeGestureRecognizer *) gestureRecognizer
{
  CGPoint p = [gestureRecognizer locationInView: self.aboutWebView];
  
  if (p.x < 75)
  {
    // show the sidebar, if not visible
    ZUUIRevealController *rc = (ZUUIRevealController *)self.parentViewController.parentViewController.parentViewController;
    
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
  ZUUIRevealController *rc = (ZUUIRevealController *)self.parentViewController.parentViewController.parentViewController;
  
  if ([rc currentFrontViewPosition] == FrontViewPositionRight)
  {
    [rc revealToggle: nil];
    return;
  }
}

@end