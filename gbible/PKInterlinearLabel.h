//
//  PKInterlinearLabel.h
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
#import <UIKit/UIKit.h>
#import "PKLabel.h"

typedef enum  {
  PKILID_Lexicon =    1 << 0,
  PKILID_Idiom =      1 << 1,
  PKILID_Morphology = 1 << 2,
  PKILID_Diglot =     1 << 3
} PKILID;

@interface PKInterlinearLabel : NSObject

@property CGRect frame;
@property (nonatomic, strong) PKLabel *lexicon;
@property (nonatomic, strong) PKLabel *idiom;
@property (nonatomic, strong) PKLabel *morphology;
@property (nonatomic, strong) PKLabel *diglot;

@property int rowSpacing; // the spacing between rows (so we can calculate a column height)
@property (readonly) CGFloat columnHeight; // the height of the entire column
@property (readonly) CGFloat columnWidth; // the width of the entire column

@property PKILID visibility;

-(id) init;
-(id) initWithFrame: (CGRect) theFrame;
-(id) initWithIdiom: (PKLabel *)idiom;
-(id) initWithIdiom: (PKLabel *)idiom andLexicon: (PKLabel *)lexicon andMorphology: (PKLabel *)morphology andDiglot: (PKLabel *)diglot;
-(void) draw: (CGContextRef) theCtx;
-(void) dealloc;

-(void) setDisplayOrder:(PKILID) first :(PKILID) second :(PKILID) third :(PKILID) last;
-(NSArray *) displayOrder;

-(void) setOrigin: (CGPoint) origin;

@end
