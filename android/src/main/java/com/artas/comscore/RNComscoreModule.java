package com.artas.comscore;

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
    String mediaTypeName = options.getString("mediaType") != null ? options.getString("mediaType") : "long";

    switch (mediaTypeName) {
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

    contentMetadata = new ContentMetadata.Builder()
            .stationCode(options.getString("stationCode") != null ? options.getString("stationCode") : "")
            .uniqueId(options.getString("uniqueId") != null ? options.getString("uniqueId") : "")
            .dateOfTvAiring(Integer.parseInt(date != null && date.getString("year") != null ? date.getString("year") : "0"),
                    Integer.parseInt(date != null && date.getString("month") != null ? date.getString("month") : "0"),
                    Integer.parseInt(date != null && date.getString("day") != null ? date.getString("day") : "0"))
            .timeOfProduction(Integer.parseInt(time != null && time.getString("hour") != null ? time.getString("hour") : "0"),
                    Integer.parseInt(time != null && time.getString("minute") != null ? time.getString("minute") : "0"))
            .length(options.getInt("length"))
            .mediaType(ContentType.LONG_FORM_ON_DEMAND)
            .programId(options.getString("programId") != null ? options.getString("programId") : "")
            .programTitle(options.getString("programTitle") != null ? options.getString("programTitle") : "")
            .episodeId(options.getString("episodeId") != null ? options.getString("episodeId") : "")
            .episodeTitle(options.getString("episodeTitle") != null ? options.getString("episodeTitle") : "")
            .publisherName(options.getString("publisherName") != null ? options.getString("publisherName") : "")
            .build();

    sa.setMetadata(contentMetadata);
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
      case "live":
        mediaType = AdvertisementType.LIVE;
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
    sa.notifyBufferStart();
  }

  @ReactMethod
  public void trackBufferStopEvent() {
    sa.notifyBufferStop();
  }

  @ReactMethod
  public void trackVideoPlayEvent(Integer time) {
    sa.startFromPosition(time);
    sa.notifyPlay();
  }

  @ReactMethod
  public void trackLivePlayEvent(Integer time, Integer length) {
    sa.setDvrWindowLength(length);
    sa.startFromDvrWindowOffset(time);
    sa.notifyPlay();
  }

  @ReactMethod
  public void trackSeekStartEvent(Integer time) {
    sa.startFromPosition(time);
    sa.notifySeekStart();
  }

  @ReactMethod
  public void trackAdPlayEvent() {
    sa.notifyPlay();
  }

  @ReactMethod
  public void trackVideoPauseEvent(Integer time) {
    sa.startFromPosition(time);
    sa.notifyPause();
  }

  @ReactMethod
  public void trackLivePauseEvent(Integer time, Integer length) {
    sa.setDvrWindowLength(length);
    sa.startFromDvrWindowOffset(time);
    sa.notifyPause();
  }

  @ReactMethod
  public void trackAdPauseEvent() {
    sa.notifyPause();
  }

  @ReactMethod
  public void trackAdEndEvent() {
    sa.notifyEnd();
  }

  @ReactMethod
  public void trackVideoEndEvent() {
    sa.notifyEnd();
  }

  @ReactMethod
  public void trackSeekEvent() {
    sa.notifyPlay();
  }
}