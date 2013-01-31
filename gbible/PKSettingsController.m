//
//  PKSettingsController.m
//  gbible
//
//  Created by Kerri Shotts on 3/16/12.
//  Copyright (c) 2012 photoKandy Studios LLC. All rights reserved.
//

#import "PKSettingsController.h"
#import "PKConstants.h"
#import "PKSettings.h"
#import "ZUUIRevealController.h"
#import "PKDatabase.h"
#import "PKAppDelegate.h"
#import "PKHighlightsViewController.h"
#import "PKNotesViewController.h"
#import "PKRootViewController.h"
#import "PKBibleViewController.h"
#import "PKBibleBooksController.h"
#import "TestFlight.h"
#import "PKBible.h"
#import "TSMiniWebBrowser.h"
#import "PKBibleListViewController.h"


@interface PKSettingsController ()

@end

@implementation PKSettingsController

@synthesize layoutSettings;
@synthesize textSettings;
@synthesize iCloudSettings;
@synthesize importSettings;
@synthesize exportSettings;
@synthesize versionSettings;

@synthesize settingsGroup;

@synthesize currentPathForPopover;
@synthesize theTableCell;

/**
 *
 * Initialize our view, namely to set our title.
 *
 */
-(id)initWithStyle: (UITableViewStyle) style
{
  self = [super initWithStyle: style];

  if (self)
  {
    // set our title
    [self.navigationItem setTitle: __T(@"Settings")];
  }
  return self;
}

-(void) updateAppearanceForTheme
{
  [self.tableView setBackgroundView: nil];
  self.tableView.backgroundColor = [PKSettings PKPageColor];
  // Fix issue #55
  // self.tableView.sectionIndexColor = [PKSettings PKTextColor];
  self.tableView.separatorColor  = [PKSettings PKTextColor];
  self.tableView.separatorStyle  = UITableViewCellSeparatorStyleSingleLine;
  //self.tableView.sectionHeaderHeight = 60;
  //self.tableView.sectionFooterHeight = 60;
  [self.tableView reloadData];
}

-(void)reloadSettingsArray
{
  NSArray *englishTypeface = [NSArray arrayWithObjects:
                              @"CourierNewPSMT",
                              @"CourierNewPS-BoldMT",
                              @"Helvetica",
                              @"HelveticaNeue",
                              @"Helvetica-Light",
                              @"HelveticaNeue-Light",
                              @"OpenDyslexic-Regular",
                              @"Palatino-Roman",
                              @"Palatino-Bold", nil];
  NSArray *greekTypeface = [NSArray arrayWithObjects:   @"CourierNewPSMT",
                            @"CourierNewPS-BoldMT",
                            @"Helvetica",
                            @"Helvetica-Bold",
                            @"HelveticaNeue",
                            @"HelveticaNeue-Bold",
                            @"OpenDyslexic-Bold",
                            @"Palatino-Roman",
                            @"Palatino-Bold", nil];

  if ( SYSTEM_VERSION_LESS_THAN(@"5.0") )
  {
    englishTypeface = [NSArray arrayWithObjects: @"CourierNewPSMT",
                       @"CourierNewPS-BoldMT",
                       @"Helvetica",
                       @"OpenDyslexic-Regular",
                       @"Palatino-Roman",
                       @"Palatino-Bold", nil];
    greekTypeface = [NSArray arrayWithObjects:     @"CourierNewPSMT",
                     @"CourierNewPS-BoldMT",
                     @"Helvetica",
                     @"Helvetica-Bold",
                     @"OpenDyslexic-Bold",
                     @"Palatino-Roman",
                     @"Palatino-Bold", nil];
  }
  layoutSettings = [NSArray arrayWithObjects: [NSArray arrayWithObjects: __T(@"Theme"), @3, @"text-theme",
                                               @[@0, @1, @2, @3],
                                               @[__T(@"Original"),       __T(@"Black on White"),
                                                 __T(@"White on Black"), __T(@"Amber on Black")]
                                               , nil],
                    [NSArray arrayWithObjects: __T(@"English Typeface"), [NSNumber numberWithInt: 1], PK_SETTING_FONTFACE,
                     englishTypeface, nil],
                    [NSArray arrayWithObjects: __T(@"Greek Typeface﹡"), [NSNumber numberWithInt: 1], @"greek-typeface",                            //RE:
                                                                                                                                                   // ISSUE
                                                                                                                                                   // #6
                     greekTypeface, nil],
                    [NSArray arrayWithObjects: __T(@"Font Size"), [NSNumber numberWithInt: 3], PK_SETTING_FONTSIZE,
                     [NSArray arrayWithObjects:
                      [NSNumber numberWithInt: 9],
                      [NSNumber numberWithInt: 10],
                      [NSNumber numberWithInt: 11],
                      [NSNumber numberWithInt: 12],
                      [NSNumber numberWithInt: 14],
                      [NSNumber numberWithInt: 16],
                      [NSNumber numberWithInt: 18],
                      [NSNumber numberWithInt: 20],
                      [NSNumber numberWithInt: 22],
                      [NSNumber numberWithInt: 26],
                      [NSNumber numberWithInt: 32],
                      [NSNumber numberWithInt: 48], nil],
                     [NSArray arrayWithObjects:                                                       
                      @"9pt", @"10pt", @"11pt", @"12pt",
                      @"14pt", @"16pt", @"18pt", @"20pt", @"22pt",
                      @"26pt", @"32pt", @"48pt",
                      nil], nil],
                    [NSArray arrayWithObjects: __T(@"Line Spacing"), [NSNumber numberWithInt: 3], PK_SETTING_LINESPACING,
                     [NSArray arrayWithObjects:                                                       
                      [NSNumber numberWithInt: PK_LS_NORMAL],
                      [NSNumber numberWithInt: PK_LS_ONEQUARTER],
                      [NSNumber numberWithInt: PK_LS_ONEHALF],
                      [NSNumber numberWithInt: PK_LS_DOUBLE], nil],
                     [NSArray arrayWithObjects:                                                       
                      __T(@"Normal"),   __T(@"One-Quarter"),
                      __T(@"One-Half"), __T(@"Double"), nil], nil],
                    [NSArray arrayWithObjects: __T(@"Row Spacing"), [NSNumber numberWithInt: 3], PK_SETTING_VERSESPACING,
                     [NSArray arrayWithObjects: [NSNumber numberWithInt: PK_VS_NONE],
                      [NSNumber numberWithInt: PK_VS_SINGLE],
                      [NSNumber numberWithInt: PK_VS_DOUBLE], nil],
                     [NSArray arrayWithObjects: __T(@"Normal"), __T(@"Single Space"),
                      __T(@"Double Space"), nil], nil],
                    [NSArray arrayWithObjects: __T(@"Column Widths"), [NSNumber numberWithInt: 3], PK_SETTING_COLUMNWIDTHS,
                     [NSArray arrayWithObjects: [NSNumber numberWithInt: PK_CW_WIDEGREEK],
                      [NSNumber numberWithInt: PK_CW_WIDEENGLISH],
                      [NSNumber numberWithInt: PK_CW_EQUAL], nil],
                     [NSArray arrayWithObjects: __T(@"Wide Greek Column"),
                      __T(@"Wide English Column"),
                      __T(@"Equal Columns"), nil], nil],
                    nil];

  // get the left and right-side Bibles

  textSettings =
    [NSArray arrayWithObjects: [NSArray arrayWithObjects: __T(@"Greek Text"), [NSNumber numberWithInt: 3], PK_SETTING_GREEKTEXT,
                                [PKBible availableOriginalTexts: PK_TBL_BIBLES_ID],
                                [PKBible availableOriginalTexts: PK_TBL_BIBLES_NAME],
                                nil],
     [NSArray arrayWithObjects: __T(@"English Text"), [NSNumber numberWithInt: 3], PK_SETTING_ENGLISHTEXT,
      [PKBible availableHostTexts: PK_TBL_BIBLES_ID],
      [PKBible availableHostTexts: PK_TBL_BIBLES_NAME],
      nil],
     [NSArray arrayWithObjects: __Tv(@"Transliterate Greek",
                                     @"Transliterate Greek﹡?"), [NSNumber numberWithInt: 2], PK_SETTING_TRANSLITERATE, nil],
     [NSArray arrayWithObjects: __Tv(@"Show Inline Notes",
                                     @"Show Inline Notes?"), [NSNumber numberWithInt: 2], PK_SETTING_INLINENOTES, nil],
     [NSArray arrayWithObjects: __Tv(@"Show Morphology",
                                     @"Show Morphology?"), [NSNumber numberWithInt: 2], PK_SETTING_SHOWMORPHOLOGY, nil],
     [NSArray arrayWithObjects: __Tv(@"Show Strong's",
                                     @"Show Strong's?"), [NSNumber numberWithInt: 2], @"show-strongs", nil],
     [NSArray arrayWithObjects: __Tv(@"Show Translation",
                                     @"Show Translation✝?"), [NSNumber numberWithInt: 2], @"show-interlinear", nil],
          [NSArray arrayWithObjects: __T(@"Manage Bibles..."), [NSNumber numberWithInt:0], nil, nil ],
     nil];
  // iCloudSettings = [NSArray arrayWithObjects: [NSArray arrayWithObjects: @"Enable iCloud?", [NSNumber numberWithInt:2],
  // PK_SETTING_USEICLOUD, nil],
  //                                            nil];
  importSettings =
    [NSArray arrayWithObjects: [NSArray arrayWithObjects: __T(@"Import Annotations"), [NSNumber numberWithInt: 0], nil, nil],
     [NSArray arrayWithObjects: __T(@"Import Highlights"), [NSNumber numberWithInt: 0], nil, nil],
     [NSArray arrayWithObjects: __T(@"Import Everything"), [NSNumber numberWithInt: 0], nil, nil],
     nil];
  exportSettings  = [NSArray arrayWithObjects: [NSArray arrayWithObjects: __T(@"Export"), [NSNumber numberWithInt: 0], nil, nil],
                     nil];

  versionSettings =
    [NSArray arrayWithObjects:  [NSArray arrayWithObjects: [[[NSBundle mainBundle] infoDictionary] objectForKey: @"CFBundleVersion"
                                 ],
                                 [NSNumber numberWithInt: 0], nil, nil],
     [NSArray arrayWithObjects: __Tv(@"Anonymous Usage Statistics",
                                     @"Anonymous Usage Statistics?"), [NSNumber numberWithInt: 2], @"usage-stats", nil],
     nil];

  settingsGroup = [NSArray arrayWithObjects: textSettings, layoutSettings,   // iCloudSettings,
                   exportSettings, importSettings, versionSettings, nil];
}

/**
 *
 * Called when the view has finished loading. Here we create our
 * settings arrays.
 *
 */
-(void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  [TestFlight passCheckpoint: @"SETTINGS"];
  [self.tableView setBackgroundView: nil];
  self.tableView.backgroundColor = [PKSettings PKPageColor];
  [self reloadSettingsArray];

  UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc]
                                          initWithTarget: self action: @selector(didReceiveRightSwipe:)];
  UISwipeGestureRecognizer *swipeLeft  = [[UISwipeGestureRecognizer alloc]
                                          initWithTarget: self action: @selector(didReceiveLeftSwipe:)];
  swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
  swipeLeft.direction  = UISwipeGestureRecognizerDirectionLeft;
  [swipeRight setNumberOfTouchesRequired: 1];
  [swipeLeft setNumberOfTouchesRequired: 1];
  [self.tableView addGestureRecognizer: swipeRight];
  [self.tableView addGestureRecognizer: swipeLeft];

  UIBarButtonItem *changeReference = [[UIBarButtonItem alloc]
                                      initWithImage: [UIImage imageNamed: @"Listb.png"]
                                              style: UIBarButtonItemStylePlain
                                             target: self.parentViewController.parentViewController.parentViewController
                                             action: @selector(revealToggle:)];

  changeReference.accessibilityLabel    = __T(@"Go to passage");
  self.navigationItem.leftBarButtonItem = changeReference;
}

/**
 *
 * release our settings arrays
 *
 */
-(void)viewDidUnload
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  settingsGroup   = nil;
  exportSettings  = nil;
  importSettings  = nil;
  // iCloudSettings = nil;
  textSettings    = nil;
  layoutSettings  = nil;
  versionSettings = nil;
}

-(void)calculateShadows
{
  CGFloat topOpacity       = 0.0f;
  CGFloat theContentOffset = (self.tableView.contentOffset.y);

  if (theContentOffset > 15)
  {
    theContentOffset = 15;
  }
  topOpacity = (theContentOffset / 15) * 0.5;

  [( (PKRootViewController *)self.parentViewController.parentViewController ) showTopShadowWithOpacity: topOpacity];

  CGFloat bottomOpacity = 0.0f;

  theContentOffset = self.tableView.contentSize.height - self.tableView.contentOffset.y -
                     self.tableView.bounds.size.height;

  if (theContentOffset > 15)
  {
    theContentOffset = 15;
  }
  bottomOpacity = (theContentOffset / 15) * 0.5;

  [( (PKRootViewController *)self.parentViewController.parentViewController ) showBottomShadowWithOpacity: bottomOpacity];
}

-(void) viewDidAppear: (BOOL) animated
{
  [super viewDidAppear: animated];
  PKRootViewController *pvc  =
    (PKRootViewController *)[[(PKAppDelegate *)[PKAppDelegate instance] rootViewController] frontViewController];
  PKBibleViewController *bvc = [[[pvc.viewControllers objectAtIndex: 0] viewControllers] objectAtIndex: 0];
  bvc.dirty = YES;
  [self calculateShadows];
  [super viewDidAppear: animated];
  [self updateAppearanceForTheme];
}

-(void) didRotateFromInterfaceOrientation: (UIInterfaceOrientation) fromInterfaceOrientation
{
  [super didRotateFromInterfaceOrientation: fromInterfaceOrientation];
  [self calculateShadows];
  [self.tableView reloadData];
}

-(void) scrollViewDidScroll: (UIScrollView *) scrollView
{
  [self calculateShadows];
}

/**
 *
 * We support all orientations
 *
 */
-(BOOL)shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) interfaceOrientation
{
  return YES;
}

#pragma mark -
#pragma mark Table View Data Source Methods

/**
 *
 * Return desired header for each section in the table
 *
 */
-(NSString *)tableView: (UITableView *) tableView titleForHeaderInSection: (NSInteger) section
{
  switch (section)
  {
  case 0: return __T(@"Text");
    break;

  case 1: return __T(@"Layout");
    break;

  //  case 2: return @"Synchronization";
  //          break;
  case 2: return __T(@"Export");
    break;

  case 3: return __T(@"Import");
    break;

  case 4: return __T(@"Version");
    break;

  default: return @"Undefined";
    break;
  }
  return @"Undefined";
}

/**
 *
 * Return the footer for each group of cells.
 *
 */
-(NSString *)tableView: (UITableView *) tableView titleForFooterInSection: (NSInteger) section
{
  switch (section)
  {
  case 0: return __Tv(
             @"note-when-transliterating-greek",
             @"﹡ When transliterating Greek, the app may be slower when navigating to new passages.\n\n✝ Show Translation setting applies only to texts that support in-line translation. Currently the only text that supports this setting is Westcott-Hort.");
    break;

  case 1: return __Tv(
             @"note-opendyslexic",
             @"﹡ The OpenDyslexic font does not support polytonic Greek. It is suggested to use the OpenDyslexic font only if transliterating the Greek or when using a text without diacritics.");
    break;

//        case 2: return @"Enable iCloud to synchronize your data across multiple devices. It is suggested \
//                         that you export your data prior to enabling iCloud synchronization.";
//                break;
  case 2: return __Tv(
             @"note-export",
             @"Export will create a file of the form 'export_date_time.dat' that you can download when your device is connected to iTunes. You can then save this file in a safe place, or use it to import data to another device.");
    break;

  case 3: return __Tv(
             @"note-import",
             @"Before importing, connect your device to iTunes and copy the file you want to import. Be sure to name it 'import.dat'. Then select the desired option above. You can import more than one time from the same file.");
    break;

  case 4: return __Tv(
             @"note-anonymous-with-copyright",
             @"Disable Anonymous Usage Statistics if you don't want to send anonymous usage and debugging information. Please consider leaving this setting enabled, as the information helps us to create a better app for everyone. We will never sell this information to any other company. TestFlight is used to compile the anonymous information. \n\nNote: If you in a country where using the Bible may result in personal harm, you should disable Anonymous Usage Statistics. \n\nThis application is Copyright 2013 photoKandy Studios LLC. It is released under the Creative Commons BY-SA-NC license. See http://www.photokandy.com/apps/gib for more information. \n\n\n\n\n\n ");
    break;

  default: return @"Undefined";
    break;
  }
  return @"Undefined";
}

/**
 *
 * Return the number of sections we have
 *
 */
-(NSInteger) numberOfSectionsInTableView: (UITableView *) tableView
{
  return [settingsGroup count];
}

/**
 *
 * Return the number of rows in a particular section
 *
 */
-(NSInteger) tableView: (UITableView *) tableView numberOfRowsInSection: (NSInteger) section
{
  return [[self.settingsGroup objectAtIndex: section] count];
}

-(CGFloat)tableView: (UITableView *) tableView heightForHeaderInSection: (NSInteger) section
{
  return 20.0 +
         [[self tableView: tableView titleForHeaderInSection: section] sizeWithFont: [UIFont boldSystemFontOfSize: 16]
          constrainedToSize: CGSizeMake(tableView.bounds.size.width -
                                        ( ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) ? 88: 20 ),
                                        1000)].height;
}

-(CGFloat)tableView: (UITableView *) tableView heightForFooterInSection: (NSInteger) section
{
  return 40.0 +
         [[self tableView: tableView titleForFooterInSection: section] sizeWithFont: [UIFont systemFontOfSize: 14]
          constrainedToSize: CGSizeMake(tableView.bounds.size.width -
                                        ( ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) ? 88: 20 ),
                                        1000)].height;
}

// from http://www.randycrafton.com/2010/09/changing-the-text-color-of-a-grouped-uitableviews-section-header/
-(UIView *) tableView: (UITableView *) tableView viewForHeaderInSection: (NSInteger) section
{
  UIView *headerView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, tableView.bounds.size.width, 60)];
  UILabel *label     =
    [[UILabel alloc] initWithFrame: CGRectMake( ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) ? 44: 10,
                                                10, headerView.frame.size.width -
                                                ( ([[UIDevice currentDevice] userInterfaceIdiom] ==
                                                   UIUserInterfaceIdiomPad) ? 88: 20 ), 20 )];
  label.text            = [self tableView: tableView titleForHeaderInSection: section];
  label.font            = [UIFont boldSystemFontOfSize: 16.0];
  label.textAlignment   = NSTextAlignmentLeft;
  label.backgroundColor = [UIColor clearColor];
  label.textColor       = [PKSettings PKTextColor];

  [headerView addSubview: label];
  return headerView;
}

-(UIView *) tableView: (UITableView *) tableView viewForFooterInSection: (NSInteger) section
{
  UIView *footerView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, tableView.bounds.size.width, 600)];
  UILabel *label     =
    [[UILabel alloc] initWithFrame: CGRectMake( ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) ? 44: 10,
                                                10, footerView.frame.size.width -
                                                ( ([[UIDevice currentDevice] userInterfaceIdiom] ==
                                                   UIUserInterfaceIdiomPad) ? 88: 20 ), 400 )];
  label.text            = [self tableView: tableView titleForFooterInSection: section];
  label.numberOfLines   = 0;
  label.textAlignment   = NSTextAlignmentLeft;
  label.font            = [UIFont systemFontOfSize: 16.0];
  label.backgroundColor = [UIColor clearColor];
  label.textColor       = [PKSettings PKTextColor];
  [label sizeToFit];

  [footerView addSubview: label];
  return footerView;
}

/**
 *
 * Generate the cell for a given index path. This cell will be based on our settings array defined
 * and filled earlier, and may contain accessory views, popups, and more.
 *
 */
-(UITableViewCell *) tableView: (UITableView *) tableView cellForRowAtIndexPath: (NSIndexPath *) indexPath
{
  static NSString *settingsCellID = @"PKSettingsCellID";
  UITableViewCell *cell           = [tableView dequeueReusableCellWithIdentifier: settingsCellID];

  if (!cell)
  {
    cell = [[UITableViewCell alloc]
              initWithStyle: UITableViewCellStyleValue1
            reuseIdentifier: settingsCellID];
  }

  cell.backgroundColor           = [PKSettings PKSecondaryPageColor];
  cell.detailTextLabel.textColor = [PKSettings PKTextColor];

  NSUInteger section = [indexPath section];
  NSUInteger row     = [indexPath row];
  NSArray *cellData  = [[settingsGroup objectAtIndex: section] objectAtIndex: row];

  cell.textLabel.text      = [cellData objectAtIndex: 0];
  cell.textLabel.textColor = [PKSettings PKTextColor];

  cell.accessoryType       = UITableViewCellAccessoryNone;

  switch ([[cellData objectAtIndex: 1] intValue])
  {
  case 0 :      // the nothing case. :-)
    cell.detailTextLabel.text = @"";
    break;

  case 1 :      // here we want a disclosure arrow and the current setting
                //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.detailTextLabel.text = [(PKSettings *)[PKSettings instance] loadSetting: [cellData objectAtIndex: 2]];
    break;

  case 2 :      // here we want to display a checkbox if YES; none if NO
                // FIX ISSUE #48
    cell.detailTextLabel.text = __T(@"No");

    //cell.accessoryType = UITableViewCellAccessoryNone;
    if ([[(PKSettings *)[PKSettings instance] loadSetting: [cellData objectAtIndex: 2]] boolValue])
    {
      cell.detailTextLabel.text = __T(@"Yes");
      //cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    break;

  case 3 :      // here we want a disclosure arrow, current settings, and lookup
    ;             // cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                  // first, get the setting
    NSString *theSetting      = [(PKSettings *)[PKSettings instance] loadSetting: [cellData objectAtIndex: 2]];
    // now, convert it to an NSNumber
    NSNumber *theSettingValue = [NSNumber numberWithInt: [theSetting integerValue]];
    // find it in the cell's 3rd array
    int theIndex              = [[cellData objectAtIndex: 3] indexOfObject: theSettingValue];

    // now look up the corresponding text in the 4th array
    if (theIndex != NSNotFound)
    {
      NSString *theValue = [[cellData objectAtIndex: 4] objectAtIndex: theIndex];
      cell.detailTextLabel.text = theValue;
    }
    else
    {
      cell.detailTextLabel.text = @"Bad Setting";
    }
    break;
  }

  return cell;
}

/**
 *
 * Handle the user tapping on a row. Depending on the setting we have in a row, we may need to:
 *  - toggle the row's checkbox,
 *  - fire off a new action (like import/export)
 *  - show a popover TODO: these are buggy on the iPad...
 *
 */
-(void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
  UIActionSheet *popover;
  NSUInteger section       = [indexPath section];
  NSUInteger row           = [indexPath row];
  NSArray *cellData        = [[settingsGroup objectAtIndex: section] objectAtIndex: row];
  BOOL curValue;
  UITableViewCell *newCell = [tableView cellForRowAtIndexPath: indexPath];

  NSString *title          = __T(@"Operation");

  switch ([[cellData objectAtIndex: 1] intValue])
  {
  case 0 : {     // we're on a "nothing cell", but these will do actions...
      if (section == 0)
      {
        // manage Bibles
        PKBibleListViewController *blvc = [[PKBibleListViewController alloc] initWithStyle:UITableViewStylePlain];
        blvc.delegate = self;
        UINavigationController *mvnc = [[UINavigationController alloc] initWithRootViewController: blvc];
        mvnc.modalPresentationStyle = UIModalPresentationFormSheet;
        mvnc.navigationBar.barStyle = UIBarStyleBlack;
        [self presentModalViewController: mvnc animated: YES];
      }

      if (section == 2)
      {
        title = __T(@"Export Operation");

        if ([(PKDatabase *)[PKDatabase instance] exportAll])
        {
          UIAlertView *theAlertView =
            [[UIAlertView alloc] initWithTitle: title message: __T(@"Done!") delegate: self cancelButtonTitle: nil
             otherButtonTitles:
             __T(@"OK"), nil];
          [theAlertView show];
        }
      }

      if (section == 3)
      {
        title = __T(@"Import Operation");

        if (row == 0)
        {
          if ([(PKDatabase *)[PKDatabase instance] importNotes])
          {
            UIAlertView *theAlertView =
              [[UIAlertView alloc] initWithTitle: title message: __T(@"Done!") delegate: self cancelButtonTitle: nil
               otherButtonTitles
               : __T(@"OK"), nil];
            [theAlertView show];
          }
        }

        if (row == 1)
        {
          if ([(PKDatabase *)[PKDatabase instance] importHighlights])
          {
            UIAlertView *theAlertView =
              [[UIAlertView alloc] initWithTitle: title message: __T(@"Done!") delegate: self cancelButtonTitle: nil
               otherButtonTitles
               : __T(@"OK"), nil];
            [theAlertView show];
          }
        }

        if (row == 2)
        {
          if ([(PKDatabase *)[PKDatabase instance] importNotes])
          {
            if ([(PKDatabase *)[PKDatabase instance] importHighlights])
            {
              if ([(PKDatabase *)[PKDatabase instance] importSettings])
              {
                UIAlertView *theAlertView =
                  [[UIAlertView alloc] initWithTitle: title message: __T(@"Done!") delegate: self cancelButtonTitle: nil
                   otherButtonTitles: __T(@"OK"), nil];
                [theAlertView show];
              }
            }
          }
        }
        [[[[PKAppDelegate instance] segmentController].viewControllers objectAtIndex: 1] reloadHighlights];
        [[[[PKAppDelegate instance] segmentController].viewControllers objectAtIndex: 2] reloadNotes];
        [self.tableView reloadData];             // settings may be different.
      }
      break;
  }

  case 1 :      // we're on a cell that wants to display a popover/actionsheet (no lookup)
    popover = [[UIActionSheet alloc] initWithTitle: [cellData objectAtIndex: 0]
                                          delegate: self
                                 cancelButtonTitle: nil
                            destructiveButtonTitle: nil
                                 otherButtonTitles: nil];

    for (int i = 0; i < [[cellData objectAtIndex: 3] count]; i++)
    {
      [popover addButtonWithTitle: [[cellData objectAtIndex: 3] objectAtIndex: i]];
    }
    [popover addButtonWithTitle: __T(@"Cancel")];
    popover.cancelButtonIndex = popover.numberOfButtons - 1;
    currentPathForPopover     = indexPath;
    theTableCell              = newCell;
    [popover showInView: self.parentViewController.parentViewController.view];
    break;

  case 2:       // we're on a cell that we need to toggle the checkmark on
    curValue                     = [[(PKSettings *)[PKSettings instance] loadSetting: [cellData objectAtIndex: 2]] boolValue];
    [[PKSettings instance] saveSetting: [cellData objectAtIndex: 2] valueForSetting: (!curValue ? @"YES": @"NO")];
    [[PKSettings instance] reloadSettings];
    newCell.detailTextLabel.text = (!curValue) ? __T(@"Yes") : __T(@"No");

    break;

  case 3 :      // we're on a cell that we need to display a popover for, with lookup
    popover = [[UIActionSheet alloc] initWithTitle: [cellData objectAtIndex: 0]
                                          delegate: self
                                 cancelButtonTitle: nil
                            destructiveButtonTitle: nil
                                 otherButtonTitles: nil];

    for (int i = 0; i < [[cellData objectAtIndex: 4] count]; i++)
    {
      [popover addButtonWithTitle: [[cellData objectAtIndex: 4] objectAtIndex: i]];
    }
    [popover addButtonWithTitle: __T(@"Cancel")];
    popover.cancelButtonIndex = popover.numberOfButtons - 1;
    currentPathForPopover     = indexPath;
    theTableCell              = newCell;
    [popover showInView: self.parentViewController.parentViewController.view];
    break;
  }
  [tableView deselectRowAtIndexPath: indexPath animated: YES];
}

# pragma mark -
# pragma mark ActionSheet (Popover) methods

/**
 *
 * Handle selecting an option for an actionsheet we've shown previously. Depending on the
 * currently selected index path, we will either use the result as labeled in the sheet, or
 * look it up.
 *
 */
-(void)actionSheet: (UIActionSheet *) actionSheet didDismissWithButtonIndex: (NSInteger) buttonIndex
{
  NSUInteger section = [currentPathForPopover section];
  NSUInteger row     = [currentPathForPopover row];
  NSArray *cellData  = [[settingsGroup objectAtIndex: section] objectAtIndex: row];
  NSString *selectedValue;
  NSString *settingValue;

  // handle Cancel being pressed...
  if (buttonIndex == actionSheet.cancelButtonIndex)
  {
    currentPathForPopover = nil;
    theTableCell          = nil;
    return;     // no action
  }

  switch ([[cellData objectAtIndex: 1] intValue])
  {
  case 1:       // we're a simple copy-the-value popover -- no lookup.
    selectedValue                     = [[cellData objectAtIndex: 3] objectAtIndex: buttonIndex];
    [[PKSettings instance] saveSetting: [cellData objectAtIndex: 2] valueForSetting: selectedValue];
    [[PKSettings instance] reloadSettings];
    theTableCell.detailTextLabel.text = selectedValue;
    break;

  case 3:       // we're a lookup popover
    selectedValue                     = [[cellData objectAtIndex: 4] objectAtIndex: buttonIndex];
    settingValue                      = [[cellData objectAtIndex: 3] objectAtIndex: buttonIndex];
    [[PKSettings instance] saveSetting: [cellData objectAtIndex: 2] valueForSetting: settingValue];
    [[PKSettings instance] reloadSettings];
    theTableCell.detailTextLabel.text = selectedValue;
    break;
  }

  if ([[cellData objectAtIndex: 2] isEqual: @"text-theme"])
  {
    [self updateAppearanceForTheme];
    [[[[PKAppDelegate instance] segmentController].viewControllers objectAtIndex: 0] updateAppearanceForTheme];
    [[[[PKAppDelegate instance] segmentController].viewControllers objectAtIndex: 1] updateAppearanceForTheme];
    [[[[PKAppDelegate instance] segmentController].viewControllers objectAtIndex: 2] updateAppearanceForTheme];
    [[[[PKAppDelegate instance] segmentController].viewControllers objectAtIndex: 3] updateAppearanceForTheme];
  }

  theTableCell          = nil;
  currentPathForPopover = nil;
}

-(void) didReceiveRightSwipe: (UISwipeGestureRecognizer *) gestureRecognizer
{
  CGPoint p = [gestureRecognizer locationInView: self.tableView];

  if (p.x < 75)
  {
    // show the sidebar, if not visible
    ZUUIRevealController *rc = (ZUUIRevealController *)self.parentViewController.parentViewController.parentViewController;

    if ([rc currentFrontViewPosition] == FrontViewPositionLeft)
    {
      [rc revealToggle: nil];
      return;
    }
  }
}

-(void) didReceiveLeftSwipe: (UISwipeGestureRecognizer *) gestureRecognizer
{
  // hide the sidebar, if visible
  ZUUIRevealController *rc = (ZUUIRevealController *)self.parentViewController.parentViewController.parentViewController;

  if ([rc currentFrontViewPosition] == FrontViewPositionRight)
  {
    [rc revealToggle: nil];
    return;
  }
}

-(void) installedBiblesChanged
{
  [self reloadSettingsArray];
  [self.tableView reloadData];
}

@end