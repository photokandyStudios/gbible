//
//  PKInterlinearLabel.m
//  gbible
//
//  Created by Kerri Shotts on 6/5/2013.
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

#import "PKInterlinearLabel.h"

#import "UIFont+Utility.h"

@implementation PKInterlinearLabel
{
  int _displayOrder;
}





-(id) init
{
  self = [super init];
  
  if (self)
  {
    _idiom = nil;
    _diglot = nil;
    _morphology = nil;
    _lexicon = nil;
    _visibility = PKILID_Idiom | PKILID_Diglot | PKILID_Lexicon | PKILID_Morphology;
    _displayOrder = (PKILID_Lexicon << 12) | (PKILID_Idiom << 8) | (PKILID_Morphology << 4) | (PKILID_Diglot << 0);
  }
  return self;
}

-(id) initWithFrame: (CGRect) theFrame
{
  self = [self init];
  
  if (self)
  {
    _frame = theFrame;
  }
  return self;
}

-(id) initWithIdiom: (PKLabel *)idiom
{
  self = [self initWithIdiom:idiom andLexicon:nil andMorphology:nil andDiglot:nil];
  return self;
}

-(id) initWithIdiom: (PKLabel *)idiom andLexicon: (PKLabel *)lexicon andMorphology: (PKLabel *)morphology andDiglot: (PKLabel *)diglot
{
  self = [self init];
  if (self)
  {
    _idiom = idiom;
    _lexicon = lexicon;
    _morphology = morphology;
    _diglot = diglot;
  }
  return self;
}

-(void) _calculateFrames
{
}

-(void) setDisplayOrder:(PKILID) first :(PKILID) second :(PKILID) third :(PKILID) last
{
  _displayOrder = (first << 12) | (second << 8) | (third << 4) | (last);
}

-(NSArray *) displayOrder
{
  return @[ @( (_displayOrder & 0xF000) >> 12 ),
            @( (_displayOrder & 0x0F00) >>  8 ),
            @( (_displayOrder & 0x00F0) >>  4 ),
            @( (_displayOrder & 0x000F) >>  0 ) ];
}

-(void) draw: (CGContextRef) theCtx
{
  [_idiom draw:theCtx];
  [_diglot draw:theCtx];
  [_morphology draw:theCtx];
  [_lexicon draw:theCtx];
}

-(void) dealloc
{
  _idiom = nil;
  _diglot = nil;
  _morphology = nil;
  _lexicon = nil;
}

@end