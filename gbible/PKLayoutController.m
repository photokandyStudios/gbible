//
//  PKLayoutController.m
//  gbible
//
//  Created by Kerri Shotts on 12/14/12.
//  Copyright (c) 2012 photoKandy Studios LLC. All rights reserved.
//

#import "PKLayoutController.h"

@interface PKLayoutController ()
  @property (strong, nonatomic) UILabel * previewLabel;
  @property (strong, nonatomic) UILabel * fontSizeLabel;
  @property (strong, nonatomic) UILabel * greekFontLabel;
  @property (strong, nonatomic) UILabel * englishFontLabel;
  @property (strong, nonatomic) UILabel * rowSpacingLabel;
  @property (strong, nonatomic) UIStepper * fontStepper;
  @property (strong, nonatomic) UISlider * brightnessSlider;
  @property (strong, nonatomic) UISegmentedControl * rowSpacingSelector;
  @property (strong, nonatomic) UISegmentedControl * lineSpacingSelector;
  @property (strong, nonatomic) UISegmentedControl * columnSelector;
  @property (strong, nonatomic) UIPickerView * fontPicker;
  @property (strong, nonatomic) UIImageView * decreaseBrightnessImage;
  @property (strong, nonatomic) UIImageView * increaseBrightnessImage;

@end

@implementation PKLayoutController

  @synthesize previewLabel;
  @synthesize fontSizeLabel;
  @synthesize greekFontLabel;
  @synthesize englishFontLabel;
  @synthesize rowSpacingLabel;
  @synthesize fontStepper;
  @synthesize brightnessSlider;
  @synthesize rowSpacingSelector;
  @synthesize lineSpacingSelector;
  @synthesize columnSelector;
  @synthesize fontPicker;
  @synthesize decreaseBrightnessImage;
  @synthesize increaseBrightnessImage;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
