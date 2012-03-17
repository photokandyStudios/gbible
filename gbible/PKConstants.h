//
//  PKConstants.h
//  gbible
//
//  Created by Kerri Shotts on 3/16/12.
//  Copyright (c) 2012 photoKandy Studios LLC. All rights reserved.
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
extern NSString * const PK_SETTING_LINESPACING;
extern NSString * const PK_SETTING_VERSESPACING;
extern NSString * const PK_SETTING_COLUMNWIDTHS;
extern NSString * const PK_SETTING_GREEKTEXT;
extern NSString * const PK_SETTING_ENGLISHTEXT;
extern NSString * const PK_SETTING_TRANSLITERATE;
extern NSString * const PK_SETTING_SHOWMORPHOLOGY;
extern NSString * const PK_SETTING_INLINENOTES;
extern NSString * const PK_SETTING_FONTSIZE;
extern NSString * const PK_SETTING_FONTFACE;
extern NSString * const PK_SETTING_USEICLOUD;





#endif
