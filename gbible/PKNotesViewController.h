//
//  PKNotesViewController.h
//  gbible
//
//  Created by Kerri Shotts on 3/16/12.
//  Copyright (c) 2012 photoKandy Studios LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PKNotesViewController : UITableViewController <UISearchBarDelegate>

@property (strong, nonatomic) NSArray *notes;
@property (strong, nonatomic) UILabel *noResults;

@property (strong, nonatomic) NSString *theSearchTerm;
@property (strong, nonatomic) UISearchBar *theSearchBar;
@property (strong, nonatomic) UIButton *clickToDismiss;


-(void)reloadNotes;

@end