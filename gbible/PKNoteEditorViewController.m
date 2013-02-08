//
//  PKNoteEditorViewController.m
//  gbible
//
//  Created by Kerri Shotts on 4/1/12.
//  Copyright (c) 2012 photoKandy Studios LLC. All rights reserved.
//

#import "PKNoteEditorViewController.h"
#import "PKNotes.h"
#import "PKBible.h"
#import "PKAppDelegate.h"
#import "PKNotesViewController.h"
#import "PKBibleViewController.h"
#import "ZUUIRevealController.h"
#import "PKRootViewController.h"
#import "TestFlight.h"
#import "KOKeyboardRow.h"
#import "PKTextView.h"
#import "PKBibleBooksController.h"

@interface PKNoteEditorViewController ()

@property (nonatomic, strong) UIPopoverController *PO;

@end

@implementation PKNoteEditorViewController

@synthesize state;
@synthesize passage;
@synthesize note;
@synthesize noteTitle;

@synthesize txtTitle;
@synthesize txtNote;
@synthesize btnDelete;
@synthesize btnCancel;
@synthesize btnDone;

@synthesize scroller;

@synthesize PO;

-(id)init
{
  self = [super init];
  
  if (self)
  {
    // Custom initialization
  }
  return self;
}

-(id) initWithPassage: (NSString *) thePassage
{
  self = [super init];
  
  if (self)
  {
    passage = thePassage;
    int theBook    = [PKBible bookFromString: thePassage];
    int theChapter = [PKBible chapterFromString: thePassage];
    int theVerse   = [PKBible verseFromString: thePassage];
    
    noteTitle = [NSString stringWithFormat: @"%@ %i:%i",
                 [PKBible nameForBook: theBook],
                 theChapter, theVerse];
    
    note = [NSString stringWithFormat: @"%@\n%@",
            [PKBible getTextForBook: theBook forChapter: theChapter forVerse: theVerse forSide: 1],
            [PKBible getTextForBook: theBook forChapter: theChapter forVerse: theVerse forSide: 2]];
  }
  return self;
}

-(id) initWithPassage: (NSString *) thePassage andTitle: (NSString *) theTitle andNote: (NSString *) theNote
{
  self = [super init];
  
  if (self)
  {
    passage   = thePassage;
    noteTitle = theTitle;
    note      = theNote;
  }
  return self;
}

-(void)updateState
{
  switch (state)
  {
    case 0:
      self.navigationItem.leftBarButtonItem  = btnDelete;
      self.navigationItem.rightBarButtonItem = btnDone;
      self.navigationItem.title              = __T(@"Viewing Note");
      break;
      
    case 1:
      self.navigationItem.leftBarButtonItem  = btnCancel;
      self.navigationItem.rightBarButtonItem = btnDone;
      self.navigationItem.title              = __T(@"Editing Note");
      break;
      
    default:
      break;
  }
}

-(void)loadData
{
  NSArray *theNote = [(PKNotes *)[PKNotes instance] getNoteForPassage: self.passage];
  
  if (!theNote)
  {
    // we're creating a note...yay! State will go straight to edit
    self.state    = 1;      // editing, pull values from default
    txtTitle.text = noteTitle;
    txtNote.text  = note;
  }
  else
  {
    self.state    = 0;      // looking
    txtTitle.text = [theNote objectAtIndex: 0];
    txtNote.text  = [theNote objectAtIndex: 1];
  }
  [self updateState];
}

-(void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  [TestFlight passCheckpoint: @"ANNOTATION"];
  
  // get the font
  UIFont *theFont = [UIFont fontWithName: [[PKSettings instance] textFontFace]
                                    size: [[PKSettings instance] textFontSize]];
  
  if (theFont == nil)
  {
    theFont = [UIFont fontWithName: [NSString stringWithFormat: @"%@-Regular", [[PKSettings instance] textFontFace]]
                              size: [[PKSettings instance] textFontSize]];
  }
  
  if (theFont == nil)
  {
    theFont = [UIFont fontWithName: @"Helvetica"
                              size: [[PKSettings instance] textFontSize]];
  }
  
  scroller =
  [[TPKeyboardAvoidingScrollView alloc] initWithFrame: CGRectMake(0, 0, self.view.bounds.size.width,
                                                                  self.view.bounds.size.height)];
  
  txtTitle =
  [[UITextField alloc] initWithFrame: CGRectMake(20, 10, self.view.bounds.size.width - 40, (theFont.lineHeight*1.5) + 10)];
  txtNote  =
  [[PKTextView alloc] initWithFrame: CGRectMake(10, 20 + theFont.lineHeight, self.view.bounds.size.width - 20,
                                                self.view.bounds.size.height - 52)];
  
  txtTitle.placeholder            = __T(@"Title for note");
  
  self.view.autoresizesSubviews   = YES;
  txtTitle.autoresizingMask       = UIViewAutoresizingFlexibleWidth;
  txtNote.autoresizingMask        = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  scroller.autoresizesSubviews    = YES;
  scroller.autoresizingMask       = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  
  scroller.clipsToBounds          = YES;
  scroller.delegate               = self;
  scroller.directionalLockEnabled = YES;
  
  [scroller adjustWidth: YES andHeight: YES withHorizontalPadding: 0 andVerticalPadding: 0];
  
  //txtTitle.borderStyle = UITextBorderStyleRoundedRect;
  
  txtNote.font           = theFont;
  txtTitle.font          = [UIFont fontWithName:[theFont fontName] size:[theFont pointSize]*1.5];
  txtTitle.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
  
  
  txtTitle.returnKeyType = UIReturnKeyNext;
  txtNote.returnKeyType  = UIReturnKeyDefault;
  
  txtTitle.delegate      = self;
  txtNote.delegate       = self;
  txtNote.actionDelegate = self;
  
  btnDone                = [[UIBarButtonItem alloc] initWithTitle: __T(@"Done") style: UIBarButtonItemStyleDone
                                                           target: self
                                                           action: @selector(donePressed:)];
  btnDelete              = [[UIBarButtonItem alloc] initWithTitle: __T(@"Delete") style: UIBarButtonItemStylePlain
                                                           target: self
                                                           action: @selector(deletePressed:)];
  btnCancel              = [[UIBarButtonItem alloc] initWithTitle: __T(@"Cancel") style: UIBarButtonItemStylePlain
                                                           target: self
                                                           action: @selector(cancelPressed:)];
  
  self.view.backgroundColor = [UIColor whiteColor];
  [scroller addSubview: txtTitle];
  [scroller addSubview: txtNote];
  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
  {
    [KOKeyboardRow applyToTextView:txtNote];
  }
  [self.view addSubview: scroller];
}

-(void) updateAppearanceForTheme
{
  self.view.backgroundColor = [PKSettings PKPageColor];
  self.txtNote.backgroundColor                     = [UIColor clearColor];
  self.txtTitle.backgroundColor                    = [UIColor clearColor];
  self.txtNote.textColor                           = [PKSettings PKTextColor];
  self.txtTitle.textColor                          = [PKSettings PKTextColor];
  self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
}

-(void)viewWillAppear: (BOOL) animated
{
  [self loadData];
  [self updateAppearanceForTheme];
  [self.view setNeedsLayout];
}

-(void)viewDidUnload
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  txtTitle  = nil;
  txtNote   = nil;
  btnDelete = nil;
  btnCancel = nil;
  btnDone   = nil;
  scroller  = nil;
}

-(void)didAnimateFirstHalfOfRotationToInterfaceOrientation: (UIInterfaceOrientation) toInterfaceOrientation
{
  [self.view layoutSubviews];
  [scroller adjustWidth: YES andHeight: YES withHorizontalPadding: 0 andVerticalPadding: 0];
}

-(BOOL)shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) interfaceOrientation
{
  return YES;
}

#pragma mark -
#pragma mark button events

-(void)cancelPressed: (id) sender
{
  [self dismissModalViewControllerAnimated: YES];
}

-(void)donePressed: (id) sender
{
  if (state == 1)
  {
    [(PKNotes *)[PKNotes instance] setNote: txtNote.text withTitle: txtTitle.text forPassage: passage];
    PKRootViewController *pvc  =
    (PKRootViewController *)[[(PKAppDelegate *)[PKAppDelegate instance] rootViewController] frontViewController];
    PKBibleViewController *bvc = [[[pvc.viewControllers objectAtIndex: 0] viewControllers] objectAtIndex: 0];
    [bvc notifyNoteChanged];
    [[[[PKAppDelegate instance] segmentController].viewControllers objectAtIndex: 2] reloadNotes];
  }
  [self dismissModalViewControllerAnimated: YES];
}

-(void)deletePressed: (id) sender
{
  [(PKNotes *)[PKNotes instance] deleteNoteForPassage: passage];
  PKRootViewController *pvc  =
  (PKRootViewController *)[[(PKAppDelegate *)[PKAppDelegate instance] rootViewController] frontViewController];
  PKBibleViewController *bvc = [[[pvc.viewControllers objectAtIndex: 0] viewControllers] objectAtIndex: 0];
  [bvc notifyNoteChanged];
  [[[[PKAppDelegate instance] segmentController].viewControllers objectAtIndex: 2] reloadNotes];
  [self dismissModalViewControllerAnimated: YES];
}

#pragma mark -
#pragma mark text field delegate methods

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
  if (textField == txtTitle)
  {
    [txtTitle resignFirstResponder];
    [txtNote becomeFirstResponder];
    
    return NO;
  }
  return YES;
}

-(void) textFieldDidBeginEditing: (UITextField *) textField
{
  state = 1;
  [self updateState];
}

#pragma mark -
#pragma mark text view field delegate methods

-(void) textViewDidBeginEditing: (UITextView *) textView
{
  state = 1;
  [self updateState];
}

-(void) textViewDidEndEditing:(UITextView *)textView
{
  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
  {
    [((KOKeyboardRow *)textView.inputAccessoryView) removeFromSuperview];
    [KOKeyboardRow applyToTextView:txtNote];
  }
}

#pragma mark -
#pragma mark custom action delegates from the text view
- (void)insertVerseReference
{

  PKBibleBooksController *BBC = [[PKBibleBooksController alloc] initWithCollectionViewLayout:[PSUICollectionViewFlowLayout new]];
  BBC.delegate = self;
  
  UINavigationController *NC = [[UINavigationController alloc] initWithRootViewController:BBC];
  
  NC.modalPresentationStyle = UIModalPresentationFormSheet;
  [self presentModalViewController: NC animated: YES];

}

- (void)insertVerse
{

  PKBibleBooksController *BBC = [[PKBibleBooksController alloc] initWithCollectionViewLayout:[PSUICollectionViewFlowLayout new]];
  BBC.delegate = self;
  BBC.notifyWithCopyOfVerse = YES;
  
  UINavigationController *NC = [[UINavigationController alloc] initWithRootViewController:BBC];
  
  NC.modalPresentationStyle = UIModalPresentationFormSheet;
  [self presentModalViewController: NC animated: YES];

}

- (void)showVerse
{
    [PO dismissPopoverAnimated: NO];
}

- (void)defineStrongs
{
    [PO dismissPopoverAnimated: NO];
}


#pragma mark -
#pragma mark a Bible verse is trying to be inserted
- (void)newReferenceByBook:(int)theBook andChapter:(int)theChapter andVerse:(int)andVerse
{
  NSString *theReference = [NSString stringWithFormat:@" %@ %i:%i ", [PKBible nameForBook:theBook],
                                                                  theChapter, andVerse];
  [txtNote insertText:theReference];
  //[txtNote becomeFirstResponder];
}

- (void)newVerseByBook:(int)theBook andChapter:(int)theChapter andVerse:(int)andVerse
{
}

@end