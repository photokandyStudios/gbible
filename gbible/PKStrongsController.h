//
//  PKStrongsController.h
//  gbible
//
//  Created by Kerri Shotts on 3/16/12.
//  Copyright (c) 2012 photoKandy Studios LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLTapLabelDelegate.h"

@interface PKStrongsController : UITableViewController <UISearchBarDelegate, GLTapLabelDelegate>

    @property (strong, nonatomic) NSString * theSearchTerm;
    
    @property (strong, nonatomic) NSArray * theSearchResults;
    
    @property (strong, nonatomic) UISearchBar *theSearchBar;
    
    @property (strong, nonatomic) UIButton *clickToDismiss;
    
    @property (strong, nonatomic) UILabel *noResults;
    
    @property BOOL byKeyOnly;
    
    -(void)doSearchForTerm: (NSString *)theTerm;
    -(void)doSearchForTerm:(NSString *)theTerm byKeyOnly:(BOOL)keyOnly;
    
@end
