// Copyright 2019 Google LLC.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "GADMAdapterMaioRewardedAd.h"
#import "GADMMaioConstants.h"
#import "GADMMaioError.h"

@interface GADMAdapterMaioRewardedAd () <MaioRewardedLoadCallback, MaioRewardedShowCallback>

@property(nonatomic, copy) GADMediationRewardedLoadCompletionHandler completionHandler;
@property(nonatomic, weak) id<GADMediationRewardedAdEventDelegate> adEventDelegate;
@property(nonatomic, copy) NSString *zoneId;
@property(nonatomic, strong) MaioRewarded *rewarded;

@end

@implementation GADMAdapterMaioRewardedAd

- (void)loadRewardedAdForAdConfiguration:(GADMediationRewardedAdConfiguration *)adConfiguration
                       completionHandler:
                           (GADMediationRewardedLoadCompletionHandler)completionHandler {
  self.completionHandler = completionHandler;
  _zoneId = adConfiguration.credentials.settings[kGADMMaioAdapterZoneId];

  MaioRequest *request = [[MaioRequest alloc] initWithZoneId:self.zoneId testMode:adConfiguration.isTestRequest bidData:adConfiguration.bidResponse];
  self.rewarded = [MaioRewarded loadAdWithRequest:request callback:self];
}

- (void)presentFromViewController:(nonnull UIViewController *)viewController {
  [self.adEventDelegate willPresentFullScreenView];
  [self.rewarded showWithViewContext:viewController callback:self];
}

#pragma mark - MaioRewardedLoadCallback MaioRewardedShowCallback

- (void)didLoad:(MaioRewarded *)ad {
  self.adEventDelegate = self.completionHandler(self, nil);
}

- (void)didFail:(MaioRewarded *)ad errorCode:(NSInteger)errorCode {
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

- (void)didOpen:(MaioRewarded *)ad {
  [self.adEventDelegate didStartVideo];
}

- (void)didClose:(MaioRewarded *)ad {
  id<GADMediationRewardedAdEventDelegate> strongAdEventDelegate = self.adEventDelegate;
  [strongAdEventDelegate didEndVideo];
  [strongAdEventDelegate didDismissFullScreenView];
}

- (void)didReward:(MaioRewarded *)ad reward:(RewardData *)reward {
  GADAdReward *gReward = [[GADAdReward alloc] initWithRewardType:reward.value rewardAmount:[NSDecimalNumber one]];
  [self.adEventDelegate didRewardUserWithReward:gReward];
}
@end
