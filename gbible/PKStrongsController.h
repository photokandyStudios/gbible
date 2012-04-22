//
//  PKStrongsController.h
//  gbible
//
//  Created by Kerri Shotts on 3/16/12.
//  Copyright (c) 2012 photoKandy Studios LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PKStrongsController : UITableViewController <UISearchBarDelegate>

    @property (strong, nonatomic) NSString * theSearchTerm;
    
    @property (strong, nonatomic) NSArray * theSearchResults;
    
    @property (strong, nonatomic) UISearchBar *theSearchBar;
    
    @property BOOL byKeyOnly;
    
    -(void)doSearchForTerm: (NSString *)theTerm;
    -(void)doSearchForTerm:(NSString *)theTerm byKeyOnly:(BOOL)keyOnly;
    
@end
