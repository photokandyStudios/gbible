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

@interface PKSettingsController ()

@end

@implementation PKSettingsController

    @synthesize layoutSettings;
    @synthesize textSettings;
    @synthesize iCloudSettings;
    @synthesize importSettings;
    @synthesize exportSettings;
    
    @synthesize settingsGroup;
    
    @synthesize currentPathForPopover;
    @synthesize theTableCell;

/**
 *
 * Initialize our view, namely to set our title.
 *
 */
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // set our title
        [self.navigationItem setTitle:@"Settings"];
    }
    return self;
}

/**
 *
 * Called when the view has finished loading. Here we create our 
 * settings arrays.
 *
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.tableView setBackgroundView:nil];
    self.tableView.backgroundColor = [UIColor colorWithRed:0.945098 green:0.933333 blue:0.898039 alpha:1];
    layoutSettings = [NSArray arrayWithObjects: [NSArray arrayWithObjects: @"Typeface", [NSNumber numberWithInt:1], PK_SETTING_FONTFACE, 
                                                                           [NSArray arrayWithObjects: @"AmericanTypewriter",
                                                                                                      @"Arial", 
                                                                                                      @"Baskerville",
                                                                                                      @"Courier",
                                                                                                      @"Georgia", 
                                                                                                      @"Helvetica",
                                                                                                      @"Helvetica-Light",
                                                                                                      @"HoeflerText-Regular",
                                                                                                      @"Marion-Regular",
                                                                                                      @"Optima-Regular",
                                                                                                      @"Palatino-Roman",
                                                                                                      @"Verdana", nil], nil],
                                                [NSArray arrayWithObjects: @"Font Size", [NSNumber numberWithInt:3], PK_SETTING_FONTSIZE, 
                                                                           [NSArray arrayWithObjects: //[NSNumber numberWithInt:6],
                                                                                                      //[NSNumber numberWithInt:7],
                                                                                                      //[NSNumber numberWithInt:8],
                                                                                                      [NSNumber numberWithInt:9],
                                                                                                      [NSNumber numberWithInt:10],
                                                                                                      [NSNumber numberWithInt:11],
                                                                                                      [NSNumber numberWithInt:12],
                                                                                                      [NSNumber numberWithInt:14],
                                                                                                      [NSNumber numberWithInt:16],
                                                                                                      [NSNumber numberWithInt:18],
                                                                                                      [NSNumber numberWithInt:20],
                                                                                                      [NSNumber numberWithInt:22], 
                                                                                                      [NSNumber numberWithInt:26],
                                                                                                      [NSNumber numberWithInt:32],
                                                                                                      [NSNumber numberWithInt:48], nil],
                                                                           [NSArray arrayWithObjects: //@"6pt", @"7pt", @"8pt", 
                                                                                                      @"9pt", @"10pt", @"11pt", @"12pt",
                                                                                                      @"14pt", @"16pt", @"18pt", @"20pt", @"22pt", 
                                                                                                      @"26pt", @"32pt", @"48pt",
                                                                                                      nil] ,nil],
                                                [NSArray arrayWithObjects: @"Inter-line Spacing", [NSNumber numberWithInt:3], PK_SETTING_LINESPACING, 
                                                                           [NSArray arrayWithObjects: [NSNumber numberWithInt:PK_LS_CRAMPED],
                                                                                                      [NSNumber numberWithInt:PK_LS_TIGHT],
                                                                                                      [NSNumber numberWithInt:PK_LS_NORMAL],
                                                                                                      [NSNumber numberWithInt:PK_LS_ONEQUARTER],
                                                                                                      [NSNumber numberWithInt:PK_LS_ONEHALF],
                                                                                                      [NSNumber numberWithInt:PK_LS_DOUBLE], nil],
                                                                           [NSArray arrayWithObjects: @"Cramped", @"Tight", @"Normal", @"One-Quarter",
                                                                                                      @"One-Half", @"Double", nil], nil ],
                                                [NSArray arrayWithObjects: @"Line Spacing", [NSNumber numberWithInt:3], PK_SETTING_VERSESPACING, 
                                                                           [NSArray arrayWithObjects: [NSNumber numberWithInt:PK_VS_NONE],
                                                                                                      [NSNumber numberWithInt:PK_VS_SINGLE],
                                                                                                      [NSNumber numberWithInt:PK_VS_DOUBLE], nil],
                                                                           [NSArray arrayWithObjects: @"No Spacing", @"Single Spacing", @"Double Spacing", nil], nil ],
                                                [NSArray arrayWithObjects: @"Column Widths", [NSNumber numberWithInt:3], PK_SETTING_COLUMNWIDTHS, 
                                                                           [NSArray arrayWithObjects: [NSNumber numberWithInt:PK_CW_WIDEGREEK],
                                                                                                      [NSNumber numberWithInt:PK_CW_WIDEENGLISH],
                                                                                                      [NSNumber numberWithInt:PK_CW_EQUAL], nil],
                                                                           [NSArray arrayWithObjects: @"Wide Greek Column", @"Wide English Column", @"Equal Columns", nil], nil ],
                                                nil];
    textSettings = [NSArray arrayWithObjects: [NSArray arrayWithObjects: @"Greek Text", [NSNumber numberWithInt:3], PK_SETTING_GREEKTEXT, 
                                                                           [NSArray arrayWithObjects: [NSNumber numberWithInt:PK_BIBLETEXT_BYZ],
                                                                                                      [NSNumber numberWithInt:PK_BIBLETEXT_BYZP],
                                                                                                      [NSNumber numberWithInt:PK_BIBLETEXT_TIS],
                                                                                                      [NSNumber numberWithInt:PK_BIBLETEXT_TR],
                                                                                                      [NSNumber numberWithInt:PK_BIBLETEXT_TRP],
                                                                                                      [NSNumber numberWithInt:PK_BIBLETEXT_WH],
                                                                                                      [NSNumber numberWithInt:PK_BIBLETEXT_WHP], nil],
                                                                           [NSArray arrayWithObjects: @"Byzantine", @"Byzantine (Parsed)",
                                                                                                      @"Tischendorf 8th ed.",
                                                                                                      @"Textus Receptus", @"Textus Receptus (Parsed)",
                                                                                                      @"Westcott-Hort", @"Westcott-Hort (Parsed)", nil], nil],
                                              [NSArray arrayWithObjects: @"English Text", [NSNumber numberWithInt:3], PK_SETTING_ENGLISHTEXT, 
                                                                           [NSArray arrayWithObjects: [NSNumber numberWithInt:PK_BIBLETEXT_KJV],
                                                                                                      [NSNumber numberWithInt:PK_BIBLETEXT_YLT], nil],
                                                                           [NSArray arrayWithObjects: @"King James/Authorized Version",
                                                                                                      @"Young's Literal Translation", nil], nil],
                                              [NSArray arrayWithObjects: @"Transliterate Greek?", [NSNumber numberWithInt:2], PK_SETTING_TRANSLITERATE, nil],
                                              [NSArray arrayWithObjects: @"Show Inline Notes?", [NSNumber numberWithInt:2], PK_SETTING_INLINENOTES, nil],
                                              [NSArray arrayWithObjects: @"Show Morphology?", [NSNumber numberWithInt:2], PK_SETTING_SHOWMORPHOLOGY, nil],
                                              nil];
   // iCloudSettings = [NSArray arrayWithObjects: [NSArray arrayWithObjects: @"Enable iCloud?", [NSNumber numberWithInt:2], PK_SETTING_USEICLOUD, nil],
    //                                            nil];
    importSettings = [NSArray arrayWithObjects: [NSArray arrayWithObjects: @"Import Annotations", [NSNumber numberWithInt:0], nil, nil ],
//                                                [NSArray arrayWithObjects: @"Import Bookmarks", [NSNumber numberWithInt:0],nil, nil ],
                                                [NSArray arrayWithObjects: @"Import Highlights", [NSNumber numberWithInt:0],nil, nil ],
                                                [NSArray arrayWithObjects: @"Import Everything", [NSNumber numberWithInt:0], nil, nil ],
                                                nil];
    exportSettings = [NSArray arrayWithObjects: [NSArray arrayWithObjects: @"Export", [NSNumber numberWithInt:0], nil, nil ],
                                                nil];
    
    settingsGroup = [NSArray arrayWithObjects: textSettings, layoutSettings, // iCloudSettings,
                                               exportSettings, importSettings, nil ];


    UISwipeGestureRecognizer *swipeRight=[[UISwipeGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(didReceiveRightSwipe:)];
    UISwipeGestureRecognizer *swipeLeft =[[UISwipeGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(didReceiveLeftSwipe:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    swipeLeft.direction  = UISwipeGestureRecognizerDirectionLeft;
    [swipeRight setNumberOfTouchesRequired:1];
    [swipeLeft  setNumberOfTouchesRequired:1];
    [self.tableView addGestureRecognizer:swipeRight];
    [self.tableView addGestureRecognizer:swipeLeft];

    UIBarButtonItem *changeReference = [[UIBarButtonItem alloc]
                                        initWithImage:[UIImage imageNamed:@"Listb.png"] 
                                        style:UIBarButtonItemStylePlain 
                                        target:self.parentViewController.parentViewController.parentViewController
                                        action:@selector(revealToggle:)];

    if ([changeReference respondsToSelector:@selector(setTintColor:)])
    {
        changeReference.tintColor = [UIColor colorWithRed:0.250980 green:0.282352 blue:0.313725 alpha:1.0];
    }
    changeReference.accessibilityLabel = @"Go to passage";
    self.navigationItem.leftBarButtonItem = changeReference;
    
}

/**
 *
 * release our settings arrays
 *
 */
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    settingsGroup = nil;
    exportSettings = nil;
    importSettings = nil;
   // iCloudSettings = nil;
    textSettings = nil;
    layoutSettings = nil;
}

/**
 *
 * We support all orientations
 *
 */
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
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
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section)
    {
        case 0: return @"Text";
                break;
        case 1: return @"Layout";
                break;
      //  case 2: return @"Synchronization";
      //          break;
        case 2: return @"Export";
                break;
        case 3: return @"Import";
                break;
        default:return @"Undefined";
                break;
    }
    return @"Undefined";
}

/**
 *
 * Return the footer for each group of cells. Note that as currently written (with \ 
 * linebreaks in strings), iOS renders some of the text strangely. TODO: fix.
 *
 */
-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    switch (section)
    {
        case 0: return @"";
                break;
        case 1: return @"";
                break;
//        case 2: return @"Enable iCloud to synchronize your data across multiple devices. It is suggested \
//                         that you export your data prior to enabling iCloud synchronization.";
//                break;
        case 2: return @"Export will create a file named 'export' and the current date and time that you can download when your device is connected to iTunes. You can then save this file in a safe place, or use it to import data to another device.";
                break;
        case 3: return @"Before importing, connect your device to iTunes and copy the file you want to import. Be sure to name it 'import.dat'. Then select the desired option above. You can import more than one time from the same file.";
                break;
        default:return @"Undefined";
                break;
    }
    return @"Undefined";
}

/**
 *
 * Return the number of sections we have
 *
 */
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return [settingsGroup count];
}

/**
 *
 * Return the number of rows in a particular section
 *
 */
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.settingsGroup objectAtIndex:section] count];
}

/**
 *
 * Generate the cell for a given index path. This cell will be based on our settings array defined
 * and filled earlier, and may contain accessory views, popups, and more.
 *
 */
-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *settingsCellID = @"PKSettingsCellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:settingsCellID];
    if (!cell)
    {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleValue1
                reuseIdentifier:settingsCellID];
    }
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    NSArray *cellData = [[settingsGroup objectAtIndex:section] objectAtIndex:row];
    
    cell.textLabel.text = [cellData objectAtIndex:0];
    cell.accessoryType = UITableViewCellAccessoryNone;
    switch ( [[cellData objectAtIndex:1] intValue] )
    {
        case 0: // the nothing case. :-)
                cell.detailTextLabel.text = @"";
                break;
        case 1: // here we want a disclosure arrow and the current setting
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.detailTextLabel.text = [ (PKSettings *)[PKSettings instance] loadSetting:[cellData objectAtIndex:2] ];
                break;
        case 2: // here we want to display a checkbox if YES; none if NO
                cell.accessoryType = UITableViewCellAccessoryNone;
                if ( [ [ (PKSettings *)[PKSettings instance] loadSetting:[cellData objectAtIndex:2] ] boolValue] )
                {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
                break;
        case 3: // here we want a disclosure arrow, current settings, and lookup
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                
                // first, get the setting
                NSString *theSetting = [ (PKSettings *)[PKSettings instance] loadSetting:[cellData objectAtIndex:2] ];
                // now, convert it to an NSNumber
                NSNumber *theSettingValue = [NSNumber numberWithInt:[theSetting integerValue]];
                // find it in the cell's 3rd array
                int theIndex = [[cellData objectAtIndex:3] indexOfObject:theSettingValue];
                // now look up the corresponding text in the 4th array
                NSString *theValue = [ [cellData objectAtIndex:4] objectAtIndex: theIndex ];
                cell.detailTextLabel.text = theValue;
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
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIActionSheet *popover;
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    NSArray *cellData = [[settingsGroup objectAtIndex:section] objectAtIndex:row];
    BOOL curValue;
    UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
    
    NSString *title = @"Operation";

    switch ( [[cellData objectAtIndex:1] intValue] )
    {
        case 0: {// we're on a "nothing cell", but these will do actions...
                if (section == 2) 
                { 
                    title = @"Export Operation";
                    [(PKDatabase *)[PKDatabase instance] exportAll]; 
                }
                if (section == 3)
                {
                    title = @"Import Operation";
                    if (row==0) { [(PKDatabase *)[PKDatabase instance] importNotes]; }
                    if (row==1) { [(PKDatabase *)[PKDatabase instance] importHighlights]; }
                    if (row==2) { 
                                  [(PKDatabase *)[PKDatabase instance] importNotes]; 
                                  [(PKDatabase *)[PKDatabase instance] importHighlights]; 
                                  [(PKDatabase *)[PKDatabase instance] importSettings]; 
                                }
                    [[[[PKAppDelegate instance] segmentController].viewControllers objectAtIndex:1] reloadHighlights];
                    [[[[PKAppDelegate instance] segmentController].viewControllers objectAtIndex:2] reloadNotes];
                    [self.tableView reloadData]; // settings may be different.
                }
                UIAlertView *theAlertView = [[UIAlertView alloc] initWithTitle:title message:@"Done!" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                [theAlertView show];
                break;}
        case 1: // we're on a cell that wants to display a popover/actionsheet (no lookup)
                popover = [[UIActionSheet alloc] initWithTitle: [cellData objectAtIndex:0]
                                                 delegate: self
                                                 cancelButtonTitle: nil
                                                 destructiveButtonTitle: nil
                                                 otherButtonTitles: nil ];
                for (int i=0; i<[[cellData objectAtIndex:3] count]; i++)
                {
                    [popover addButtonWithTitle:[[cellData objectAtIndex:3] objectAtIndex:i]];
                }
                [popover addButtonWithTitle:@"Cancel"];
                popover.cancelButtonIndex = popover.numberOfButtons - 1;
                currentPathForPopover = indexPath;
                theTableCell = newCell;
                [popover showInView:super.view];
//                [popover showFromRect:theTableCell.frame inView:self.view animated:YES];
                break;
        case 2: // we're on a cell that we need to toggle the checkmark on
                curValue = [ [ (PKSettings *)[PKSettings instance] loadSetting:[cellData objectAtIndex:2] ] boolValue];
                [[PKSettings instance] saveSetting:[cellData objectAtIndex:2] valueForSetting: (!curValue?@"YES":@"NO")];
                [[PKSettings instance] reloadSettings];
                newCell.accessoryType = (!curValue)?UITableViewCellAccessoryCheckmark:UITableViewCellAccessoryNone;
                
                break;
        case 3: // we're on a cell that we need to display a popover for, with lookup
                popover = [[UIActionSheet alloc] initWithTitle: [cellData objectAtIndex:0]
                                                 delegate: self
                                                 cancelButtonTitle: nil
                                                 destructiveButtonTitle: nil
                                                 otherButtonTitles: nil ];
                for (int i=0; i<[[cellData objectAtIndex:4] count]; i++)
                {
                    [popover addButtonWithTitle:[[cellData objectAtIndex:4] objectAtIndex:i]];
                }
                [popover addButtonWithTitle:@"Cancel"];
                popover.cancelButtonIndex = popover.numberOfButtons - 1;
                currentPathForPopover = indexPath;
                theTableCell = newCell;
                [popover showInView:self.parentViewController.parentViewController.view];
//                [popover showFromRect:theTableCell.frame inView:self.view animated:YES];
                break;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSUInteger section = [currentPathForPopover section];
    NSUInteger row = [currentPathForPopover row];
    NSArray *cellData = [[settingsGroup objectAtIndex:section] objectAtIndex:row];
    NSString *selectedValue;
    NSString *settingValue;
    
    // handle Cancel being pressed...
    if (buttonIndex == actionSheet.cancelButtonIndex)
    {
        currentPathForPopover = nil;
        theTableCell = nil;
        return; // no action
    }
    switch ( [[cellData objectAtIndex:1] intValue] )
    {
        case 1: // we're a simple copy-the-value popover -- no lookup.
                selectedValue = [[cellData objectAtIndex:3] objectAtIndex:buttonIndex];
                [[PKSettings instance] saveSetting:[cellData objectAtIndex:2] valueForSetting: selectedValue];
                [[PKSettings instance] reloadSettings];
                theTableCell.detailTextLabel.text = selectedValue;
                break;
        case 3: // we're a lookup popover
                selectedValue = [[cellData objectAtIndex:4] objectAtIndex:buttonIndex];
                settingValue  = [[cellData objectAtIndex:3] objectAtIndex:buttonIndex];
                [[PKSettings instance] saveSetting:[cellData objectAtIndex:2] valueForSetting: settingValue];
                [[PKSettings instance] reloadSettings];
                theTableCell.detailTextLabel.text = selectedValue;
                break;
    }
    

    theTableCell = nil;
    currentPathForPopover = nil;
}

-(void) didReceiveRightSwipe:(UISwipeGestureRecognizer*)gestureRecognizer
{
    CGPoint p = [gestureRecognizer locationInView:self.tableView];
    if (p.x < 75)
    {
        // show the sidebar, if not visible
        ZUUIRevealController *rc = (ZUUIRevealController*) self.parentViewController.parentViewController.parentViewController;
        if ( [rc currentFrontViewPosition] == FrontViewPositionLeft )
        {
            [rc revealToggle:nil];
            return;
        }
    }
}

-(void) didReceiveLeftSwipe:(UISwipeGestureRecognizer*)gestureRecognizer
{
    CGPoint p = [gestureRecognizer locationInView:self.tableView];
//    if (p.x < 75)
//    {
        // hide the sidebar, if visible
        ZUUIRevealController *rc = (ZUUIRevealController*) self.parentViewController.parentViewController.parentViewController;
        if ( [rc currentFrontViewPosition] == FrontViewPositionRight )
        {
            [rc revealToggle:nil];
            return;
        }
//    }
}

@end
