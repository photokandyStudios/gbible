//
//  PKLayoutController.m
//  gbible
//
//  Created by Kerri Shotts on 12/14/12.
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
#import "PKLayoutController.h"
#import "PKSettings.h"
#import "NSString+FontAwesome.h"
#import "CoolButton.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "PKAppDelegate.h"
#import "UIFont+Utility.h"
#import "PKAppDelegate.h"
#import "UIImage+PKUtility.h"

@interface PKLayoutController ()

@end

@implementation PKLayoutController
{
  UILabel */**__strong**/ _previewLabel;
  UILabel */**__strong**/ _label1;
  UILabel */**__strong**/ _fontSizeLabel;
  UILabel */**__strong**/ _greekFontLabel;
  UILabel */**__strong**/ _englishFontLabel;
  UILabel */**__strong**/ _rowSpacingLabel;
  UIStepper */**__strong**/ _fontStepper;
  UISlider */**__strong**/ _brightnessSlider;
  UISegmentedControl */**__strong**/ _rowSpacingSelector;
  UISegmentedControl */**__strong**/ _lineSpacingSelector;
  UISegmentedControl */**__strong**/ _columnSelector;
  UITableView */**__strong**/ _englishFontPicker;
  UITableView */**__strong**/ _greekFontPicker;
  UIImageView */**__strong**/ _decreaseBrightnessLabel;
  UIImageView */**__strong**/ _increaseBrightnessLabel;
  UISegmentedControl */**__strong**/ _themeSelector;

  NSArray */**__strong**/ _fontNames;
  NSArray */**__strong**/ _fontSizes;
  NSArray */**__strong**/ _themeTextColors;
  NSArray */**__strong**/ _themeBgColors;
}

-(id)init
{
  self = [super init];

  if (self)
  {
    // Custom initialization
   // [self.view setFrame: CGRectMake(0, 0, 320, 460)];
  }
  return self;
}

-(void)viewDidLoad
{
  [super viewDidLoad];

  // Do any additional setup after loading the view.
  if (self.navigationItem)
  {
    UIBarButtonItem *closeButton =
      [[UIBarButtonItem alloc] initWithTitle: __T(@"Done") style: UIBarButtonItemStylePlain target: self action: @selector(closeMe:)
      ];
    self.navigationItem.rightBarButtonItem = closeButton;
    self.navigationItem.title              = __T(@"Text Settings");
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
    {
      self.extendedLayoutIncludesOpaqueBars  = YES;
      self.edgesForExtendedLayout = UIRectEdgeNone;
      [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:[PKSettings PKSecondaryPageColor]] forBarMetrics:UIBarMetricsDefault];
      self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    }
    else
    {
      self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
      [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:[PKSettings PKSecondaryPageColor]] forBarMetrics:UIBarMetricsDefault];
      [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:[PKSettings PKSecondaryPageColor]] forBarMetrics:UIBarMetricsDefaultPrompt];
      [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:[PKSettings PKSecondaryPageColor]] forBarMetrics:UIBarMetricsCompact];
      [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:[PKSettings PKSecondaryPageColor]] forBarMetrics:UIBarMetricsCompactPrompt];
    }
  }

  _fontSizes     = @[@9, @10, @11, @12, @14, @16, @18, @20, @22, @26, @32, @48];

  _themeBgColors = @[[UIColor colorWithRed: 0.945098 green: 0.933333 blue: 0.898039 alpha: 1],
                    [UIColor colorWithWhite: 0.90 alpha: 1],
                    [UIColor colorWithWhite: 0.10 alpha: 1],
                    [UIColor colorWithWhite: 0.10 alpha: 1]
                  ];
  _themeTextColors =  @[[UIColor colorWithRed: 0.341176 green: 0.223529 blue: 0.125490 alpha: 1.0],
                       [UIColor colorWithWhite: 0.10 alpha: 1],
                       [UIColor colorWithWhite: 0.65 alpha: 1.0],
                       [UIColor colorWithRed: 0.65 green: 0.50 blue: 0.00 alpha: 1.0]
                    ];

  self.view.backgroundColor = [UIColor colorWithWhite: 0.9 alpha: 1];
  if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
  {
      if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        self.view.backgroundColor = [UIColor clearColor];
  }

  _label1                 = [[UILabel alloc] initWithFrame: CGRectMake(10, 10, 160, 30)];
  _label1.text            = [NSString stringWithFormat: @"%@ %i", __T(@"Theme"), [[PKSettings instance] textTheme] + 1];
  _label1.textAlignment   = NSTextAlignmentLeft;
  _label1.font = [UIFont fontWithName:[PKSettings interfaceFont] size:16];
  _label1.backgroundColor = [UIColor clearColor];
  [self.view addSubview: _label1];

  CoolButton *theme1 = [[CoolButton alloc] initWithFrame: CGRectMake(10, 44, 49, 27)];
  [theme1 addTarget: self action: @selector(themeChanged:) forControlEvents: UIControlEventTouchUpInside];
  theme1.buttonColor = _themeBgColors[0];
  [theme1 setTag: 0];
  [theme1 setTitle: __T(@"1") forState: UIControlStateNormal];
  [theme1 setTitleColor: _themeTextColors[0] forState: UIControlStateNormal];
  [self.view addSubview: theme1];

  CoolButton *theme2 = [[CoolButton alloc] initWithFrame: CGRectMake(59, 44, 49, 27)];
  [theme2 addTarget: self action: @selector(themeChanged:) forControlEvents: UIControlEventTouchUpInside];
  theme2.buttonColor = _themeBgColors[1];
  [theme2 setTag: 1];
  [theme2 setTitle: __T(@"2") forState: UIControlStateNormal];
  [theme2 setTitleColor: _themeTextColors[1] forState: UIControlStateNormal];
  [self.view addSubview: theme2];

  CoolButton *theme3 = [[CoolButton alloc] initWithFrame: CGRectMake(108, 44, 49, 27)];
  [theme3 addTarget: self action: @selector(themeChanged:) forControlEvents: UIControlEventTouchUpInside];
  theme3.buttonColor = _themeBgColors[2];
  [theme3 setTag: 2];
  [theme3 setTitle: __T(@"3") forState: UIControlStateNormal];
  [theme3 setTitleColor: _themeTextColors[2] forState: UIControlStateNormal];
  [self.view addSubview: theme3];

  CoolButton *theme4 = [[CoolButton alloc] initWithFrame: CGRectMake(157, 44, 49, 27)];
  [theme4 addTarget: self action: @selector(themeChanged:) forControlEvents: UIControlEventTouchUpInside];
  theme4.buttonColor = _themeBgColors[3];
  [theme4 setTag: 3];
  [theme4 setTitle: __T(@"4") forState: UIControlStateNormal];
  [theme4 setTitleColor: _themeTextColors[3] forState: UIControlStateNormal];
  [self.view addSubview: theme4];

  _fontSizeLabel                 = [[UILabel alloc] initWithFrame: CGRectMake(216, 10, 94, 30)];
  _fontSizeLabel.font            = [UIFont fontWithName:[PKSettings boldInterfaceFont] size:20];
  _fontSizeLabel.textAlignment   = NSTextAlignmentCenter;
  _fontSizeLabel.text            = [NSString stringWithFormat: @"%ipt", [[PKSettings instance] textFontSize]];
  _fontSizeLabel.backgroundColor = [UIColor clearColor];
  [self.view addSubview: _fontSizeLabel];

  _fontStepper                   = [[UIStepper alloc] initWithFrame: CGRectMake(216, 44, 88, 60)];
  _fontStepper.value             = [_fontSizes indexOfObject: @([[PKSettings instance] textFontSize])];
  [_fontStepper setMinimumValue: 0];
  [_fontStepper setMaximumValue: 11];
  [_fontStepper addTarget: self action: @selector(fontSizeChanged:) forControlEvents: UIControlEventValueChanged];
  [self.view addSubview: _fontStepper];

  _greekFontLabel      = [[UILabel alloc] initWithFrame: CGRectMake(10, 80, 140, 20)];
  _greekFontLabel.text = __T(@"Greek Typeface");
  _greekFontLabel.backgroundColor             = [UIColor clearColor];
  _greekFontLabel.font                      = [UIFont fontWithName:[PKSettings interfaceFont] size:16];
  _greekFontLabel.textAlignment               = NSTextAlignmentCenter;
  _greekFontLabel.adjustsFontSizeToFitWidth   = YES;
  _greekFontLabel.minimumScaleFactor          = 0.1; //TODO: Check that this works for localization
  _greekFontLabel.numberOfLines               = 1;
  [self.view addSubview: _greekFontLabel];

  _englishFontLabel                           = [[UILabel alloc] initWithFrame: CGRectMake(170, 80, 140, 20)];
  _englishFontLabel.text                      = __T(@"English Typeface");
  _englishFontLabel.font                      = [UIFont fontWithName:[PKSettings interfaceFont] size:16];
  _englishFontLabel.backgroundColor           = [UIColor clearColor];
  _englishFontLabel.textAlignment             = NSTextAlignmentCenter;
  _englishFontLabel.adjustsFontSizeToFitWidth = YES;
  _englishFontLabel.minimumScaleFactor        = 0.1f; //TODO: check that this works for localization
  _englishFontLabel.numberOfLines             = 1;
  [self.view addSubview: _englishFontLabel];

  _greekFontPicker                            =
    [[UITableView alloc] initWithFrame: CGRectMake(00, 100, 165, 190) style: UITableViewStylePlain];
  _greekFontPicker.backgroundColor            = [UIColor clearColor];
  _greekFontPicker.backgroundView             = nil;
  _greekFontPicker.dataSource                 = self;
  _greekFontPicker.delegate                   = self;
  _greekFontPicker.rowHeight                  = 32;
  [self.view addSubview: _greekFontPicker];

  _englishFontPicker                 =
    [[UITableView alloc] initWithFrame: CGRectMake(155, 100, 165, 190) style: UITableViewStylePlain];
  _englishFontPicker.backgroundColor = [UIColor clearColor];
  _englishFontPicker.backgroundView  = nil;
  _englishFontPicker.dataSource      = self;
  _englishFontPicker.rowHeight                  = 32;
  _englishFontPicker.delegate        = self;

  [self.view addSubview: _englishFontPicker];

  _lineSpacingSelector = [[UISegmentedControl alloc] initWithFrame: CGRectMake(10, 300, 145, 30)];

  [_lineSpacingSelector insertSegmentWithImage: [UIImage imageNamed: @"vs0-30" withColor:[PKSettings PKTintColor]] atIndex: 0 animated: NO];
  [_lineSpacingSelector insertSegmentWithImage: [UIImage imageNamed: @"vs1-30" withColor:[PKSettings PKTintColor]] atIndex: 1 animated: NO];
  [_lineSpacingSelector insertSegmentWithImage: [UIImage imageNamed: @"vs2-30" withColor:[PKSettings PKTintColor]] atIndex: 2 animated: NO];
  _lineSpacingSelector.selectedSegmentIndex = ( [PKSettings instance].textVerseSpacing );
  [_lineSpacingSelector addTarget: self action: @selector(lineSpacingChanged:) forControlEvents: UIControlEventValueChanged];
  [self.view addSubview: _lineSpacingSelector];

  _columnSelector = [[UISegmentedControl alloc] initWithFrame: CGRectMake(165, 300, 145, 30)];
  [_columnSelector addTarget: self action: @selector(columnChanged:) forControlEvents: UIControlEventValueChanged];
  [_columnSelector insertSegmentWithImage: [UIImage imageNamed: @"wlc-30" withColor:[PKSettings PKTintColor]] atIndex: 0 animated: NO];
  [_columnSelector insertSegmentWithImage: [UIImage imageNamed: @"eqc-30" withColor:[PKSettings PKTintColor]] atIndex: 1 animated: NO];
  [_columnSelector insertSegmentWithImage: [UIImage imageNamed: @"wrc-30" withColor:[PKSettings PKTintColor]] atIndex: 2 animated: NO];

  switch ( [PKSettings instance].layoutColumnWidths )
  {
  case 0:
    _columnSelector.selectedSegmentIndex = 0;
    break;

  case 1:
    _columnSelector.selectedSegmentIndex = 2;
    break;

  case 2:
    _columnSelector.selectedSegmentIndex = 1;
    break;
  }
  [self.view addSubview: _columnSelector];

  _rowSpacingSelector = [[UISegmentedControl alloc] initWithFrame: CGRectMake(116, 340, 194, 30)];

  [_rowSpacingSelector insertSegmentWithImage: [UIImage imageNamed: @"ls100-30" withColor:[PKSettings PKTintColor]] atIndex: 0 animated: NO];
  [_rowSpacingSelector insertSegmentWithImage: [UIImage imageNamed: @"ls125-30" withColor:[PKSettings PKTintColor]] atIndex: 1 animated: NO];
  [_rowSpacingSelector insertSegmentWithImage: [UIImage imageNamed: @"ls150-30" withColor:[PKSettings PKTintColor]] atIndex: 2 animated: NO];
  [_rowSpacingSelector insertSegmentWithImage: [UIImage imageNamed: @"ls200-30" withColor:[PKSettings PKTintColor]] atIndex: 3 animated: NO];

  switch ( [PKSettings instance].textLineSpacing )
  {
  case 100: _rowSpacingSelector.selectedSegmentIndex = 0;
    break;

  case 125: _rowSpacingSelector.selectedSegmentIndex = 1;
    break;

  case 150: _rowSpacingSelector.selectedSegmentIndex = 2;
    break;

  case 200: _rowSpacingSelector.selectedSegmentIndex = 3;
    break;
  }
  [_rowSpacingSelector addTarget: self action: @selector(rowSpacingChanged:) forControlEvents: UIControlEventValueChanged];

  [self.view addSubview: _rowSpacingSelector];

  _rowSpacingLabel = [[UILabel alloc] initWithFrame: CGRectMake(10, 335, 96, 40)];
  _rowSpacingLabel.backgroundColor           = [UIColor clearColor];
  _rowSpacingLabel.text                      = __T(@"Line Spacing");
  _rowSpacingLabel.font                      = [UIFont fontWithName:[PKSettings interfaceFont] size:15];
  _rowSpacingLabel.textAlignment             = NSTextAlignmentLeft;
  _rowSpacingLabel.adjustsFontSizeToFitWidth = YES;
  _rowSpacingLabel.minimumScaleFactor        = 0.1f; //TODO: Check that this works for localization
  _rowSpacingLabel.numberOfLines             = 2;
  [self.view addSubview: _rowSpacingLabel];

  _decreaseBrightnessLabel                   = [[UIImageView alloc] initWithFrame: CGRectMake(10, 380, 30, 30)];
  _decreaseBrightnessLabel.backgroundColor   = [UIColor clearColor];
  _decreaseBrightnessLabel.accessibilityLabel= __T(@"Decrease Brightness");
  _decreaseBrightnessLabel.image             = [UIImage imageNamed:@"LessBrightness-30" withColor:[UIColor blackColor]];
  [self.view addSubview: _decreaseBrightnessLabel];

  _increaseBrightnessLabel                   = [[UIImageView alloc] initWithFrame: CGRectMake(280, 380, 30, 30)];
  _increaseBrightnessLabel.backgroundColor   = [UIColor clearColor];
  _increaseBrightnessLabel.accessibilityLabel= __T(@"Increase Brightness");
  _increaseBrightnessLabel.image             = [UIImage imageNamed:@"MoreBrightness-30" withColor:[UIColor blackColor]];
  [self.view addSubview: _increaseBrightnessLabel];

  _brightnessSlider                          = [[UISlider alloc] initWithFrame: CGRectMake(50, 380, 220, 30)];
  [_brightnessSlider setMinimumValue: 0];
  [_brightnessSlider setMaximumValue: 1];
  [_brightnessSlider setValue: [[UIScreen mainScreen] brightness]];
  [_brightnessSlider addTarget: self action: @selector(brightnessChanged:) forControlEvents: UIControlEventValueChanged];

  [self.view addSubview: _brightnessSlider];

  _fontNames = @[__T(@"Arev Sans"), __T(@"Arev Sans Bold"), __T(@"Courier"),    __T(@"Courier Bold"),
                __T(@"Courier New"),    __T(@"Courier New Bold"),     __T(@"Gentium Plus"), __T(@"Gentium Plus Italic"),
                __T(@"Helvetica Light"), __T(@"Helvetica"),
                __T(@"Helvetica Bold"), __T(@"Helvetica Neue Light"), __T(@"Helvetica Neue"),  __T(@"Helvetica Neue Bold"),
                __T(@"New Athena Unicode"), __T(@"New Athena Unicode Bold"), 
                __T(@"Open Dyslexic"),  __T(@"Open Dyslexic Bold"),   __T(@"Palatino"),        __T(@"Palatino Bold")];

  // my height is 440px
}

-(void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

-(void)notifyDelegate
{
  // see, we only need to ntify the delegate on the iPad; the iPhone will do it on "done"
  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
  {
    [[PKSettings instance] saveSettings];

    if (_delegate)
    {
      [_delegate didChangeLayout: self];
    }
  }
}

# pragma mark -
# pragma mark font table routines

-(NSInteger) tableView: (UITableView *) tableView numberOfRowsInSection: (NSInteger) section
{
  return _fontNames.count;
}

-(NSInteger) numberOfSectionsInTableView: (UITableView *) tableView
{
  return 1;
}

-(UITableViewCell *) tableView: (UITableView *) tableView cellForRowAtIndexPath: (NSIndexPath *) indexPath
{
  static NSString *cellID = @"PKLayoutFontID";
  UITableViewCell *cell   = [tableView dequeueReusableCellWithIdentifier: cellID];

  if (!cell)
  {
    cell = [[UITableViewCell alloc]
              initWithStyle: UITableViewCellStyleDefault
            reuseIdentifier: cellID];
  }

  NSInteger row = [indexPath row];

  cell.textLabel.text          = _fontNames[row];
  cell.textLabel.numberOfLines = 1;
  cell.textLabel.minimumScaleFactor = 0.1f;
  cell.textLabel.adjustsFontSizeToFitWidth = YES;
  cell.textLabel.font          = [UIFont fontWithName: _fontNames[row] andSize: 14];
  cell.accessoryType           = UITableViewCellAccessoryNone;
  cell.backgroundColor     = [UIColor clearColor];

  if (tableView == _greekFontPicker)
  {
    if ([[[PKSettings instance] textGreekFontFace] isEqualToString: _fontNames[row]])
    {
      cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
  }
  else
  {
    if ([[[PKSettings instance] textFontFace] isEqualToString: _fontNames[row]])
    {
      cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
  }

  return cell;
}

-(void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
  NSInteger row = [indexPath row];
  [tableView deselectRowAtIndexPath: indexPath animated: YES];

  if (tableView == _greekFontPicker)
  {
    [PKSettings instance].textGreekFontFace = _fontNames[row];
  }
  else
  {
    [PKSettings instance].textFontFace = _fontNames[row];
  }
  [tableView reloadData];
  [self notifyDelegate];
}

#pragma mark -
#pragma mark control notifications

-(void) columnChanged: (id) sender
{
  switch (_columnSelector.selectedSegmentIndex)
  {
  case 0:
    [PKSettings instance].layoutColumnWidths = 0;
    break;

  case 1:
    [PKSettings instance].layoutColumnWidths = 2;
    break;

  case 2:
    [PKSettings instance].layoutColumnWidths = 1;
    break;
  }
  [self notifyDelegate];
}

-(void) fontSizeChanged: (id) sender
{
  [PKSettings instance].textFontSize = [_fontSizes[(int)_fontStepper.value] intValue];
  _fontSizeLabel.text = [NSString stringWithFormat: @"%ipt", [[PKSettings instance] textFontSize]];
  [self notifyDelegate];
}

-(void) lineSpacingChanged: (id) sender
{
  ( [PKSettings instance].textVerseSpacing ) = (int)_lineSpacingSelector.selectedSegmentIndex;
  [self notifyDelegate];
}

-(void) rowSpacingChanged: (id) sender
{
  switch (_rowSpacingSelector.selectedSegmentIndex)
  {
  case 0: [PKSettings instance].textLineSpacing = 100;
    break;

  case 1: [PKSettings instance].textLineSpacing = 125;
    break;

  case 2: [PKSettings instance].textLineSpacing = 150;
    break;

  case 3: [PKSettings instance].textLineSpacing = 200;
    break;
  }
  [self notifyDelegate];
}

-(void) themeChanged: (id) sender
{
  [PKSettings instance].textTheme = (int)( (CoolButton *)sender ).tag;
  _label1.text = [NSString stringWithFormat: @"%@ %i", __T(@"Theme"), [[PKSettings instance] textTheme] + 1];

  [self notifyDelegate];
  [[PKAppDelegate sharedInstance] updateAppearanceForTheme];
}

-(void) brightnessChanged: (id) sender
{
  [[UIScreen mainScreen] setBrightness: _brightnessSlider.value];
}

-(void) closeMe: (id) sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
  [[PKSettings instance] saveSettings];

  if (_delegate)
  {
    [_delegate didChangeLayout: self];
  }
}

@end
