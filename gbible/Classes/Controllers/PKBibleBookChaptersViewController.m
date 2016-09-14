//
//  PKBibleBookChaptersViewController.m
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
#import "PKBibleBookChaptersViewController.h"
#import "PKBibleBookChapterVersesViewController.h"
#import "PKBible.h"
#import "PKSettings.h"
#import "PKSimpleCollectionViewCell.h"
#import "PKSimpleBibleViewController.h"
#import "UIImage+PKUtility.h"
#import "PKReference.h"

@interface PKBibleBookChaptersViewController ()

@end

@implementation PKBibleBookChaptersViewController

#pragma mark -
#pragma mark view lifecycle

/**
 *
 * Initialize; set our selectedBook to the incoming book
 *
 */
-(id)initWithBook: (NSUInteger) theBook
{
  self = [super initWithCollectionViewLayout:[UICollectionViewFlowLayout new]];
  
  if (self)
  {
    // Custom initialization
    _selectedBook = theBook;
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


  self.view.backgroundColor = (self.delegate)?[PKSettings PKPageColor]:[PKSettings PKSidebarPageColor];
  self.collectionView.backgroundColor = (self.delegate)?[PKSettings PKPageColor]:[PKSettings PKSidebarPageColor];
//  self.title                                       = __T(@"Select Chapter");
  self.title = [PKBible nameForBook:_selectedBook];
  if (SYSTEM_VERSION_LESS_THAN(@"7.0"))
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
  else
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
  CGFloat topOffset = self.navigationController.navigationBar.frame.size.height;
  if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) { topOffset = 0; }
  self.collectionView.contentInset = UIEdgeInsetsMake(topOffset, 0, 0, 0);
  if (SYSTEM_VERSION_LESS_THAN(@"7.0") && !_delegate)
    self.collectionView.scrollIndicatorInsets = UIEdgeInsetsMake(topOffset, 0, 0, 0);

  [self.collectionView registerClass:[PKSimpleCollectionViewCell class] forCellWithReuseIdentifier:@"simple-cell"];

  if (_delegate)
  {
    UIBarButtonItem *closeButton =
      [[UIBarButtonItem alloc] initWithTitle: __T(@"Done") style: UIBarButtonItemStylePlain target: self action: @selector(closeMe:)
      ];
    self.navigationItem.rightBarButtonItem = closeButton;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
    {
      [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:[PKSettings PKSecondaryPageColor]] forBarMetrics:UIBarMetricsDefault];
    }
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

-(NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
  return 1;
}

/**
 *
 * Get number of chapters for the book
 *
 */
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
  return [PKBible countOfChaptersForBook: _selectedBook];
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSTCollectionViewDelegate
/**
 *
 * Return book + chapter in the cell
 *
 */

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
  PKSimpleCollectionViewCell *cell = (PKSimpleCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"simple-cell" forIndexPath:indexPath];
  
  NSUInteger row = [indexPath row];
  
  cell.label.text      = [PKReference stringFromChapterNumber:row + 1]; // get chapter
  cell.label.font      = [UIFont fontWithName:[PKSettings boldInterfaceFont] size:16];
  cell.backgroundColor = (self.delegate)?[PKSettings PKPageColor]:[PKSettings PKSidebarPageColor];
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
                                                    initWithBook: _selectedBook withChapter: row + 1];
    bcvc.delegate = self.delegate;
    bcvc.notifyWithCopyOfVerse = self.notifyWithCopyOfVerse;

    [self.navigationController pushViewController: bcvc animated: YES];
  }
  else
  {
    PKSimpleBibleViewController *sbvc = [[PKSimpleBibleViewController alloc] initWithStyle:UITableViewStylePlain];
    sbvc.delegate = self.delegate;
    sbvc.notifyWithCopyOfVerse = self.notifyWithCopyOfVerse;
    [sbvc loadChapter:row + 1 forBook:_selectedBook];
    [self.navigationController pushViewController:sbvc animated:YES];
  }
  
  [collectionView deselectItemAtIndexPath: indexPath animated: YES];
}

-(CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
  return CGSizeMake((isWide((UIView *)self) ? 86 : 65),
                    (isWide((UIView *)self) ? 65 : 44));
}

-(CGFloat) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
  return 0;
}

-(CGFloat) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
  return 0;
}

- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0,0,0,0);
}
#pragma mark -
#pragma mark Button Actions


-(void) closeMe: (id) sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
  [[PKSettings instance] saveSettings];
}


@end
