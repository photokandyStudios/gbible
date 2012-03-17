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

@interface PKSettingsController ()

@end

@implementation PKSettingsController

    @synthesize layoutSettings;
    @synthesize textSettings;
    @synthesize iCloudSettings;
    @synthesize importSettings;
    @synthesize exportSettings;
    
    @synthesize settingsGroup;
    

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // set our title
        [self.navigationItem setTitle:@"Settings"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    layoutSettings = [NSArray arrayWithObjects: [NSArray arrayWithObjects: @"Typeface", [NSNumber numberWithInt:1], PK_SETTING_FONTFACE, 
                                                                           [NSArray arrayWithObjects: @"Arial", @"Courier", @"Georgia", @"Helvetica", @"Verdana", nil], nil],
                                                [NSArray arrayWithObjects: @"Font Size", [NSNumber numberWithInt:3], PK_SETTING_FONTSIZE, 
                                                                           [NSArray arrayWithObjects: [NSNumber numberWithInt:6],
                                                                                                      [NSNumber numberWithInt:7],
                                                                                                      [NSNumber numberWithInt:8],
                                                                                                      [NSNumber numberWithInt:9],
                                                                                                      [NSNumber numberWithInt:10],
                                                                                                      [NSNumber numberWithInt:11],
                                                                                                      [NSNumber numberWithInt:12],
                                                                                                      [NSNumber numberWithInt:14],
                                                                                                      [NSNumber numberWithInt:16],
                                                                                                      [NSNumber numberWithInt:18],
                                                                                                      [NSNumber numberWithInt:20],
                                                                                                      [NSNumber numberWithInt:22], nil],
                                                                           [NSArray arrayWithObjects: @"6pt", @"7pt", @"8pt", @"9pt", @"10pt", @"11pt", @"12pt",
                                                                                                      @"14pt", @"16pt", @"18pt", @"20pt", @"22pt", nil] ,nil],
                                                [NSArray arrayWithObjects: @"Line Spacing", [NSNumber numberWithInt:3], PK_SETTING_LINESPACING, 
                                                                           [NSArray arrayWithObjects: [NSNumber numberWithInt:PK_LS_CRAMPED],
                                                                                                      [NSNumber numberWithInt:PK_LS_TIGHT],
                                                                                                      [NSNumber numberWithInt:PK_LS_NORMAL],
                                                                                                      [NSNumber numberWithInt:PK_LS_ONEQUARTER],
                                                                                                      [NSNumber numberWithInt:PK_LS_ONEHALF],
                                                                                                      [NSNumber numberWithInt:PK_LS_DOUBLE], nil],
                                                                           [NSArray arrayWithObjects: @"Cramped", @"Tight", @"Normal", @"One-Quarter",
                                                                                                      @"One-Half", @"Double", nil], nil ],
                                                [NSArray arrayWithObjects: @"Verse Spacing", [NSNumber numberWithInt:3], PK_SETTING_VERSESPACING, 
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
    iCloudSettings = [NSArray arrayWithObjects: [NSArray arrayWithObjects: @"Enable iCloud?", [NSNumber numberWithInt:2], PK_SETTING_USEICLOUD, nil],
                                                nil];
    importSettings = [NSArray arrayWithObjects: [NSArray arrayWithObjects: @"Import Notes", [NSNumber numberWithInt:0], nil, nil ],
                                                [NSArray arrayWithObjects: @"Import Bookmarks", [NSNumber numberWithInt:0],nil, nil ],
                                                [NSArray arrayWithObjects: @"Import Highlights", [NSNumber numberWithInt:0],nil, nil ],
                                                [NSArray arrayWithObjects: @"Import Everything", [NSNumber numberWithInt:0], nil, nil ],
                                                nil];
    exportSettings = [NSArray arrayWithObjects: [NSArray arrayWithObjects: @"Export", [NSNumber numberWithInt:0], nil, nil ],
                                                nil];
    
    settingsGroup = [NSArray arrayWithObjects: textSettings, layoutSettings, iCloudSettings,
                                               exportSettings, importSettings, nil ];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    settingsGroup = nil;
    exportSettings = nil;
    importSettings = nil;
    iCloudSettings = nil;
    textSettings = nil;
    layoutSettings = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark -
#pragma mark Table View Data Source Methods

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section)
    {
        case 0: return @"Text";
                break;
        case 1: return @"Layout";
                break;
        case 2: return @"Synchronization";
                break;
        case 3: return @"Export";
                break;
        case 4: return @"Import";
                break;
        default:return @"Undefined";
                break;
    }
    return @"Undefined";
}

-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    switch (section)
    {
        case 0: return @"";
                break;
        case 1: return @"";
                break;
        case 2: return @"Enable iCloud to synchronize your data across multiple devices. It is suggested \
                         that you export your data prior to enabling iCloud synchronization.";
                break;
        case 3: return @"Export will create a file named 'export_MMDDYYYY_HHMMSS.dat' that you can download \
                         when your device is connected to iTunes. You can then save this file in a safe \
                         place, or use it to import data to another device.";
                break;
        case 4: return @"Before importing, connect your device to iTunes and copy the file you want to \
                         import. Be sure to name it 'import.dat'. Then select the desired option above. \
                         You can import more than one time from the same file.";
                break;
        default:return @"Undefined";
                break;
    }
    return @"Undefined";
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return [settingsGroup count];
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.settingsGroup objectAtIndex:section] count];
}

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

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    NSArray *cellData = [[settingsGroup objectAtIndex:section] objectAtIndex:row];
    BOOL curValue;
    UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
    
    switch ( [[cellData objectAtIndex:1] intValue] )
    {
        case 0: // we're on a "nothing cell", but these will do actions...
                break;
        case 1: // we're on a cell that wants to display a popover/actionsheet (no lookup)
                break;
        case 2: // we're on a cell that we need to toggle the checkmark on
                curValue = [ [ (PKSettings *)[PKSettings instance] loadSetting:[cellData objectAtIndex:2] ] boolValue];
                [[PKSettings instance] saveSetting:[cellData objectAtIndex:2] valueForSetting: (!curValue?@"YES":@"NO")];
                [[PKSettings instance] reloadSettings];
                newCell.accessoryType = (!curValue)?UITableViewCellAccessoryCheckmark:UITableViewCellAccessoryNone;
                
                break;
        case 3: // we're on a cell that we need to display a popover for, with lookup
                break;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
