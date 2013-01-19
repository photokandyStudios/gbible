//
//  PKBibleBooksController.m
//  gbible
//
//  Created by Kerri Shotts on 3/16/12.
//  Copyright (c) 2012 photoKandy Studios LLC. All rights reserved.
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
  
  self.view.backgroundColor                   = [PKSettings PKSelectionColor];
  self.collectionView.backgroundColor = [PKSettings PKSidebarPageColor];
  self.title                                       = __T(@"Goto");
  self.navigationController.navigationBar.barStyle = UIBarStyleBlack;

  [self.collectionView registerClass:[PKSimpleCollectionViewCell class] forCellWithReuseIdentifier:@"simple-cell"];
  //self.collectionView.bounds = CGRectMake (0,0, 260, 500);
}

-(void) updateAppearanceForTheme
{
  self.view.backgroundColor = [PKSettings PKSidebarPageColor];
  self.collectionView.backgroundColor = [PKSettings PKSidebarPageColor];
  [self.collectionView reloadData];
}

/**
 *
 * Set our width
 *
 */
-(void)viewDidAppear: (BOOL) animated
{
  CGRect newFrame = self.navigationController.view.frame;
  newFrame.size.width                  = 260;
  self.navigationController.view.frame = newFrame;
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
  CGRect newFrame = self.navigationController.view.frame;
  newFrame.size.width                  = 260;
  self.navigationController.view.frame = newFrame;
}

-(void)didRotateFromInterfaceOrientation: (UIInterfaceOrientation) fromInterfaceOrientation
{
  CGRect newFrame = self.navigationController.view.frame;
  newFrame.size.width                  = 260;
  self.navigationController.view.frame = newFrame;
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
  cell.backgroundColor = [PKSettings PKSidebarPageColor];
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

@end