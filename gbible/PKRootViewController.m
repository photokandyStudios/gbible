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

@interface PKRootViewController ()

@end

@implementation PKRootViewController

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
                                             
        // navigation controllers
        UINavigationController *navBibleController = [[UINavigationController alloc] initWithRootViewController:bibleViewController ];
        UINavigationController *navStrongsController = [[UINavigationController alloc] initWithRootViewController:strongsViewController ];
        UINavigationController *navAboutController = [[UINavigationController alloc] initWithRootViewController:aboutViewController ];
        UINavigationController *navSettingsController = [[UINavigationController alloc] initWithRootViewController:settingsViewController ];
        UINavigationController *navSearchController = [[UINavigationController alloc] initWithRootViewController:searchViewController ];
        
        // set up our nav image
        UINavigationBar *navBar = [navBibleController navigationBar];
        [navBar setBackgroundImage:[UIImage imageNamed:@"BlueNavigationBar.png"] forBarMetrics:UIBarMetricsDefault];
        [navBar setTitleTextAttributes:[[NSDictionary alloc] initWithObjectsAndKeys:[UIColor blackColor], UITextAttributeTextShadowColor,
        [UIColor whiteColor], UITextAttributeTextColor, nil]];

        navBar = [navSearchController navigationBar];
        [navBar setBackgroundImage:[UIImage imageNamed:@"BlueNavigationBar.png"] forBarMetrics:UIBarMetricsDefault];
        [navBar setTitleTextAttributes:[[NSDictionary alloc] initWithObjectsAndKeys:[UIColor blackColor], UITextAttributeTextShadowColor,
        [UIColor whiteColor], UITextAttributeTextColor, nil]];

        navBar = [navStrongsController navigationBar];
        [navBar setBackgroundImage:[UIImage imageNamed:@"BlueNavigationBar.png"] forBarMetrics:UIBarMetricsDefault];
        [navBar setTitleTextAttributes:[[NSDictionary alloc] initWithObjectsAndKeys:[UIColor blackColor], UITextAttributeTextShadowColor,
        [UIColor whiteColor], UITextAttributeTextColor, nil]];

        navBar = [navAboutController navigationBar];
        [navBar setBackgroundImage:[UIImage imageNamed:@"BlueNavigationBar.png"] forBarMetrics:UIBarMetricsDefault];
        [navBar setTitleTextAttributes:[[NSDictionary alloc] initWithObjectsAndKeys:[UIColor blackColor], UITextAttributeTextShadowColor,
        [UIColor whiteColor], UITextAttributeTextColor, nil]];

        navBar = [navSettingsController navigationBar];
        [navBar setBackgroundImage:[UIImage imageNamed:@"BlueNavigationBar.png"] forBarMetrics:UIBarMetricsDefault];
        [navBar setTitleTextAttributes:[[NSDictionary alloc] initWithObjectsAndKeys:[UIColor blackColor], UITextAttributeTextShadowColor,
        [UIColor whiteColor], UITextAttributeTextColor, nil]];

        // add them to our view
        [self setViewControllers:[NSArray arrayWithObjects:navBibleController, navSearchController, navStrongsController,
                                                           navAboutController, navSettingsController, nil]];
        UITabBar *myTabBar = [self tabBar];
        [myTabBar setBackgroundImage:[UIImage imageNamed:@"BlueTabBar.png"]];
        [myTabBar setSelectionIndicatorImage:[[UIImage alloc]init]];
//        [myTabBar setSelectionIndicatorImage:[UIImage imageNamed:@"BlueTabBarSelected.png"]];
//        NSLog (@"Height of tab bar: %f", myTabBar.bounds.size.height);
        myTabBar.tintColor = [UIColor colorWithWhite:0.85 alpha:1.0];
        
        self.delegate = self;
                                                                
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

@end
