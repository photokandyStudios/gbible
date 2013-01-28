//
//  PKDatabase.h
//  gbible
//
//  Created by Kerri Shotts on 3/16/12.
//  Copyright (c) 2012 photoKandy Studios LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"

@interface PKDatabase : NSObject

@property (readonly, strong, nonatomic) FMDatabaseQueue *bible;
@property (readonly, strong, nonatomic) FMDatabaseQueue *userBible;
@property (readonly, strong, nonatomic) FMDatabaseQueue *content;

+(id)   instance;
-(id)   init;
-(void) dealloc;

-(BOOL) importNotes;
-(BOOL) importHighlights;
-(BOOL) importSettings;
-(BOOL) exportAll;

@end