//
//  LanguageString.h
//  Signal GH
//
//  Created by Glenn Howes on 1/18/14.
//  Copyright (c) 2014 Generally Helpful Software. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface LanguageString : NSObject
@property(nonatomic, readonly) NSString* languageCode;
@property(nonatomic, readonly) NSString* string;

+(NSArray*)extractFromRawData:(const unsigned char*)streamData;
+(NSString*) bestMatchFromSet:(NSSet*)setOfLanguageStrings;

-(id) initWithLanguageCode:(NSString*)languageCode andString:(NSString*)string;
@end
