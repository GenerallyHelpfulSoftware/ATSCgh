//
//  NSData+DigitalTV.h
//  Signal GH
//
//  Created by Glenn Howes on 1/8/14.
//  Copyright (c) 2014 Generally Helpful Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (DigitalTV)
-(NSData*) dataAfterUncompressionUsingTablesC5;
-(NSData*) dataAfterUncompressionUsingTablesC7;
@end

BOOL GetNthBitOfMemory(NSUInteger whichBIt, const unsigned char* rawData);