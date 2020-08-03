//
//  GADMAdapterMaioInterstitialAd.h
//  Adapter
//
//  Copyright © 2020 i-mobile, Inc. All rights reserved.
//


#import "GADMAdapterMaioInterstitialAd.h"
#import "GADMMaioConstants.h"
#import "GADMMaioError.h"

@class MaioRewarded;

#define MaioInterstitial MaioRewarded

@interface GADMAdapterMaioInterstitialAd ()

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

  dispatch_async(dispatch_get_main_queue(), ^{
    BOOL stubComplete = kGADMAdapterMaioStubLoadComplete;
    if (stubComplete) {
      [self didLoad:nil];
    } else {
      [self didFail:nil errorCode:10000];
    }
  });
}

- (void)presentFromViewController:(nonnull UIViewController *)viewController {

  UIViewController *dummyViewController = [UIViewController new];
  dispatch_async(dispatch_get_main_queue(), ^{
    BOOL stubComplete = kGADMAdapterMaioStubPresentComplete;
    if (stubComplete) {
      [viewController presentViewController:dummyViewController animated:YES completion:nil];

      [self didOpen:nil];
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [dummyViewController dismissViewControllerAnimated:YES completion:nil];
        [self didClose:nil];
      });

    } else {
      [viewController presentViewController:dummyViewController animated:YES completion:nil];
      [self didOpen:nil];
      [self didFail:nil errorCode:20000];
      [dummyViewController dismissViewControllerAnimated:YES completion:nil];
      [self didClose:nil];
    }
  });
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
