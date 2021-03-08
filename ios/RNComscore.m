#import "RNComscore.h"
#import "RCTConvert.h"
#import <ComScore/ComScore.h>

@implementation RNComscore

SCORStreamingAnalytics *sa;
SCORStreamingContentMetadata *contentMetadata;
SCORStreamingAdvertisementMetadata *adMetadata;

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(init:(NSString *) publisherId)
{
    SCORPublisherConfiguration *myPublisherConfig = [SCORPublisherConfiguration
      publisherConfigurationWithBuilderBlock:^(SCORPublisherConfigurationBuilder *builder) {
        builder.publisherId = publisherId;
      }];
    [[SCORAnalytics configuration] addClientWithConfiguration:myPublisherConfig];
    
    [SCORAnalytics start];
    
    sa = [[SCORStreamingAnalytics alloc] init];
    [sa createPlaybackSession];
}

RCT_EXPORT_METHOD(setContentMetaData:(NSDictionary *) options)
{
    NSInteger mediaType = 0;
    
    if ([options[@"mediaType"]  isEqual: @"long"]) {
        mediaType = SCORStreamingContentTypeLongFormOnDemand;
    } else if ([options[@"mediaType"]  isEqual: @"short"]) {
        mediaType = SCORStreamingContentTypeShortFormOnDemand;
    } else if ([options[@"mediaType"]  isEqual: @"live"]) {
        mediaType = SCORStreamingContentTypeLive;
    }
    
    contentMetadata = [SCORStreamingContentMetadata
    contentMetadataWithBuilderBlock:^(SCORStreamingContentMetadataBuilder *builder) {
        [builder setMediaType: mediaType];
        [builder setUniqueId: [RCTConvert NSString:options[@"uniqueId"]]];
        [builder setLength: [RCTConvert NSInteger:options[@"length"]]];
        [builder setDictionaryClassificationC3: @"*null"];
        [builder setDictionaryClassificationC4: @"*null"];
        [builder setDictionaryClassificationC6: @"*null"];
        [builder setDateOfTvAiringYear:[RCTConvert NSInteger:options[@"dateOfTvAiring"][@"year"]]
                                 month:[RCTConvert NSInteger:options[@"dateOfTvAiring"][@"month"]]
                                   day:[RCTConvert NSInteger:options[@"dateOfTvAiring"][@"day"]]];
        [builder setTimeOfProductionHours:[RCTConvert NSInteger:options[@"timeOfProduction"][@"hour"]]
                                  minutes:[RCTConvert NSInteger:options[@"timeOfProduction"][@"minitues"]]];
        [builder setStationCode: [RCTConvert NSString:options[@"setStationCode"]]];
        [builder setEpisodeTitle: [RCTConvert NSString:options[@"episodeTitle"]]];
        [builder setEpisodeId: [RCTConvert NSString:options[@"episodeId"]]];
        [builder setProgramId: [RCTConvert NSString:options[@"programId"]]];
        [builder setPublisherName: [RCTConvert NSString:options[@"publisherName"]]];
        [builder setProgramTitle: [RCTConvert NSString:options[@"programTitle"]]];
        [builder classifyAsCompleteEpisode: YES];
    }];
}

RCT_EXPORT_METHOD(trackBufferStartEvent)
{
    [sa notifyBufferStart];
}


RCT_EXPORT_METHOD(trackVideoPlayEvent)
{
    [sa setMetadata: contentMetadata];
    [sa notifyPlay];
}

RCT_EXPORT_METHOD(trackAdPlayEvent)
{
    [sa setMetadata: adMetadata];
    [sa notifyPlay];
}

RCT_EXPORT_METHOD(trackVideoPauseEvent)
{
    [sa setMetadata: contentMetadata];
    [sa notifyPause];
}

RCT_EXPORT_METHOD(trackAdPauseEvent)
{
    [sa setMetadata: adMetadata];
    [sa notifyPause];
}

RCT_EXPORT_METHOD(trackAdEndEvent)
{
    [sa setMetadata: adMetadata];
    [sa notifyEnd];
}

RCT_EXPORT_METHOD(trackVideoEndEvent)
{
    [sa setMetadata: contentMetadata];
    [sa notifyEnd];
}

RCT_EXPORT_METHOD(trackSeekEvent)
{
    [sa notifySeekStart];
}

RCT_EXPORT_METHOD(setAdMetaData:(NSString *) adType
                  adId:(NSString *) adId)
{
    NSInteger mediaType = 0;
    
    if ([adType isEqual: @"preroll"]) {
        mediaType = SCORStreamingAdvertisementTypeOnDemandPreRoll;
    } else if ([adType isEqual: @"midroll"]) {
        mediaType = SCORStreamingAdvertisementTypeOnDemandMidRoll;
    } else if ([adType isEqual: @"postroll"]) {
        mediaType = SCORStreamingAdvertisementTypeOnDemandPostRoll;
    }
    adMetadata = [SCORStreamingAdvertisementMetadata
    advertisementMetadataWithBuilderBlock:^(SCORStreamingAdvertisementMetadataBuilder *builder) {
        [builder setUniqueId: adId];
        [builder setMediaType: mediaType];
        [builder setRelatedContentMetadata: contentMetadata];
    }];
    [sa setMetadata: adMetadata];
}


@end
  
