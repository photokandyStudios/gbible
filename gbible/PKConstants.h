//
//  PKConstants.h
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
#ifndef gbible_PKConstants_h
#define gbible_PKConstants_h

// Bible texts (must match bibleContent database)
extern int const PK_BIBLETEXT_BYZ;
extern int const PK_BIBLETEXT_BYZP;
extern int const PK_BIBLETEXT_TIS;
extern int const PK_BIBLETEXT_TR;
extern int const PK_BIBLETEXT_TRP;
extern int const PK_BIBLETEXT_WH;
extern int const PK_BIBLETEXT_WHP;
extern int const PK_BIBLETEXT_KJV;
extern int const PK_BIBLETEXT_YLT;

// boolean constant
extern BOOL const PK_PARSED;
extern BOOL const PK_TRANSLITERATE;
extern BOOL const PK_INLINENOTES;
extern BOOL const PK_SHOWMORPHOLOGY;

// Line spacing constants
extern int const PK_LS_CRAMPED;
extern int const PK_LS_TIGHT;
extern int const PK_LS_NORMAL;
extern int const PK_LS_ONEQUARTER;
extern int const PK_LS_ONEHALF;
extern int const PK_LS_DOUBLE;

// verse spacing constants
extern int const PK_VS_NONE;
extern int const PK_VS_SINGLE;
extern int const PK_VS_DOUBLE;

// column width constants

extern int const PK_CW_WIDEGREEK;
extern int const PK_CW_WIDEENGLISH;
extern int const PK_CW_EQUAL;

// setting constants
extern NSString *const PK_SETTING_LINESPACING;
extern NSString *const PK_SETTING_VERSESPACING;
extern NSString *const PK_SETTING_COLUMNWIDTHS;
extern NSString *const PK_SETTING_GREEKTEXT;
extern NSString *const PK_SETTING_ENGLISHTEXT;
extern NSString *const PK_SETTING_TRANSLITERATE;
extern NSString *const PK_SETTING_SHOWMORPHOLOGY;
extern NSString *const PK_SETTING_INLINENOTES;
extern NSString *const PK_SETTING_FONTSIZE;
extern NSString *const PK_SETTING_FONTFACE;
extern NSString *const PK_SETTING_USEICLOUD;

extern int const PK_TBL_BIBLES_ABBREVIATION;
extern int const PK_TBL_BIBLES_ATTRIBUTION;
extern int const PK_TBL_BIBLES_SIDE;
extern int const PK_TBL_BIBLES_ID;
extern int const PK_TBL_BIBLES_NAME;
extern int const PK_TBL_BIBLES_PARSED_ID;

#endif