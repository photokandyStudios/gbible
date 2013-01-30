//
//  PKBibleListViewController.h
//  gbible
//
//  Created by Kerri Shotts on 1/29/13.
//  Copyright (c) 2013 photoKandy Studios LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PKBibleListViewController : UITableViewController

@property (strong, nonatomic) NSArray *builtInBibleIDs;
@property (strong, nonatomic) NSArray *builtInBibleAbbreviations;
@property (strong, nonatomic) NSArray *builtInBibleTitles;

@property (strong, nonatomic) NSArray *installedBibleIDs;
@property (strong, nonatomic) NSArray *installedBibleAbbreviations;
@property (strong, nonatomic) NSArray *installedBibleTitles;

@property (strong, nonatomic) NSArray *availableBibleIDs;
@property (strong, nonatomic) NSArray *availableBibleAbbreviations;
@property (strong, nonatomic) NSArray *availableBibleTitles;


@end
