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

@interface PKRootViewController ()

@end

@implementation PKRootViewController

- (id)init
{
    self = [super init];
    if (self) {
        // I know this is harder to do in code than IB, but for crying out loud - i hate magic!
        
        // initialize our tab bar
        PKBibleViewController *bibleViewController = [[PKBibleViewController alloc] init];
        PKStrongsController   *strongsViewController=[[PKStrongsController alloc] init];
        PKAboutViewController *aboutViewController = [[PKAboutViewController alloc] init];
        PKSettingsController  *settingsViewController=[[PKSettingsController alloc] initWithStyle:UITableViewStyleGrouped];

        // Titles
        bibleViewController.title = @"Read Bible";
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
        // navigation controllers
        UINavigationController *navBibleController = [[UINavigationController alloc] initWithRootViewController:bibleViewController ];
        UINavigationController *navStrongsController = [[UINavigationController alloc] initWithRootViewController:strongsViewController ];
        UINavigationController *navAboutController = [[UINavigationController alloc] initWithRootViewController:aboutViewController ];
        UINavigationController *navSettingsController = [[UINavigationController alloc] initWithRootViewController:settingsViewController ];
        // add them to our view
        [self setViewControllers:[NSArray arrayWithObjects:navBibleController, navStrongsController,
                                                           navAboutController, navSettingsController, nil]];
        
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
