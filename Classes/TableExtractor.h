//
//  TableExtractor.h
//  Signal GH
//
//  Created by Glenn Howes on 2/7/14.
//  Copyright (c) 2014 Generally Helpful Software. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^parsingCallback_t)(NSUInteger endIndex, NSDictionary* extractors, NSDictionary* tables);
@interface TableExtractor : NSObject
@property(nonatomic, readonly) NSNumber* pid;
@property(nonatomic, readonly) unsigned char table_id;


+(void) extractTablesFromData:(const unsigned char*)theData ofValidLength:(size_t)validLength withSetOfExtractors:(NSDictionary*)preexisting intoCallback:(parsingCallback_t)callback;
-(id) initWithPID:(NSNumber*)aPid;

@end
