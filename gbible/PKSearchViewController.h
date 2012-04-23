//
//  PKSearchViewController.h
//  gbible
//
//  Created by Kerri Shotts on 4/2/12.
//  Copyright (c) 2012 photoKandy Studios LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PKSearchViewController : UITableViewController <UISearchBarDelegate>

    @property (strong, nonatomic) NSString * theSearchTerm;
    @property (strong, nonatomic) NSArray * theSearchResults;
    @property (strong, nonatomic) UISearchBar *theSearchBar;
    @property (strong, nonatomic) UIButton *clickToDismiss;
    @property (strong, nonatomic) UILabel *noResults;
    -(void)doSearchForTerm: (NSString *)theTerm;
    -(void)doSearchForTerm: (NSString *)theTerm requireParsings: (BOOL) parsings;

@end
