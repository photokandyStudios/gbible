//
//  PKBibleBookChaptersViewController.m
//  gbible
//
//  Created by Kerri Shotts on 3/16/12.
//  Copyright (c) 2012 photoKandy Studios LLC. All rights reserved.
//

#import "PKBibleBookChaptersViewController.h"
#import "PKBibleBookChapterVersesViewController.h"
#import "PKBible.h"
#import "PKSettings.h"
#import "PKSimpleCollectionViewCell.h"
#import "PKSimpleBibleViewController.h"

@interface PKBibleBookChaptersViewController ()

@end

@implementation PKBibleBookChaptersViewController

@synthesize selectedBook;
@synthesize delegate;

#pragma mark -
#pragma mark view lifecycle

/**
 *
 * Initialize; set our selectedBook to the incoming book
 *
 */
-(id)initWithBook: (int) theBook
{
  self = [super initWithCollectionViewLayout:[PSUICollectionViewFlowLayout new]];
  
  if (self)
  {
    // Custom initialization
    selectedBook = theBook;
  }
  return self;
}

/**
 *
 * Set our title, adjust background
 *
 */
-(void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  [TestFlight passCheckpoint: @"BIBLE_BOOK_CHAPTERS"];


  self.view.backgroundColor           = [PKSettings PKSidebarPageColor];
  self.collectionView.backgroundColor = [PKSettings PKSidebarPageColor];
//  self.title                                       = __T(@"Select Chapter");
  self.title = [PKBible nameForBook:selectedBook];
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
  self.view.backgroundColor = [PKSettings PKSidebarPageColor];
  self.collectionView.backgroundColor = [PKSettings PKSidebarPageColor];
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
 * Get number of chapters for the book
 *
 */
- (NSInteger)collectionView:(PSUICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
  return [PKBible countOfChaptersForBook: selectedBook];
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSTCollectionViewDelegate
/**
 *
 * Return book + chapter in the cell
 *
 */

- (PSUICollectionViewCell *)collectionView:(PSUICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
  PKSimpleCollectionViewCell *cell = (PKSimpleCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"simple-cell" forIndexPath:indexPath];
  
  NSUInteger row = [indexPath row];
  
  cell.label.text      = [NSString stringWithFormat: @"%i", row + 1]; // get chapter
  cell.backgroundColor = [PKSettings PKSidebarPageColor];
  cell.label.textColor = [PKSettings PKSidebarTextColor];
  
  return cell;
}

/**
 *
 * When we select a row, push a Verses controller to select the verse
 *
 */
-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
  NSUInteger row = [indexPath row];
  
  if (!self.delegate)
  {
    PKBibleBookChapterVersesViewController *bcvc = [[PKBibleBookChapterVersesViewController alloc]
                                                    initWithBook: selectedBook withChapter: row + 1];
    bcvc.delegate = self.delegate;
    bcvc.notifyWithCopyOfVerse = self.notifyWithCopyOfVerse;

    [self.navigationController pushViewController: bcvc animated: YES];
  }
  else
  {
    PKSimpleBibleViewController *sbvc = [[PKSimpleBibleViewController alloc] initWithStyle:UITableViewStylePlain];
    sbvc.delegate = self.delegate;
    sbvc.notifyWithCopyOfVerse = self.notifyWithCopyOfVerse;
    [sbvc loadChapter:row + 1 forBook:selectedBook];
    [self.navigationController pushViewController:sbvc animated:YES];
  }
  
  [collectionView deselectItemAtIndexPath: indexPath animated: YES];
}

-(CGSize) collectionView:(PSUICollectionView *)collectionView layout:(PSUICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
  return CGSizeMake((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 86 : 65),
                    (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 65 : 44));
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