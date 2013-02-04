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

@interface PKNoteEditorViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate>

@property (strong, nonatomic) NSString *passage;
@property (strong, nonatomic) NSString *noteTitle;
@property (strong, nonatomic) NSString *note;
@property int state;

@property (strong, nonatomic) UITextField *txtTitle;
@property (strong, nonatomic) PKTextView *txtNote;
@property (strong, nonatomic) UIBarButtonItem *btnDelete;
@property (strong, nonatomic) UIBarButtonItem *btnCancel;
@property (strong, nonatomic) UIBarButtonItem *btnDone;

@property (strong, nonatomic) TPKeyboardAvoidingScrollView *scroller;

-(id) initWithPassage: (NSString *) thePassage;
-(id) initWithPassage: (NSString *) thePassage andTitle: (NSString *) theTitle andNote: (NSString *) theNote;

@end