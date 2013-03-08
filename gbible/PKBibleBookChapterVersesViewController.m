//
//  PKBibleBookChapterVersesViewController.m
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
#import "PKBibleBookChapterVersesViewController.h"
#import "PKBible.h"
#import "PKBibleViewController.h"
//#import "PKRootViewController.h"
#import "ZUUIRevealController.h"
#import "PKSettings.h"
#import "PKSimpleCollectionViewCell.h"
#import "PKBibleReferenceDelegate.h"
#import "PKAppDelegate.h"

@interface PKBibleBookChapterVersesViewController ()

@end

@implementation PKBibleBookChapterVersesViewController

@synthesize selectedBook;
@synthesize selectedChapter;
@synthesize delegate;

#pragma mark -
#pragma mark view lifecycle

/**
 *
 * Set the book and chapter
 *
 */
-(id)initWithBook: (int) theBook withChapter: (int) theChapter
{
  self = [super initWithCollectionViewLayout:[PSUICollectionViewFlowLayout new]];
  
  if (self)
  {
    // Custom initialization
    selectedBook    = theBook;
    selectedChapter = theChapter;
  }
  return self;
}

/**
 *
 * Set our title and background
 *
 */
-(void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  [TestFlight passCheckpoint: @"BIBLE_BOOK_CHAPTER_VERSES"];
  
  self.view.backgroundColor = (self.delegate)?[PKSettings PKPageColor]:[PKSettings PKSidebarPageColor];
  self.collectionView.backgroundColor = (self.delegate)?[PKSettings PKPageColor]:[PKSettings PKSidebarPageColor];
  //self.title                                       = __T(@"Select Verse");
  self.title = [__T(@"Chapter") stringByAppendingFormat:@" %i", selectedChapter];
  self.navigationController.navigationBar.barStyle = UIBarStyleBlack;

  [self.collectionView registerClass:[PKSimpleCollectionViewCell class] forCellWithReuseIdentifier:@"simple-cell"];
  
  if (delegate)
  {
    UIBarButtonItem *closeButton =
      [[UIBarButtonItem alloc] initWithTitle: __T(@"Done") style: UIBarButtonItemStylePlain target: self action: @selector(closeMe:)
      ];
    self.navigationItem.rightBarButtonItem = closeButton;
  }
}

-(void) updateAppearanceForTheme
{
  self.view.backgroundColor = (self.delegate)?[PKSettings PKPageColor]:[PKSettings PKSidebarPageColor];
  self.collectionView.backgroundColor = (self.delegate)?[PKSettings PKPageColor]:[PKSettings PKSidebarPageColor];
  [self.collectionView reloadData];
}

-(void)viewWillAppear: (BOOL) animated
{
  [self updateAppearanceForTheme];
}

-(void)viewDidUnload
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
}

-(BOOL)shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) interfaceOrientation
{
  return YES;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSTCollectionViewDataSource

-(NSInteger) numberOfSectionsInCollectionView:(PSUICollectionView *)collectionView
{
  return 1;
}

/**
 *
 * Return # of verses for the book & chapter
 *
 */
- (NSInteger)collectionView:(PSUICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
  return [PKBible countOfVersesForBook: selectedBook forChapter: selectedChapter];
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSTCollectionViewDelegate

/**
 *
 * Return the cell with a typical reference, like Matthew 1:1
 *
 */
- (PSUICollectionViewCell *)collectionView:(PSUICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
  PKSimpleCollectionViewCell *cell = (PKSimpleCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"simple-cell" forIndexPath:indexPath];
  
  NSUInteger row = [indexPath row];
  
  cell.label.text      = [NSString stringWithFormat: @"%i:%i", selectedChapter, row + 1];
  cell.label.font      = [UIFont fontWithName:[PKSettings boldInterfaceFont] size:16];
  cell.backgroundColor = (self.delegate)?[PKSettings PKPageColor]:[PKSettings PKSidebarPageColor];
  cell.label.textColor = [PKSettings PKSidebarTextColor];
  
  return cell;
}

/**
 *
 * If we press a row, we need to tell the BibleView controller to go there
 *
 */
-(void) collectionView:(PSUICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
  NSUInteger row = [indexPath row];
  
  [collectionView deselectItemAtIndexPath: indexPath animated: YES];
  
  // we can now form a complete reference. Pass that back to the bible view
  if (!self.delegate)
  {
    [self.navigationController popViewControllerAnimated:YES];
//    [self.navigationController popToRootViewControllerAnimated: YES];
    [[PKAppDelegate sharedInstance].rootViewController revealToggle: self];
    [[PKAppDelegate sharedInstance].bibleViewController displayBook: selectedBook andChapter: selectedChapter andVerse: row + 1];
  }
  else
  {
    if (self.notifyWithCopyOfVerse)
    {
      [self.delegate newVerseByBook:selectedBook andChapter:selectedChapter andVerse:row+1];
    }
    else
    {
      [self.delegate newReferenceByBook:selectedBook andChapter:selectedChapter andVerse:row+1];
    }
    [self dismissModalViewControllerAnimated: YES];
  }
 
}
-(CGSize) collectionView:(PSUICollectionView *)collectionView layout:(PSUICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
  return CGSizeMake((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 86 : 65),
                    (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 50 : 44) );
}

-(CGFloat) collectionView:(PSUICollectionView *)collectionView layout:(PSUICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
  return 0;
}

-(CGFloat) collectionView:(PSUICollectionView *)collectionView layout:(PSUICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
  return 0;
}

- (UIEdgeInsets)collectionView:
(PSUICollectionView *)collectionView layout:(PSUICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0,0,0,0);
}

#pragma mark -
#pragma mark Button Actions

-(void) closeMe: (id) sender
{
  [self dismissModalViewControllerAnimated: YES];
  [[PKSettings instance] saveSettings];
}


@end