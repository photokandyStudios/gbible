//
//  PKConstants.m
//  gbible
//
//  Created by Kerri Shotts on 3/16/12.
//  Copyright (c) 2012 photoKandy Studios LLC. All rights reserved.
//

#include "PKConstants.h"
// Bible texts (must match bibleContent database)
int const PK_BIBLETEXT_BYZ   = 1;
int const PK_BIBLETEXT_BYZP  = 2;
int const PK_BIBLETEXT_TIS   = 3;
int const PK_BIBLETEXT_TR    = 4;
int const PK_BIBLETEXT_TRP   = 5;
int const PK_BIBLETEXT_WH    = 6;
int const PK_BIBLETEXT_WHP   = 7;
int const PK_BIBLETEXT_KJV   = 8;
int const PK_BIBLETEXT_YLT   = 9;

// boolean constant
BOOL const PK_PARSED         = YES;
BOOL const PK_TRANSLITERATE  = YES;
BOOL const PK_INLINENOTES    = YES;
BOOL const PK_SHOWMORPHOLOGY = YES;

// Line spacing constants
int const PK_LS_CRAMPED      = 50;
int const PK_LS_TIGHT        = 75;
int const PK_LS_NORMAL       = 100;
int const PK_LS_ONEQUARTER   = 125;
int const PK_LS_ONEHALF      = 150;
int const PK_LS_DOUBLE       = 200;

// verse spacing constants
int const PK_VS_NONE         = 0;
int const PK_VS_SINGLE       = 1;
int const PK_VS_DOUBLE       = 2;

// column width constants

int const PK_CW_WIDEGREEK                 = 0;
int const PK_CW_WIDEENGLISH               = 1;
int const PK_CW_EQUAL                     = 2;

// setting constants
NSString *const PK_SETTING_LINESPACING    = @"line-spacing";
NSString *const PK_SETTING_VERSESPACING   = @"verse-spacing";
NSString *const PK_SETTING_COLUMNWIDTHS   = @"column-widths";
NSString *const PK_SETTING_GREEKTEXT      = @"greek-text";
NSString *const PK_SETTING_ENGLISHTEXT    = @"english-text";
NSString *const PK_SETTING_TRANSLITERATE  = @"transliterate";
NSString *const PK_SETTING_SHOWMORPHOLOGY = @"show-morphology";
NSString *const PK_SETTING_INLINENOTES    = @"inline-notes";
NSString *const PK_SETTING_FONTSIZE       = @"font-size";
NSString *const PK_SETTING_FONTFACE       = @"font-face";
NSString *const PK_SETTING_USEICLOUD      = @"icloud-enabled";

// color themes
int const PK_TT_ORIGINAL                  = 0;
int const PK_TT_BLACK_ON_WHITE            = 1;
int const PK_TT_WHITE_ON_BLACK            = 2;
int const PK_TT_AMBER_ON_BLACK            = 3;

// bibles table column indexes
int const PK_TBL_BIBLES_ABBREVIATION      = 0;
int const PK_TBL_BIBLES_ATTRIBUTION       = 1;
int const PK_TBL_BIBLES_SIDE              = 2;
int const PK_TBL_BIBLES_ID                = 3;
int const PK_TBL_BIBLES_NAME              = 4;
int const PK_TBL_BIBLES_PARSED_ID         = 5;