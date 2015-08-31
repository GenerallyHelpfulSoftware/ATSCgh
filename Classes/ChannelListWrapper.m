//
//  ChannelListWrapper.m
//  Signal GH
//
//  Created by Glenn Howes on 8/29/15.
//  Copyright © 2015 Generally Helpful Software. All rights reserved.
//

#import "ChannelListWrapper.h"
#import "StringConstants.h"

@interface ChannelListWrapper()
@property (nonatomic, strong) NSArray<NSDictionary*>* channelList;
@end



@implementation ChannelListWrapper
+(NSCache*)channelListCache
{
    static NSCache* sCache = nil;
    static dispatch_once_t  done;
    dispatch_once(&done, ^{
        sCache = [[NSCache alloc] init];
    });
    return sCache;
}

+(NSString*) broadcastStandardForRegion:(StandardRegion)region
{
    NSString* result = nil;
    switch(region)
    {
        case kRegionUSAnCanada:
        {
            result = kAmericanChannelsTag;
        }
        break;
        case kRegionEuropeanUnion:
        {
            result = kEuropeanChannelsTag;
        }
        break;
        case kRegionAustralia:
        {
            result = kAustralianChannelsTag;
        }
        break;
        case kRegionTaiwan:
        {
            result = kTaiwanChannelsTag;
        }
        break;
        default:
        {
            NSAssert(false, @"Unknown region");
        }
        break;
    }

    return result;
}

+(ChannelListWrapper*) broadcastListWrapperForRegion:(StandardRegion) region
{
    NSString* key = [NSString stringWithFormat:@"%ld", (unsigned long) region];
    
    NSCache* listCache = [ChannelListWrapper channelListCache];
    ChannelListWrapper* result = [listCache objectForKey:key];
    
    if(result == nil)
    {
        NSString* standard = [self broadcastStandardForRegion:region];
        result = [ChannelListWrapper listWrapperForStandard:standard];
    }
    
    return  result;
}

+(ChannelListWrapper*) listWrapperForStandard:(NSString*)standard
{
    NSCache* listCache = [ChannelListWrapper channelListCache];
    ChannelListWrapper* result = [listCache objectForKey:standard];
    if(result == nil)
    {
        result = [[ChannelListWrapper alloc] initWithBroadcastStandard:standard];
        [listCache setObject:result forKey:standard cost:10];
    }
    return result;
}

+(NSArray<NSDictionary*>*)taiwaneseBroadcastChannels
{
    NSArray<NSDictionary*>* result = @[
                                       @{kRealChannelTag:@2, kTunerFrequencyTag:@57000000
                                       },
                                       @{kRealChannelTag:@3, kTunerFrequencyTag:@63000000
                                       },
                                       @{kRealChannelTag:@4, kTunerFrequencyTag:@69000000
                                       },
                                       @{kRealChannelTag:@5, kTunerFrequencyTag:@79000000
                                       },
                                       @{kRealChannelTag:@6, kTunerFrequencyTag:@85000000
                                       },
                                       @{kRealChannelTag:@7, kTunerFrequencyTag:@177000000
                                       },
                                       @{kRealChannelTag:@8, kTunerFrequencyTag:@183000000
                                       },
                                       @{kRealChannelTag:@9, kTunerFrequencyTag:@189000000
                                       },
                                       @{kRealChannelTag:@10, kTunerFrequencyTag:@195000000
                                       },
                                       @{kRealChannelTag:@11, kTunerFrequencyTag:@201000000
                                       },
                                       @{kRealChannelTag:@12, kTunerFrequencyTag:@207000000
                                       },
                                       @{kRealChannelTag:@13, kTunerFrequencyTag:@213000000
                                       },
                                       @{kRealChannelTag:@14, kTunerFrequencyTag:@473000000
                                       },
                                       @{kRealChannelTag:@15, kTunerFrequencyTag:@479000000
                                       },
                                       @{kRealChannelTag:@16, kTunerFrequencyTag:@485000000
                                       },
                                       @{kRealChannelTag:@17, kTunerFrequencyTag:@491000000
                                       },
                                       @{kRealChannelTag:@18, kTunerFrequencyTag:@497000000
                                       },
                                       @{kRealChannelTag:@19, kTunerFrequencyTag:@503000000
                                       },
                                       @{kRealChannelTag:@20, kTunerFrequencyTag:@509000000
                                       },
                                       @{kRealChannelTag:@21, kTunerFrequencyTag:@515000000
                                       },
                                       @{kRealChannelTag:@22, kTunerFrequencyTag:@521000000
                                       },
                                       @{kRealChannelTag:@23, kTunerFrequencyTag:@527000000
                                       },
                                       @{kRealChannelTag:@24, kTunerFrequencyTag:@533000000
                                       },
                                       @{kRealChannelTag:@25, kTunerFrequencyTag:@539000000
                                       },
                                       @{kRealChannelTag:@26, kTunerFrequencyTag:@545000000
                                       },
                                       @{kRealChannelTag:@27, kTunerFrequencyTag:@551000000
                                       },
                                       @{kRealChannelTag:@28, kTunerFrequencyTag:@557000000
                                       },
                                       @{kRealChannelTag:@29, kTunerFrequencyTag:@563000000
                                       },
                                       @{kRealChannelTag:@30, kTunerFrequencyTag:@569000000
                                       },
                                       @{kRealChannelTag:@31, kTunerFrequencyTag:@575000000
                                       },
                                       @{kRealChannelTag:@32, kTunerFrequencyTag:@581000000
                                       },
                                       @{kRealChannelTag:@33, kTunerFrequencyTag:@587000000
                                       },
                                       @{kRealChannelTag:@34, kTunerFrequencyTag:@593000000
                                       },
                                       @{kRealChannelTag:@35, kTunerFrequencyTag:@599000000
                                       },
                                       @{kRealChannelTag:@36, kTunerFrequencyTag:@605000000
                                       },
                                       @{kRealChannelTag:@37, kTunerFrequencyTag:@611000000
                                       },
                                       @{kRealChannelTag:@38, kTunerFrequencyTag:@617000000
                                       },
                                       @{kRealChannelTag:@39, kTunerFrequencyTag:@623000000
                                       },
                                       @{kRealChannelTag:@40, kTunerFrequencyTag:@629000000
                                       },
                                       @{kRealChannelTag:@41, kTunerFrequencyTag:@635000000
                                       },
                                       @{kRealChannelTag:@42, kTunerFrequencyTag:@641000000
                                       },
                                       @{kRealChannelTag:@43, kTunerFrequencyTag:@647000000
                                       },
                                       @{kRealChannelTag:@44, kTunerFrequencyTag:@653000000
                                       },
                                       @{kRealChannelTag:@45, kTunerFrequencyTag:@659000000
                                       },
                                       @{kRealChannelTag:@46, kTunerFrequencyTag:@665000000
                                       },
                                       @{kRealChannelTag:@47, kTunerFrequencyTag:@671000000
                                       },
                                       @{kRealChannelTag:@48, kTunerFrequencyTag:@677000000
                                       },
                                       @{kRealChannelTag:@49, kTunerFrequencyTag:@683000000
                                       },
                                       @{kRealChannelTag:@50, kTunerFrequencyTag:@689000000
                                       },
                                       @{kRealChannelTag:@51, kTunerFrequencyTag:@695000000
                                       },
                                       @{kRealChannelTag:@52, kTunerFrequencyTag:@701000000
                                       },
                                       @{kRealChannelTag:@53, kTunerFrequencyTag:@707000000
                                       },
                                       @{kRealChannelTag:@54, kTunerFrequencyTag:@713000000
                                       },
                                       @{kRealChannelTag:@55, kTunerFrequencyTag:@719000000
                                       },
                                       @{kRealChannelTag:@56, kTunerFrequencyTag:@725000000
                                       },
                                       @{kRealChannelTag:@57, kTunerFrequencyTag:@731000000
                                       },
                                       @{kRealChannelTag:@58, kTunerFrequencyTag:@737000000
                                       },
                                       @{kRealChannelTag:@59, kTunerFrequencyTag:@743000000
                                       },
                                       @{kRealChannelTag:@60, kTunerFrequencyTag:@749000000
                                       },
                                       @{kRealChannelTag:@61, kTunerFrequencyTag:@755000000
                                       },
                                       @{kRealChannelTag:@62, kTunerFrequencyTag:@761000000
                                       },
                                       @{kRealChannelTag:@63, kTunerFrequencyTag:@767000000
                                       },
                                       @{kRealChannelTag:@64, kTunerFrequencyTag:@773000000
                                       },
                                       @{kRealChannelTag:@65, kTunerFrequencyTag:@779000000
                                       },
                                       @{kRealChannelTag:@66, kTunerFrequencyTag:@785000000
                                       },
                                       @{kRealChannelTag:@67, kTunerFrequencyTag:@791000000
                                       },
                                       @{kRealChannelTag:@68, kTunerFrequencyTag:@797000000
                                       },
                                       @{kRealChannelTag:@69, kTunerFrequencyTag:@803000000
                                       }
                                       
                                       
                                       ];
    
    return result;
}

+(NSArray<NSDictionary*>*) australianBroadcastChannels
{
    NSArray<NSDictionary*>* result = @[
                                       
                   @{kRealChannelTag:@5, kTunerFrequencyTag:@177500000
                   },
                   @{kRealChannelTag:@6, kTunerFrequencyTag:@184500000
                   },
                   @{kRealChannelTag:@7, kTunerFrequencyTag:@191500000
                   },
                   @{kRealChannelTag:@8, kTunerFrequencyTag:@198500000
                   },
                   @{kRealChannelTag:@9, kTunerFrequencyTag:@205500000
                   },
                   @{kRealChannelTag:@10, kTunerFrequencyTag:@212500000
                   },
                   @{kRealChannelTag:@11, kTunerFrequencyTag:@219500000
                   },
                   @{kRealChannelTag:@12, kTunerFrequencyTag:@226500000
                   },
                   @{kRealChannelTag:@21, kTunerFrequencyTag:@480500000
                   },
                   @{kRealChannelTag:@22, kTunerFrequencyTag:@487500000
                   },
                   @{kRealChannelTag:@23, kTunerFrequencyTag:@494500000
                   },
                   @{kRealChannelTag:@24, kTunerFrequencyTag:@501500000
                   },
                   @{kRealChannelTag:@25, kTunerFrequencyTag:@508500000
                   },
                   @{kRealChannelTag:@26, kTunerFrequencyTag:@515500000
                   },
                   @{kRealChannelTag:@27, kTunerFrequencyTag:@522500000
                   },
                   @{kRealChannelTag:@28, kTunerFrequencyTag:@529500000
                   },
                   @{kRealChannelTag:@29, kTunerFrequencyTag:@536500000
                   },
                   @{kRealChannelTag:@30, kTunerFrequencyTag:@543500000
                   },
                   @{kRealChannelTag:@31, kTunerFrequencyTag:@550500000
                   },
                   @{kRealChannelTag:@32, kTunerFrequencyTag:@557500000
                   },
                   @{kRealChannelTag:@33, kTunerFrequencyTag:@564500000
                   },
                   @{kRealChannelTag:@34, kTunerFrequencyTag:@571500000
                   },
                   @{kRealChannelTag:@35, kTunerFrequencyTag:@578500000
                   },
                   @{kRealChannelTag:@36, kTunerFrequencyTag:@585500000
                   },
                   @{kRealChannelTag:@37, kTunerFrequencyTag:@592500000
                   },
                   @{kRealChannelTag:@38, kTunerFrequencyTag:@599500000
                   },
                   @{kRealChannelTag:@39, kTunerFrequencyTag:@606500000
                   },
                   @{kRealChannelTag:@40, kTunerFrequencyTag:@613500000
                   },
                   @{kRealChannelTag:@41, kTunerFrequencyTag:@620500000
                   },
                   @{kRealChannelTag:@42, kTunerFrequencyTag:@627500000
                   },
                   @{kRealChannelTag:@43, kTunerFrequencyTag:@634500000
                   },
                   @{kRealChannelTag:@44, kTunerFrequencyTag:@641500000
                   },
                   @{kRealChannelTag:@45, kTunerFrequencyTag:@648500000
                   },
                   @{kRealChannelTag:@46, kTunerFrequencyTag:@655500000
                   },
                   @{kRealChannelTag:@47, kTunerFrequencyTag:@662500000
                   },
                   @{kRealChannelTag:@48, kTunerFrequencyTag:@669500000
                   },
                   @{kRealChannelTag:@49, kTunerFrequencyTag:@676500000
                   },
                   @{kRealChannelTag:@50, kTunerFrequencyTag:@683500000
                   },
                   @{kRealChannelTag:@51, kTunerFrequencyTag:@690500000
                   },
                   @{kRealChannelTag:@52, kTunerFrequencyTag:@697500000
                   },
                   @{kRealChannelTag:@53, kTunerFrequencyTag:@704500000
                   },
                   @{kRealChannelTag:@54, kTunerFrequencyTag:@711500000
                   },
                   @{kRealChannelTag:@55, kTunerFrequencyTag:@718500000
                   },
                   @{kRealChannelTag:@56, kTunerFrequencyTag:@725500000
                   },
                   @{kRealChannelTag:@57, kTunerFrequencyTag:@732500000
                   },
                   @{kRealChannelTag:@58, kTunerFrequencyTag:@739500000
                   },
                   @{kRealChannelTag:@59, kTunerFrequencyTag:@746500000
                   },
                   @{kRealChannelTag:@60, kTunerFrequencyTag:@753500000
                   },
                   @{kRealChannelTag:@61, kTunerFrequencyTag:@760500000
                   },
                   @{kRealChannelTag:@62, kTunerFrequencyTag:@767500000
                   },
                   @{kRealChannelTag:@63, kTunerFrequencyTag:@774500000
                   },
                   @{kRealChannelTag:@64, kTunerFrequencyTag:@781500000
                   },
                   @{kRealChannelTag:@65, kTunerFrequencyTag:@788500000
                   },
                   @{kRealChannelTag:@66, kTunerFrequencyTag:@795500000
                   },
                   @{kRealChannelTag:@67, kTunerFrequencyTag:@802500000
                   },
                   @{kRealChannelTag:@68, kTunerFrequencyTag:@809500000
                   },
                   @{kRealChannelTag:@69, kTunerFrequencyTag:@816500000
                   }
            ];

    return result;
}

+(NSArray<NSDictionary*>*) europeanBroadcastChannels
{
    NSArray* result = @[
                        @{kRealChannelTag:@5, kTunerFrequencyTag:@177500000
                        },
                        @{kRealChannelTag:@6, kTunerFrequencyTag:@184500000
                        },
                        @{kRealChannelTag:@7, kTunerFrequencyTag:@191500000
                        },
                        @{kRealChannelTag:@8, kTunerFrequencyTag:@198500000
                        },
                        @{kRealChannelTag:@9, kTunerFrequencyTag:@205500000
                        },
                        @{kRealChannelTag:@10, kTunerFrequencyTag:@212500000
                        },
                        @{kRealChannelTag:@11, kTunerFrequencyTag:@219500000
                        },
                        @{kRealChannelTag:@12, kTunerFrequencyTag:@226500000
                        },
                        @{kRealChannelTag:@21, kTunerFrequencyTag:@474000000
                        },
                        @{kRealChannelTag:@22, kTunerFrequencyTag:@482000000
                        },
                        @{kRealChannelTag:@23, kTunerFrequencyTag:@490000000
                        },
                        @{kRealChannelTag:@24, kTunerFrequencyTag:@498000000
                        },
                        @{kRealChannelTag:@25, kTunerFrequencyTag:@506000000
                        },
                        @{kRealChannelTag:@26, kTunerFrequencyTag:@514000000
                        },
                        @{kRealChannelTag:@27, kTunerFrequencyTag:@522000000
                        },
                        @{kRealChannelTag:@28, kTunerFrequencyTag:@530000000
                        },
                        @{kRealChannelTag:@29, kTunerFrequencyTag:@538000000
                        },
                        @{kRealChannelTag:@30, kTunerFrequencyTag:@546000000
                        },
                        @{kRealChannelTag:@31, kTunerFrequencyTag:@554000000
                        },
                        @{kRealChannelTag:@32, kTunerFrequencyTag:@562000000
                        },
                        @{kRealChannelTag:@33, kTunerFrequencyTag:@570000000
                        },
                        @{kRealChannelTag:@34, kTunerFrequencyTag:@578000000
                        },
                        @{kRealChannelTag:@35, kTunerFrequencyTag:@586000000
                        },
                        @{kRealChannelTag:@36, kTunerFrequencyTag:@594000000
                        },
                        @{kRealChannelTag:@37, kTunerFrequencyTag:@602000000
                        },
                        @{kRealChannelTag:@38, kTunerFrequencyTag:@610000000
                        },
                        @{kRealChannelTag:@39, kTunerFrequencyTag:@618000000
                        },
                        @{kRealChannelTag:@40, kTunerFrequencyTag:@626000000
                        },
                        @{kRealChannelTag:@41, kTunerFrequencyTag:@634000000
                        },
                        @{kRealChannelTag:@42, kTunerFrequencyTag:@642000000
                        },
                        @{kRealChannelTag:@43, kTunerFrequencyTag:@650000000
                        },
                        @{kRealChannelTag:@44, kTunerFrequencyTag:@658000000
                        },
                        @{kRealChannelTag:@45, kTunerFrequencyTag:@666000000
                        },
                        @{kRealChannelTag:@46, kTunerFrequencyTag:@674000000
                        },
                        @{kRealChannelTag:@47, kTunerFrequencyTag:@682000000
                        },
                        @{kRealChannelTag:@48, kTunerFrequencyTag:@690000000
                        },
                        @{kRealChannelTag:@49, kTunerFrequencyTag:@698000000
                        },
                        @{kRealChannelTag:@50, kTunerFrequencyTag:@706000000
                        },
                        @{kRealChannelTag:@51, kTunerFrequencyTag:@714000000
                        },
                        @{kRealChannelTag:@52, kTunerFrequencyTag:@722000000
                        },
                        @{kRealChannelTag:@53, kTunerFrequencyTag:@730000000
                        },
                        @{kRealChannelTag:@54, kTunerFrequencyTag:@738000000
                        },
                        @{kRealChannelTag:@55, kTunerFrequencyTag:@746000000
                        },
                        @{kRealChannelTag:@56, kTunerFrequencyTag:@754000000
                        },
                        @{kRealChannelTag:@57, kTunerFrequencyTag:@762000000
                        },
                        @{kRealChannelTag:@58, kTunerFrequencyTag:@770000000
                        },
                        @{kRealChannelTag:@59, kTunerFrequencyTag:@778000000
                        },
                        @{kRealChannelTag:@60, kTunerFrequencyTag:@786000000
                        },
                        @{kRealChannelTag:@61, kTunerFrequencyTag:@794000000
                        },
                        @{kRealChannelTag:@62, kTunerFrequencyTag:@802000000
                        },
                        @{kRealChannelTag:@63, kTunerFrequencyTag:@810000000
                        },
                        @{kRealChannelTag:@64, kTunerFrequencyTag:@818000000
                        },
                        @{kRealChannelTag:@65, kTunerFrequencyTag:@826000000
                        },
                        @{kRealChannelTag:@66, kTunerFrequencyTag:@834000000
                        },
                        @{kRealChannelTag:@67, kTunerFrequencyTag:@842000000
                        },
                        @{kRealChannelTag:@68, kTunerFrequencyTag:@850000000
                        },
                        @{kRealChannelTag:@69, kTunerFrequencyTag:@858000000
                        }
                ];
    return result;
}

+(NSArray<NSDictionary*>*)usBroadcastChannels
{
    NSArray* result = @[
                        @{kRealChannelTag:@2, kTunerFrequencyTag:@57000000
                        },
                        @{kRealChannelTag:@3, kTunerFrequencyTag:@63000000
                        },
                        @{kRealChannelTag:@4, kTunerFrequencyTag:@69000000
                        },
                        @{kRealChannelTag:@5, kTunerFrequencyTag:@79000000
                        },
                        @{kRealChannelTag:@6, kTunerFrequencyTag:@85000000
                        },
                        @{kRealChannelTag:@7, kTunerFrequencyTag:@177000000
                        },
                        @{kRealChannelTag:@8, kTunerFrequencyTag:@183000000
                        },
                        @{kRealChannelTag:@9, kTunerFrequencyTag:@189000000
                        },
                        @{kRealChannelTag:@10, kTunerFrequencyTag:@195000000
                        },
                        @{kRealChannelTag:@11, kTunerFrequencyTag:@201000000
                        },
                        @{kRealChannelTag:@12, kTunerFrequencyTag:@207000000
                        },
                        @{kRealChannelTag:@13, kTunerFrequencyTag:@213000000
                        },
                        @{kRealChannelTag:@14, kTunerFrequencyTag:@473000000
                        },
                        @{kRealChannelTag:@15, kTunerFrequencyTag:@479000000
                        },
                        @{kRealChannelTag:@16, kTunerFrequencyTag:@485000000
                        },
                        @{kRealChannelTag:@17, kTunerFrequencyTag:@491000000
                        },
                        @{kRealChannelTag:@18, kTunerFrequencyTag:@497000000
                        },
                        @{kRealChannelTag:@19, kTunerFrequencyTag:@503000000
                        },
                        @{kRealChannelTag:@20, kTunerFrequencyTag:@509000000
                        },
                        @{kRealChannelTag:@21, kTunerFrequencyTag:@515000000
                        },
                        @{kRealChannelTag:@22, kTunerFrequencyTag:@521000000
                        },
                        @{kRealChannelTag:@23, kTunerFrequencyTag:@527000000
                        },
                        @{kRealChannelTag:@24, kTunerFrequencyTag:@533000000
                        },
                        @{kRealChannelTag:@25, kTunerFrequencyTag:@539000000
                        },
                        @{kRealChannelTag:@26, kTunerFrequencyTag:@545000000
                        },
                        @{kRealChannelTag:@27, kTunerFrequencyTag:@551000000
                        },
                        @{kRealChannelTag:@28, kTunerFrequencyTag:@557000000
                        },
                        @{kRealChannelTag:@29, kTunerFrequencyTag:@563000000
                        },
                        @{kRealChannelTag:@30, kTunerFrequencyTag:@569000000
                        },
                        @{kRealChannelTag:@31, kTunerFrequencyTag:@575000000
                        },
                        @{kRealChannelTag:@32, kTunerFrequencyTag:@581000000
                        },
                        @{kRealChannelTag:@33, kTunerFrequencyTag:@587000000
                        },
                        @{kRealChannelTag:@34, kTunerFrequencyTag:@593000000
                        },
                        @{kRealChannelTag:@35, kTunerFrequencyTag:@599000000
                        },
                        @{kRealChannelTag:@36, kTunerFrequencyTag:@605000000
                        },
                        @{kRealChannelTag:@37, kTunerFrequencyTag:@611000000
                        },
                        @{kRealChannelTag:@38, kTunerFrequencyTag:@617000000
                        },
                        @{kRealChannelTag:@39, kTunerFrequencyTag:@623000000
                        },
                        @{kRealChannelTag:@40, kTunerFrequencyTag:@629000000
                        },
                        @{kRealChannelTag:@41, kTunerFrequencyTag:@635000000
                        },
                        @{kRealChannelTag:@42, kTunerFrequencyTag:@641000000
                        },
                        @{kRealChannelTag:@43, kTunerFrequencyTag:@647000000
                        },
                        @{kRealChannelTag:@44, kTunerFrequencyTag:@653000000
                        },
                        @{kRealChannelTag:@45, kTunerFrequencyTag:@659000000
                        },
                        @{kRealChannelTag:@46, kTunerFrequencyTag:@665000000
                        },
                        @{kRealChannelTag:@47, kTunerFrequencyTag:@671000000
                        },
                        @{kRealChannelTag:@48, kTunerFrequencyTag:@677000000
                        },
                        @{kRealChannelTag:@49, kTunerFrequencyTag:@683000000
                        },
                        @{kRealChannelTag:@50, kTunerFrequencyTag:@689000000
                        },
                        @{kRealChannelTag:@51, kTunerFrequencyTag:@695000000
                        },
                        @{kRealChannelTag:@52, kTunerFrequencyTag:@701000000
                        },
                        @{kRealChannelTag:@53, kTunerFrequencyTag:@707000000
                        },
                        @{kRealChannelTag:@54, kTunerFrequencyTag:@713000000
                        },
                        @{kRealChannelTag:@55, kTunerFrequencyTag:@719000000
                        },
                        @{kRealChannelTag:@56, kTunerFrequencyTag:@725000000
                        },
                        @{kRealChannelTag:@57, kTunerFrequencyTag:@731000000
                        },
                        @{kRealChannelTag:@58, kTunerFrequencyTag:@737000000
                        },
                        @{kRealChannelTag:@59, kTunerFrequencyTag:@743000000
                        },
                        @{kRealChannelTag:@60, kTunerFrequencyTag:@749000000
                        },
                        @{kRealChannelTag:@61, kTunerFrequencyTag:@755000000
                        },
                        @{kRealChannelTag:@62, kTunerFrequencyTag:@761000000
                        },
                        @{kRealChannelTag:@63, kTunerFrequencyTag:@767000000
                        },
                        @{kRealChannelTag:@64, kTunerFrequencyTag:@773000000
                        },
                        @{kRealChannelTag:@65, kTunerFrequencyTag:@779000000
                        },
                        @{kRealChannelTag:@66, kTunerFrequencyTag:@785000000
                        },
                        @{kRealChannelTag:@67, kTunerFrequencyTag:@791000000
                        },
                        @{kRealChannelTag:@68, kTunerFrequencyTag:@797000000
                        },
                        @{kRealChannelTag:@69, kTunerFrequencyTag:@803000000
                        }


                        ];
    return result;
}

-(instancetype) initWithBroadcastStandard:(NSString *)standard
{
    if(nil != (self = [super init]))
    {
        if([standard isEqualToString:[ChannelListWrapper broadcastStandardForRegion:kRegionUSAnCanada]])
        {
            _channelList = [ChannelListWrapper usBroadcastChannels];
        }
        else if([standard isEqualToString:[ChannelListWrapper broadcastStandardForRegion:kRegionEuropeanUnion]])
        {
            _channelList = [ChannelListWrapper europeanBroadcastChannels];
        }
        else if([standard isEqualToString:[ChannelListWrapper broadcastStandardForRegion:kRegionAustralia]])
        {
            _channelList = [ChannelListWrapper australianBroadcastChannels];
        }
        else if([standard isEqualToString:[ChannelListWrapper broadcastStandardForRegion:kRegionTaiwan]])
        {
            _channelList = [ChannelListWrapper taiwaneseBroadcastChannels];
        }
        _standard = standard;
    }
    return self;
}

-(NSInteger) numberOfDigitalChannels
{
    NSInteger result = self.channelList.count;
    return result;
}

-(NSInteger) frequencyForChannel:(NSInteger)channel
{
    NSInteger result = channel;
    if(channel < 1000)
    {
        for(NSDictionary* aRecord in self.channelList)
        {
            NSNumber* channelValue = [aRecord valueForKey:kRealChannelTag];
            if(channelValue.integerValue == channel)
            {
                NSNumber* resultValue = [aRecord valueForKey:kTunerFrequencyTag];
                result = resultValue.integerValue;
            }
        }
    }
    return result;
}

-(NSArray*)allChannels
{
    NSInteger numDigitalChannels  = self.numberOfDigitalChannels;
    NSMutableArray*	mutableResult = [NSMutableArray arrayWithCapacity:numDigitalChannels];
    for(NSDictionary* aDictionary in self.channelList)
    {
        
        NSMutableDictionary*	mutableDictionary = [aDictionary mutableCopy];
        
        [mutableDictionary setValue:@YES forKey:kShowChannelInList];
        [mutableDictionary setValue:self.standard forKey:kChannelMapStandardTag];
        
        [mutableResult addObject:[mutableDictionary copy]];
    }
    
    return [mutableResult copy];
}

@end
