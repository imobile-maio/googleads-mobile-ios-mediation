//
//  GADMAdapterMaioInterstitialAd.h
//  Adapter
//
//  Copyright © 2020 i-mobile, Inc. All rights reserved.
//


#import "GADMAdapterMaioInterstitialAd.h"
#import "GADMMaioConstants.h"
#import "GADMMaioError.h"
@import MaioCore;

#define MaioInterstitial MaioRewarded
#define MaioInterstitialLoadCallback MaioRewardedLoadCallback
#define MaioInterstitialShowCallback MaioRewardedShowCallback

@interface GADMAdapterMaioInterstitialAd () <MaioInterstitialLoadCallback, MaioInterstitialShowCallback>

@property(nonatomic, copy) GADMediationInterstitialLoadCompletionHandler completionHandler;
@property(nonatomic, weak) id<GADMediationInterstitialAdEventDelegate> adEventDelegate;
@property(nonatomic, copy) NSString *zoneId;
@property(nonatomic, strong) MaioInterstitial *interstitial;

@end

@implementation GADMAdapterMaioInterstitialAd

- (void)loadInterstitialForAdConfiguration:(GADMediationInterstitialAdConfiguration *)adConfiguration
                         completionHandler:(GADMediationInterstitialLoadCompletionHandler)completionHandler {
  self.completionHandler = completionHandler;
  _zoneId = adConfiguration.credentials.settings[kGADMMaioAdapterZoneId];

  MaioRequest *request = [[MaioRequest alloc] initWithZoneId:self.zoneId testMode:adConfiguration.isTestRequest bidData:adConfiguration.bidResponse];
  self.interstitial = [MaioInterstitial loadAdWithRequest:request callback:self];
}

- (void)presentFromViewController:(nonnull UIViewController *)viewController {
  [self.interstitial showWithViewContext:viewController callback:self];
}

#pragma mark - MaioInterstitialLoadCallback MaioInterstitialShowCallback

- (void)didLoad:(MaioInterstitial *)ad {
  self.adEventDelegate = self.completionHandler(self, nil);
}

- (void)didFail:(MaioInterstitial *)ad errorCode:(NSInteger)errorCode {
  NSString *description = [GADMMaioError stringFromErrorCode:errorCode];
  NSError *error = [GADMMaioError errorWithDescription:description errorCode:errorCode];

  BOOL failToLoad = [GADMMaioError codeIsAboutLoad:errorCode];
  if (failToLoad) {
    self.completionHandler(nil, error);
    return;
  }
  BOOL failToShow = [GADMMaioError codeIsAboutShow:errorCode];
  if (failToShow) {
    [self.adEventDelegate didFailToPresentWithError:error];
    return;
  }
}

- (void)didOpen:(MaioInterstitial *)ad {
  // NOOP
}

- (void)didClose:(MaioInterstitial *)ad {
  [self.adEventDelegate didDismissFullScreenView];
}

@end
