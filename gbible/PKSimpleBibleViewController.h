//
//  PKSimpleBibleViewController.h
//  gbible
//
//  Created by Kerri Shotts on 2/7/13.
//  Copyright (c) 2013 photoKandy Studios LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PKBibleReferenceDelegate.h"
#import "PKTableViewController.h"

@interface PKSimpleBibleViewController : PKTableViewController <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>

@property (nonatomic, weak) id <PKBibleReferenceDelegate> delegate;
@property BOOL notifyWithCopyOfVerse;

-(void)loadChapter: (int) theChapter forBook: (int) theBook;
-(void)selectVerse: (int)theVerse;
-(void)scrollToVerse: (int)theVerse;

@end
