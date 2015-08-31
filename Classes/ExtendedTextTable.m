//
//  ExtendedTextTable.m
//  ATSCgh
// The MIT License (MIT)

//  Copyright (c) 2011-2015 Glenn R. Howes

//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.

//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//
//  Created by Glenn Howes on 1/18/14.
//  Copyright (c) 2014 Generally Helpful Software. All rights reserved.
//

#import "ExtendedTextTable.h"
#import "LanguageString.h"

@interface ExtendedTextTable ()
@property(nonatomic, readwrite) UInt16 source_id;
@property(nonatomic, readwrite) UInt16 event_id;
@property(nonatomic, strong) NSArray* strings; // LanguageStrings

@end

@implementation ExtendedTextTable

-(NSString*)description
{
    NSString* result = [NSString stringWithFormat:@"Extended Text Table Source ID:%d, Event ID:%d\n\tStrings:\n%@\n", self.source_id, self.event_id, self.strings.description];
    return result;
}

-(NSString*) uniqueKey
{
    NSString* superKey = [super uniqueKey];
    NSString* result = [NSString stringWithFormat:@"%@:%hd", superKey, self.source_id];
    return result;
}

-(id)initWithTableHeader:(TableHeader)aHeader packetHeader:(PacketHeader)packetHeader rawData:(const unsigned char*) streamData
{
    if(nil != (self = [super initWithTableHeader:aHeader packetHeader:packetHeader rawData:streamData]))
    {
        unsigned char byte9 = streamData[9];
        unsigned char byte10 = streamData[10];
        
        _source_id = byte9<< 8 | byte10;
        
        unsigned char byte11 = streamData[11];
        unsigned char byte12 = streamData[12];
        _event_id = (byte11 << 6) | (byte12 >> 2);
        
        _strings = [LanguageString extractFromRawData:&streamData[13]];
    }
    return self;
}
@end


