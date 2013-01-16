//
//  PKBibleBookChapterVersesViewController.h
//  gbible
//
//  Created by Kerri Shotts on 3/16/12.
//  Copyright (c) 2012 photoKandy Studios LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PKBibleBookChapterVersesViewController : UITableViewController

@property int selectedBook;
@property int selectedChapter;

-(id)initWithBook: (int) theBook withChapter: (int) theChapter;

@end