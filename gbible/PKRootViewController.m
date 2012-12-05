//
//  PKRootViewController.m
//  gbible
//
//  Created by Kerri Shotts on 3/16/12.
//  Copyright (c) 2012 photoKandy Studios LLC. All rights reserved.
//

#import "PKRootViewController.h"
#import "PKBibleViewController.h"
#import "PKAboutViewController.h"
#import "PKSettingsController.h"
#import "PKStrongsController.h"
#import "PKSearchViewController.h"

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
- (id)init
{
    self = [super init];
    if (self) {
        // I know this is harder to do in code than IB, but for crying out loud - i hate magic!
        aViewHasFullScreen = NO;
        // initialize our tab bar
        PKBibleViewController *bibleViewController = [[PKBibleViewController alloc] init];
        PKSearchViewController *searchViewController=[[PKSearchViewController alloc] init];
        PKStrongsController   *strongsViewController=[[PKStrongsController alloc] init];
        PKAboutViewController *aboutViewController = [[PKAboutViewController alloc] init];
        PKSettingsController  *settingsViewController=[[PKSettingsController alloc] initWithStyle:UITableViewStyleGrouped];

        // Titles
        bibleViewController.title = @"Read Bible";
        searchViewController.title = @"Search";
        strongsViewController.title = @"Strong's Lookup";
        aboutViewController.title = @"About";
        settingsViewController.title = @"Settings";
        
        // icons
        bibleViewController.tabBarItem = [[UITabBarItem alloc] 
                                          initWithTitle:@"Read Bible" image:[UIImage imageNamed:@"Home.png"] tag:1];
        strongsViewController.tabBarItem = [[UITabBarItem alloc]
                                            initWithTitle:@"Strong's Lookup"
                                            image:[UIImage imageNamed:@"Magic.png"] tag:2];
        aboutViewController.tabBarItem = [[UITabBarItem alloc]
                                          initWithTitle:@"About" image:[UIImage imageNamed:@"Info.png"] tag:3];
        settingsViewController.tabBarItem = [[UITabBarItem alloc]
                                             initWithTitle:@"Settings"
                                             image:[UIImage imageNamed:@"Gear.png"] tag:4];
        searchViewController.tabBarItem = [[UITabBarItem alloc]
                                           initWithTabBarSystemItem:UITabBarSystemItemSearch tag:5];

        if ([bibleViewController.tabBarItem respondsToSelector:@selector(setTitleTextAttributes:forState:)])
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
        UINavigationController *navBibleController = [[UINavigationController alloc] initWithRootViewController:bibleViewController ];
        UINavigationController *navStrongsController = [[UINavigationController alloc] initWithRootViewController:strongsViewController ];
        UINavigationController *navAboutController = [[UINavigationController alloc] initWithRootViewController:aboutViewController ];
        UINavigationController *navSettingsController = [[UINavigationController alloc] initWithRootViewController:settingsViewController ];
        UINavigationController *navSearchController = [[UINavigationController alloc] initWithRootViewController:searchViewController ];
        
        navBibleController.navigationBar.barStyle = UIBarStyleBlack;
        navStrongsController.navigationBar.barStyle = UIBarStyleBlack;
        navAboutController.navigationBar.barStyle = UIBarStyleBlack;
        navSettingsController.navigationBar.barStyle = UIBarStyleBlack;
        navSearchController.navigationBar.barStyle = UIBarStyleBlack;
        // set up our nav image
        UINavigationBar *navBar = [navBibleController navigationBar];
        if ([navBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)])
        {
            //[navBar setBackgroundImage:[UIImage imageNamed:@"BlueNavigationBar.png"] forBarMetrics:UIBarMetricsDefault];
            [navBar setTitleTextAttributes:[[NSDictionary alloc] initWithObjectsAndKeys:[UIColor blackColor], UITextAttributeTextShadowColor,
            [UIColor whiteColor], UITextAttributeTextColor, nil]];

            navBar = [navSearchController navigationBar];
            //[navBar setBackgroundImage:[UIImage imageNamed:@"BlueNavigationBar.png"] forBarMetrics:UIBarMetricsDefault];
            [navBar setTitleTextAttributes:[[NSDictionary alloc] initWithObjectsAndKeys:[UIColor blackColor], UITextAttributeTextShadowColor,
            [UIColor whiteColor], UITextAttributeTextColor, nil]];

            navBar = [navStrongsController navigationBar];
            //[navBar setBackgroundImage:[UIImage imageNamed:@"BlueNavigationBar.png"] forBarMetrics:UIBarMetricsDefault];
            [navBar setTitleTextAttributes:[[NSDictionary alloc] initWithObjectsAndKeys:[UIColor blackColor], UITextAttributeTextShadowColor,
            [UIColor whiteColor], UITextAttributeTextColor, nil]];

            navBar = [navAboutController navigationBar];
            //[navBar setBackgroundImage:[UIImage imageNamed:@"BlueNavigationBar.png"] forBarMetrics:UIBarMetricsDefault];
            [navBar setTitleTextAttributes:[[NSDictionary alloc] initWithObjectsAndKeys:[UIColor blackColor], UITextAttributeTextShadowColor,
            [UIColor whiteColor], UITextAttributeTextColor, nil]];

            navBar = [navSettingsController navigationBar];
            //[navBar setBackgroundImage:[UIImage imageNamed:@"BlueNavigationBar.png"] forBarMetrics:UIBarMetricsDefault];
            [navBar setTitleTextAttributes:[[NSDictionary alloc] initWithObjectsAndKeys:[UIColor blackColor], UITextAttributeTextShadowColor,
            [UIColor whiteColor], UITextAttributeTextColor, nil]];
        }

        // add them to our view
        [self setViewControllers:[NSArray arrayWithObjects:navBibleController, navSearchController, navStrongsController,
                                                           navAboutController, navSettingsController, nil]];
        UITabBar *myTabBar = [self tabBar];
        if ([myTabBar respondsToSelector:@selector(setBackgroundImage:)])
        {
            //[myTabBar setBackgroundImage:[UIImage imageNamed:@"BlueTabBar.png"]];
            [myTabBar setSelectionIndicatorImage:[[UIImage alloc]init]];
            //[myTabBar setSelectionIndicatorImage:[UIImage imageNamed:@"BlueTabBarSelected.png"]];
            //myTabBar.tintColor = [UIColor colorWithWhite:0.85 alpha:1.0];
        }
        self.delegate = self;
                                                                
    }
    [TestFlight passCheckpoint:@"ROOTVIEW"];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    // add our shadows
    topShadow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"topShadow.png"]];
    bottomShadow= [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bottomShadow.png"]];
    
    topShadow.frame = CGRectMake(0, 44, self.view.bounds.size.width, 15);
    bottomShadow.frame = CGRectMake(0, self.view.bounds.size.height-44-20,self.view.bounds.size.width,15);
    
    topShadow.contentMode = UIViewContentModeScaleToFill;
    bottomShadow.contentMode = UIViewContentModeScaleToFill;
    
    topShadow.autoresizingMask = UIViewAutoresizingFlexibleWidth ;
    bottomShadow.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    topShadow.layer.opacity = 0.0f;
    bottomShadow.layer.opacity = 0.0f;
    
    [self.view addSubview:topShadow];
    [self.view addSubview:bottomShadow];
    
    self.view.backgroundColor = PKBaseUIColor;
    
    self.selectedIndex = 0;

}
-(void) viewDidAppear:(BOOL)animated    
{
    self.selectedIndex = 0;
}
    -(void) showTopShadowWithOpacity: (CGFloat) opacity;
    {
        topShadow.layer.opacity = opacity;
    }
    -(void) showBottomShadowWithOpacity: (CGFloat) opacity;
    {
        bottomShadow.layer.opacity = opacity;
    }


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    topShadow = nil;
    bottomShadow = nil;
}

-(void)calcShadowPosition:(UIInterfaceOrientation)toInterfaceOrientation
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

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self calcShadowPosition:toInterfaceOrientation];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}


    -(void) showWaitingIndicator
    {
        if (ourIndicator != nil) { [ourIndicator removeFromSuperview]; }
        ourIndicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Wait.png"]];
        
        CGPoint centerPoint = self.view.center;
        CGRect theRect = CGRectMake(centerPoint.x-96, centerPoint.y-96, 192, 192);
        [ourIndicator setFrame:theRect];
        ourIndicator.alpha = 0.25f;
        
        [self.view addSubview:ourIndicator];
        
        [self performSelector:@selector(hideIndicator) withObject:self afterDelay:0.2f];
    }
    -(void) showRightSwipeIndicator
    {
        if (ourIndicator != nil) { [ourIndicator removeFromSuperview]; }
        ourIndicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Swipe.png"]];
        
        CGPoint centerPoint = self.view.center;
        centerPoint.x = 0;
        CGRect theRect = CGRectMake(centerPoint.x-96, centerPoint.y-96, 192, 192);
        [ourIndicator setFrame:theRect];
        ourIndicator.alpha = 0.25f;
        
        [self.view addSubview:ourIndicator];
        
        [self performSelector:@selector(hideIndicator) withObject:self afterDelay:0.2f];
    }
    -(void) showLeftSwipeIndicator
    {
        if (ourIndicator != nil) { [ourIndicator removeFromSuperview]; }
        ourIndicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Swipe.png"]];
        
        CGPoint centerPoint = self.view.center;
        centerPoint.x = self.view.bounds.size.width;
        CGRect theRect = CGRectMake(centerPoint.x-96, centerPoint.y-96, 192, 192);
        [ourIndicator setFrame:theRect];
        ourIndicator.alpha = 0.25f;
        
        [self.view addSubview:ourIndicator];
        
        [self performSelector:@selector(hideIndicator) withObject:self afterDelay:0.2f];
    }
    
    -(void) hideIndicator
    {
        [UIView animateWithDuration:0.4f animations:
        ^{
            ourIndicator.alpha = 0.0;
        } 
        completion:^(BOOL finished) 
        {
            [ourIndicator removeFromSuperview];
            ourIndicator = nil;
        }];
    }


@end
