//
//  PKBibleViewController.h
//  gbible
//
//  Created by Kerri Shotts on 3/16/12.
//  Copyright (c) 2012 photoKandy Studios LLC. All rights reserved.
//

// ============================ LICENSE ============================
//
// The code that is not otherwise licensed or is owned by photoKandy
// Studios LLC is hereby licensed under a CC BY-NC-SA 3.0 license.
// That is, you may copy the code and use it for non-commercial uses
// under the same license. For the entire license, see
// http://creativecommons.org/licenses/by-nc-sa/3.0/.
//
// Furthermore, you may use the code in this app for your own
// personal or educational use. However you may NOT release a
// competing app on the App Store without prior authorization and
// significant code changes. If authorization is granted, attribution
// must be kept, but you must also add in your own attribution. You
// must also use your own API keys (TestFlight, Parse, etc.) and you
// must provide your own support. As the code is released for non-
// commercial purposes, any directly competing app based on this code
// must not require payment of any form (including ads).
//
// Attribution must be visual and be of the form:
//
//   Portions of this code from Greek Interlinear Bible,
//   (C) photokandy Studios LLC and Kerri Shotts, released
//   under a CC BY-NC-SA 3.0 license.
//
// NOTE: The graphical assets are not covered under the above license.
// They are copyright their respective owners. Any third party code
// (such as that under the Third Party section) are licensed under
// their respective licenses.
//
#import <UIKit/UIKit.h>
#import "PKLayoutControllerDelegate.h"
#import "PKSearchDelegate.h"
#import "PKBibleReferenceDelegate.h"
#import "PKTableViewController.h"

//#import "FWTPopoverView.h"

@interface PKBibleViewController : PKTableViewController <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate,
                                                          UIActionSheetDelegate, PKLayoutControllerDelegate , UIKeyInput,
                                                          PKSearchDelegate, PKBibleReferenceDelegate>

-(void)displayBook: (int) theBook andChapter: (int) theChapter andVerse: (int) theVerse;

@property (strong, nonatomic) NSArray *currentGreekChapter;
@property (strong, nonatomic) NSArray *currentEnglishChapter;

@property (strong, nonatomic) NSMutableArray *formattedGreekChapter;
@property (strong, nonatomic) NSMutableArray *formattedEnglishChapter;

@property (strong, nonatomic) NSMutableArray *formattedGreekVerseHeights;
@property (strong, nonatomic) NSMutableArray *formattedEnglishVerseHeights;

@property (strong, nonatomic) NSMutableDictionary *selectedVerses;
@property (strong, nonatomic) NSMutableDictionary *highlightedVerses;

@property (strong, nonatomic) NSString *selectedWord;
@property (strong, nonatomic) NSString *selectedPassage;

@property (strong, nonatomic) NSMutableArray *cellHeights;     // RE: ISSUE #1
@property (strong, nonatomic) NSMutableArray *cells;           // RE: ISSUE #1

@property (strong, nonatomic) NSMutableArray *reusableLabels;

// UI elements
@property (strong, nonatomic) UIBarButtonItem *changeHighlight;
@property (strong, nonatomic) NSMutableArray *formattedCells;
@property (strong, nonatomic) UIMenuController *ourMenu;
@property int ourMenuState;
@property (strong, nonatomic) UIActionSheet *ourPopover;

@property (strong, nonatomic) UIButton *btnRegularScreen;

@property (strong, nonatomic) UILabel *tableTitle;

@property int theWordTag;
@property int theWordIndex;

@property BOOL fullScreen;

@property (strong, nonatomic) UITableViewCell *theCachedCell;

@property BOOL dirty;

@property (strong, nonatomic) UIButton *previousChapterButton;
@property (strong, nonatomic) UIButton *nextChapterButton;

@property (strong, nonatomic) UIPopoverController *PO;
//@property (strong, nonatomic) FWTPopoverView *popoverView;

@property (strong, nonatomic) UIBarButtonItem *toggleStrongsBtn;
@property (strong, nonatomic) UIBarButtonItem *toggleMorphologyBtn;
@property (strong, nonatomic) UIBarButtonItem *toggleTranslationBtn;

@property (strong, nonatomic) UIBarButtonItem *leftTextSelect;
@property (strong, nonatomic) UIBarButtonItem *rightTextSelect;
@property (strong, nonatomic) NSArray *bibleTextIDs;

@property (strong, nonatomic) UITextField *keyboardControl;

@property (strong, nonatomic, readwrite) UIView *inputView;

-(void)notifyNoteChanged;

@end