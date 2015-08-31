//
//  ExtendedTextTable.h
//  Signal GH
//
//  Created by Glenn Howes on 1/18/14.
//  Copyright (c) 2014 Generally Helpful Software. All rights reserved.
//

#import "ATSCTables.h"

@interface ExtendedTextTable : ATSCTable
@property(nonatomic, readonly) UInt16 source_id;
@property(nonatomic, readonly) UInt16 event_id;
@property(nonatomic, readonly) NSArray* strings; // LanguageStrings
@end

