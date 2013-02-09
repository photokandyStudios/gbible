//
//  PKNoteEditorViewController.h
//  gbible
//
//  Created by Kerri Shotts on 4/1/12.
//  Copyright (c) 2012 photoKandy Studios LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPKeyboardAvoidingScrollView.h"
#import "PKTextView.h"
#import "PKTextViewDelegate.h"
#import "PKBibleReferenceDelegate.h"
#import "KBKeyboardHandlerDelegate.h"


@interface PKNoteEditorViewController : UIViewController <UITextViewDelegate, PKTextViewDelegate, PKBibleReferenceDelegate, KBKeyboardHandlerDelegate>

@property (strong, nonatomic) NSString *passage;
@property (strong, nonatomic) NSString *noteTitle;
@property (strong, nonatomic) NSString *note;
@property int state;

@property (strong, nonatomic) UITextView *txtTitle;
@property (strong, nonatomic) PKTextView *txtNote;
@property (strong, nonatomic) UIBarButtonItem *btnDelete;
@property (strong, nonatomic) UIBarButtonItem *btnCancel;
@property (strong, nonatomic) UIBarButtonItem *btnDone;

@property (strong, nonatomic) TPKeyboardAvoidingScrollView *scroller;

-(id) initWithPassage: (NSString *) thePassage;
-(id) initWithPassage: (NSString *) thePassage andTitle: (NSString *) theTitle andNote: (NSString *) theNote;

@end