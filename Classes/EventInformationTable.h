//
//  EventInformationTable.h
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

#import "ATSCTables.h"

typedef enum ETMLocation
{
    kNoETMLocation,
    kETMLocatedInPTCCarryingThisPSIP,
    kETMLocatedInPTCSpecifiedByChannelTSID,
    kUknownETMLOcation
}ETMLocation;

NS_ASSUME_NONNULL_BEGIN

@class ContentDescriptor;
@class LanguageString;

@interface EventInformationRecord : NSObject
@property(nonatomic, readonly) UInt16 event_id;
@property(nonatomic, readonly) NSTimeInterval start_time; // seconds since January 6, 1980 (GPS Epoch)
@property(nonatomic, readonly) ETMLocation extendedTextLocation;
@property(nonatomic, readonly) NSTimeInterval length_in_seconds;
@property(nonatomic, readonly,  nullable) NSArray<LanguageString*>*  titles;
@property(nonatomic, readonly) NSArray<ContentDescriptor*>* descriptors;

@end

@interface EventInformationTable : ATSCTable
@property(nonatomic, readonly) UInt16 source_id;
@property(nonatomic, readonly) NSArray<EventInformationRecord*>* records; // EventInformationRecord
@end

NS_ASSUME_NONNULL_END
