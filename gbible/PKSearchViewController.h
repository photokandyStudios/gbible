//
//  PKSearchViewController.h
//  gbible
//
//  Created by Kerri Shotts on 4/2/12.
//  Copyright (c) 2012 photoKandy Studios LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PKBibleReferenceDelegate.h"

@interface PKSearchViewController : UITableViewController <UISearchBarDelegate>

@property (strong, nonatomic) NSString *theSearchTerm;
@property (strong, nonatomic) NSArray *theSearchResults;
@property (strong, nonatomic) UISearchBar *theSearchBar;
@property (strong, nonatomic) UIButton *clickToDismiss;
@property (strong, nonatomic) UILabel *noResults;
@property int fontSize;
@property (strong, nonatomic) UIFont *leftFont;
@property (strong, nonatomic) UIFont *rightFont;

@property (nonatomic, weak) id <PKBibleReferenceDelegate> delegate;
@property BOOL notifyWithCopyOfVerse;

-(void)doSearchForTerm: (NSString *) theTerm;
-(void)doSearchForTerm: (NSString *) theTerm requireParsings: (BOOL) parsings;

@end