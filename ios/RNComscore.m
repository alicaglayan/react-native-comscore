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
//    SCORPublisherConfiguration *myPublisherConfig = [SCORPublisherConfiguration
//      publisherConfigurationWithBuilderBlock:^(SCORPublisherConfigurationBuilder *builder) {
//        builder.publisherId = publisherId;
//      }];
//    [[SCORAnalytics configuration] addClientWithConfiguration:myPublisherConfig];
//
//    [SCORAnalytics start];

    sa = [[SCORStreamingAnalytics alloc] init];
    [sa createPlaybackSession];
}

RCT_EXPORT_METHOD(setContentMetaData:(NSDictionary *) options)
{
    NSInteger mediaType = 0;

    if ([options[@"mediaType"] isEqual: @"long"]) {
        mediaType = SCORStreamingContentTypeLongFormOnDemand;
    } else if ([options[@"mediaType"] isEqual: @"short"]) {
        mediaType = SCORStreamingContentTypeShortFormOnDemand;
    } else if ([options[@"mediaType"] isEqual: @"live"]) {
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
        [builder setDateOfTvAiringYear:[options[@"dateOfTvAiring"][@"year"] ? options[@"dateOfTvAiring"][@"year"] : 0 integerValue]
                                 month:[options[@"dateOfTvAiring"][@"month"] ? options[@"dateOfTvAiring"][@"month"] : 0 integerValue]
                                   day:[options[@"dateOfTvAiring"][@"day"] ? options[@"dateOfTvAiring"][@"day"] : 0 integerValue]];
        [builder setTimeOfProductionHours:[options[@"timeOfProduction"][@"hour"] ? options[@"timeOfProduction"][@"hour"] : 0 integerValue]
                                  minutes:[options[@"timeOfProduction"][@"minute"] ? options[@"timeOfProduction"][@"minute"] : 0 integerValue]];
        [builder setStationCode: [RCTConvert NSString:options[@"stationCode"]]];
        [builder setEpisodeTitle: [RCTConvert NSString:options[@"episodeTitle"]]];
        [builder setEpisodeId: [RCTConvert NSString:options[@"episodeId"]]];
        [builder setProgramId: [RCTConvert NSString:options[@"programId"]]];
        [builder setPublisherName: [RCTConvert NSString:options[@"publisherName"]]];
        [builder setProgramTitle: [RCTConvert NSString:options[@"programTitle"]]];
        [builder classifyAsCompleteEpisode: YES];
    }];
    [sa setMetadata: contentMetadata];
}

RCT_EXPORT_METHOD(trackBufferStartEvent)
{
    [sa notifyBufferStart];
}

RCT_EXPORT_METHOD(trackBufferStopEvent)
{
    [sa notifyBufferStop];
}

RCT_EXPORT_METHOD(trackVideoPlayEvent: (NSInteger) currentTime)
{
    [sa startFromPosition: currentTime];
    [sa notifyPlay];
}

RCT_EXPORT_METHOD(trackLivePlayEvent: (NSInteger) dvrOffset
                  length: (NSInteger) length)
{
    [sa setDVRWindowLength: length];
    [sa startFromDvrWindowOffset: dvrOffset];
    [sa notifyPlay];
}

RCT_EXPORT_METHOD(trackAdPlayEvent)
{
    [sa notifyPlay];
}

RCT_EXPORT_METHOD(trackVideoPauseEvent: (NSInteger) currentTime)
{
    [sa startFromPosition: currentTime];
    [sa notifyPause];
}

RCT_EXPORT_METHOD(trackLivePauseEvent: (NSInteger) dvrOffset
                  length: (NSInteger) length)
{
    [sa setDVRWindowLength: length];
    [sa startFromDvrWindowOffset: dvrOffset];
    [sa notifyPause];
}

RCT_EXPORT_METHOD(trackAdPauseEvent)
{
    [sa notifyPause];
}

RCT_EXPORT_METHOD(trackAdEndEvent)
{
    [sa notifyEnd];
}

RCT_EXPORT_METHOD(trackVideoEndEvent)
{
    [sa notifyEnd];
}

RCT_EXPORT_METHOD(trackSeekStartEvent: (NSInteger) currentTime)
{
    [sa startFromPosition: currentTime];
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
    } else if ([adType isEqual: @"live"]) {
        mediaType = SCORStreamingAdvertisementTypeLive;
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

