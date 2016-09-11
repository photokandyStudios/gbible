//
//  PKGenericSettingsViewController.m
//  gbible
//
//  Created by Kerri Shotts on 4/11/16.
//  Copyright © 2016 photoKandy Studios LLC. All rights reserved.
//

#import "PKGenericSettingsViewController.h"
#import "PKConstants.h"
#import "PKSettings.h"
#import "PKAppDelegate.h"
#import "NSString+FontAwesome.h"
#import "NSString+PKFont.h"

@interface PKGenericSettingsViewController ()

@end

@implementation PKGenericSettingsViewController
{
  NSArray * /**__strong**/ _settingsGroup;
}

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
  self.tableView.separatorColor  = [PKSettings PKTextColor];
  self.tableView.separatorStyle  = UITableViewCellSeparatorStyleSingleLine;
  
  [self.tableView reloadData];
}

-(void)reloadSettingsArray
{
  _settingsGroup = @[];
}



- (void)viewDidLoad {
  [super viewDidLoad];
  [self.tableView setBackgroundView: nil];
  self.tableView.backgroundColor = [PKSettings PKPageColor];
  [self reloadSettingsArray];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidUnload
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  _settingsGroup   = nil;
}

-(void) viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  [self updateAppearanceForTheme];
  
}
-(void) viewDidAppear: (BOOL) animated
{
  [super viewDidAppear: animated];
  [PKAppDelegate sharedInstance].bibleViewController.dirty = YES;
  [self calculateShadows];
}

-(void) didRotateFromInterfaceOrientation: (UIInterfaceOrientation) fromInterfaceOrientation
{
  [super didRotateFromInterfaceOrientation: fromInterfaceOrientation];
  [self calculateShadows];
  [self.tableView reloadData];
}

-(BOOL)shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) interfaceOrientation
{
  return YES;
}

-(NSString *)getHeadingForSection:(NSInteger) section
{
  return @"Undefined";
}

-(NSString *)getFootingForSection:(NSInteger) section
{
  return @"";
}

#pragma mark -
#pragma mark Table View Data Source Methods
-(NSString *)tableView: (UITableView *) tableView titleForHeaderInSection: (NSInteger) section
{
  return [self getHeadingForSection:section];
}

-(NSString *)tableView: (UITableView *) tableView titleForFooterInSection: (NSInteger) section
{
  return [self getFootingForSection:section];
}

-(NSInteger) numberOfSectionsInTableView: (UITableView *) tableView
{
  return [_settingsGroup count];
}

-(NSInteger) tableView: (UITableView *) tableView numberOfRowsInSection: (NSInteger) section
{
  return [_settingsGroup[section] count];
}

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
  NSArray *cellData  = _settingsGroup[section][row];
  
  cell.textLabel.text      = cellData[0];
  cell.textLabel.numberOfLines=0;
  cell.textLabel.textColor = [PKSettings PKTextColor];
  cell.textLabel.font = [UIFont fontWithName:[PKSettings boldInterfaceFont] size:16];
  cell.detailTextLabel.font = [UIFont fontWithName:[PKSettings interfaceFont] size:16];
  cell.accessoryType       = UITableViewCellAccessoryNone;
  cell.backgroundColor     = [UIColor clearColor];
  
  switch ((PK_SETTINGS_FIELD_TYPE)[cellData[1] intValue])
  {
    case TEXT_ONLY:      // the nothing case. :-)
    case TEXT_WITH_ACTION:
      cell.detailTextLabel.text = @"";
      break;
      
    case URL_ONLY:
      cell.detailTextLabel.text = @"";
      break;

    case TEXT_AND_SPINNER:
      break;

    case TEXT_AND_VALUE: // here we want the current setting
      
      cell.detailTextLabel.text = [[PKSettings instance] loadSetting: cellData[2]];
      break;
      
    case TEXT_AND_YESNO:  // here we want to display YES or NO
                  // FIX ISSUE #48
      cell.detailTextLabel.text = __T(@"No");
      
      if ([[[PKSettings instance] loadSetting: cellData[2]] boolValue])
      {
        cell.detailTextLabel.text = __T(@"Yes");
      }
      break;
      
    case TEXT_AND_LOOKUP: // here we want current settings, and lookup
      ;
      // first, get the setting
      NSString *theSetting      = [[PKSettings instance] loadSetting: cellData[2]];
      // now, convert it to an NSNumber
      NSNumber *theSettingValue = @([theSetting integerValue]);
      // find it in the cell's 3rd array
      NSUInteger theIndex              = [cellData[3] indexOfObject: theSettingValue];
      
      // now look up the corresponding text in the 4th array
      if (theIndex != NSNotFound)
      {
        NSString *theValue = cellData[4][theIndex];
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





@end
