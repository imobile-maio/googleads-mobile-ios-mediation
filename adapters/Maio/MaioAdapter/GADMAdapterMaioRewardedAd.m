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

@interface GADMAdapterMaioRewardedAd ()

@property(nonatomic, copy) GADMediationRewardedLoadCompletionHandler completionHandler;
@property(nonatomic, weak) id<GADMediationRewardedAdEventDelegate> adEventDelegate;
@property(nonatomic, copy) NSString *zoneId;

@end

@class MaioRewarded;
@class RewardData;

@implementation GADMAdapterMaioRewardedAd

- (void)loadRewardedAdForAdConfiguration:(GADMediationRewardedAdConfiguration *)adConfiguration
                       completionHandler:
                           (GADMediationRewardedLoadCompletionHandler)completionHandler {
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
  [self.adEventDelegate willPresentFullScreenView];

  UIViewController *dummyViewController = [UIViewController new];
  dispatch_async(dispatch_get_main_queue(), ^{
    BOOL stubComplete = kGADMAdapterMaioStubPresentComplete;
    if (stubComplete) {
      [viewController presentViewController:dummyViewController animated:YES completion:nil];

      [self didOpen:nil];
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self didReward:nil reward:nil];
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
  NSString *type = @"type";
  GADAdReward *gReward = [[GADAdReward alloc] initWithRewardType:type rewardAmount:[NSDecimalNumber one]];
  [self.adEventDelegate didRewardUserWithReward:gReward];
}
@end
