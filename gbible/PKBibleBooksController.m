//
//  PKBibleBooksController.m
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
#import "PKBibleBooksController.h"
#import "PKBibleBookChaptersViewController.h"
#import "PKBible.h"
#import "PKSettings.h"
#import "PSTCollectionView.h"
#import "PKSimpleCollectionViewCell.h"

@interface PKBibleBooksController ()

@end

@implementation PKBibleBooksController

//@synthesize theCollectionView;
@synthesize delegate;

# pragma mark -
# pragma mark view lifecycle

/**
 *
 * Initialize
 *
 */
-(id)init
{
  self = [super init];
  
  if (self)
  {
    // Custom initialization
  }
  return self;
}

/**
 *
 * set the background color
 *
 */
-(void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  [TestFlight passCheckpoint: @"BIBLE_BOOKS"];
  
  self.view.backgroundColor = (self.delegate)?[PKSettings PKPageColor]:[PKSettings PKSidebarPageColor];
  self.collectionView.backgroundColor = (self.delegate)?[PKSettings PKPageColor]:[PKSettings PKSidebarPageColor];
  self.title                                       = __T(@"Goto");
  self.navigationController.navigationBar.barStyle = UIBarStyleBlack;

  [self.collectionView registerClass:[PKSimpleCollectionViewCell class] forCellWithReuseIdentifier:@"simple-cell"];
  //self.collectionView.bounds = CGRectMake (0,0, 260, 500);
  
  if (delegate)
  {
    UIBarButtonItem *closeButton =
      [[UIBarButtonItem alloc] initWithTitle: __T(@"Done") style: UIBarButtonItemStylePlain target: self action: @selector(closeMe:)
      ];
    self.navigationItem.rightBarButtonItem = closeButton;
    self.navigationItem.title              = __T(@"Select Book");
  }
  
  
}

-(void) updateAppearanceForTheme
{
  self.view.backgroundColor = (self.delegate)?[PKSettings PKPageColor]:[PKSettings PKSidebarPageColor];
  self.collectionView.backgroundColor = (self.delegate)?[PKSettings PKPageColor]:[PKSettings PKSidebarPageColor];
  [self.collectionView reloadData];
}

/**
 *
 * Set our width
 *
 */
-(void)viewDidAppear: (BOOL) animated
{
  if (!delegate)
  {
    CGRect newFrame = self.navigationController.view.frame;
    newFrame.size.width                  = 260;
    self.navigationController.view.frame = newFrame;
  }
  [self updateAppearanceForTheme];
}

-(void)viewDidUnload
{
  [super viewDidUnload];
  //theCollectionView = nil;
  // Release any retained subviews of the main view.
}

/**
 *
 * keep our width during rotation animation
 *
 */
-(void)didAnimateFirstHalfOfRotationToInterfaceOrientation: (UIInterfaceOrientation) toInterfaceOrientation
{
  if (!delegate)
  {
    CGRect newFrame = self.navigationController.view.frame;
    newFrame.size.width                  = 260;
    self.navigationController.view.frame = newFrame;
  }
}

-(void)didRotateFromInterfaceOrientation: (UIInterfaceOrientation) fromInterfaceOrientation
{
  if (!delegate)
  {
    CGRect newFrame = self.navigationController.view.frame;
    newFrame.size.width                  = 260;
    self.navigationController.view.frame = newFrame;
  }
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


- (NSInteger)collectionView:(PSUICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
  return 27;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSTCollectionViewDelegate

- (PSUICollectionViewCell *)collectionView:(PSUICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
  PKSimpleCollectionViewCell *cell = (PKSimpleCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"simple-cell" forIndexPath:indexPath];
  NSUInteger row = [indexPath row];
  cell.backgroundColor = (self.delegate)?[PKSettings PKPageColor]:[PKSettings PKSidebarPageColor];
  cell.label.text      = [PKBible nameForBook: row + 40]; // get book name
  cell.label.textColor = [PKSettings PKSidebarTextColor];
  cell.label.textAlignment = UITextAlignmentLeft;
  //    cell.textLabel.textColor = [UIColor whiteColor];
  //    cell.selectionStyle = UITableViewCellSelectionStyleNone;
  
  return cell;
}

/**
 *
 * Push the Chapter view controller when we select a book.
 *
 */
-(void) collectionView:(PSUICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
  NSUInteger row = [indexPath row];
  
  PKBibleBookChaptersViewController *bcvc = [[PKBibleBookChaptersViewController alloc]
                                             initWithBook: row + 40];
  bcvc.delegate = self.delegate;
  bcvc.notifyWithCopyOfVerse = self.notifyWithCopyOfVerse;
  
  [self.navigationController pushViewController: bcvc animated: YES];
  
  [collectionView deselectItemAtIndexPath: indexPath animated: YES];
}

-(CGSize) collectionView:(PSUICollectionView *)collectionView layout:(PSUICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
  return CGSizeMake(130, (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 50 : 36));
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