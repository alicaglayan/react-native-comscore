
package com.reactlibrary;

import com.comscore.Analytics;
import com.comscore.PublisherConfiguration;
import com.comscore.streaming.AdvertisementMetadata;
import com.comscore.streaming.AdvertisementType;
import com.comscore.streaming.ContentMetadata;
import com.comscore.streaming.ContentType;
import com.comscore.streaming.StreamingAnalytics;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;

import java.util.Objects;

public class RNComscoreModule extends ReactContextBaseJavaModule {

  private final ReactApplicationContext reactContext;
  StreamingAnalytics sa = new StreamingAnalytics();
  private ContentMetadata contentMetadata = null;
  private AdvertisementMetadata adMetadata = null;

  public RNComscoreModule(ReactApplicationContext reactContext) {
    super(reactContext);
    this.reactContext = reactContext;
  }

  @Override
  public String getName() {
    return "RNComscore";
  }

  @ReactMethod
  public void init(String publisherId) {
    PublisherConfiguration myPublisherConfig = new PublisherConfiguration.Builder()
            .publisherId(publisherId)
            .build();

    Analytics.getConfiguration().addClient(myPublisherConfig);
    Analytics.getConfiguration().enableChildDirectedApplicationMode();
    Analytics.start(reactContext);
    sa.createPlaybackSession();
  }

  @ReactMethod
  public void setContentMetaData(ReadableMap options) {
    int mediaType = 0;
    String mediaTypeName = options.getString("mediaType");

    switch (Objects.requireNonNull(mediaTypeName)) {
      case "long":
        mediaType = ContentType.LONG_FORM_ON_DEMAND;
        break;
      case "short":
        mediaType = ContentType.SHORT_FORM_ON_DEMAND;
        break;
      case "live":
        mediaType = ContentType.LIVE;
        break;
    }

    ReadableMap date = options.getMap("dateOfTvAiring");
    ReadableMap time = options.getMap("timeOfProduction");
    if (date != null) {
      contentMetadata = new ContentMetadata.Builder()
              .stationCode(options.getString("stationCode"))
              .uniqueId(options.getString("uniqueId"))
              .dateOfTvAiring(Integer.parseInt(Objects.requireNonNull(date.getString("year"))),
                      Integer.parseInt(Objects.requireNonNull(date.getString("month"))),
                      Integer.parseInt(Objects.requireNonNull(date.getString("day"))))
              .timeOfProduction(Integer.parseInt(Objects.requireNonNull(time.getString("hour"))),
                      Integer.parseInt(Objects.requireNonNull(time.getString("minute"))))
              .length(Long.parseLong(Objects.requireNonNull(options.getString("length"))))
              .mediaType(ContentType.LONG_FORM_ON_DEMAND)
              .programId(options.getString("programId"))
              .programTitle(options.getString("programTitle"))
              .episodeId(options.getString("episodeId"))
              .episodeTitle(options.getString("episodeTitle"))
              .publisherName(options.getString("publisherName"))
              .build();
    }
  }

  @ReactMethod
  public void setAdMetaData(String adType, String adId) {
    int mediaType = 0;

    switch (adType) {
      case "preroll":
        mediaType = AdvertisementType.ON_DEMAND_PRE_ROLL;
        break;
      case "midroll":
        mediaType = AdvertisementType.ON_DEMAND_MID_ROLL;
        break;
      case "postroll":
        mediaType = AdvertisementType.ON_DEMAND_POST_ROLL;
        break;
    }
    adMetadata = new AdvertisementMetadata.Builder()
            .uniqueId(adId)
            .mediaType(AdvertisementType.ON_DEMAND_PRE_ROLL)
            .relatedContentMetadata(contentMetadata)
            .build();
    sa.setMetadata(adMetadata);
  }

  @ReactMethod
  public void trackBufferStartEvent() {
    sa.setMetadata(contentMetadata);
    sa.notifyBufferStart();
  }

  @ReactMethod
  public void trackVideoPlayEvent() {
    sa.setMetadata(contentMetadata);
    sa.notifyPlay();
  }

  @ReactMethod
  public void trackAdPlayEvent() {
    sa.setMetadata(adMetadata);
    sa.notifyPlay();
  }

  @ReactMethod
  public void trackVideoPauseEvent() {
    sa.setMetadata(contentMetadata);
    sa.notifyPlay();
  }

  @ReactMethod
  public void trackAdPauseEvent() {
    sa.setMetadata(adMetadata);
    sa.notifyPlay();
  }

  @ReactMethod
  public void trackAdEndEvent() {
    sa.setMetadata(adMetadata);
    sa.notifyPlay();
  }

  @ReactMethod
  public void trackVideoEndEvent() {
    sa.setMetadata(contentMetadata);
    sa.notifyPlay();
  }

  @ReactMethod
  public void trackSeekEvent() {
    sa.setMetadata(contentMetadata);
    sa.notifyPlay();
  }
}