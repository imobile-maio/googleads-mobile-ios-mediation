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

#import "GADMediationAdapterMaio.h"
#import "GADMAdapterMaioRewardedAd.h"
#import "GADMAdapterMaioInterstitialAd.h"
#import "GADMAdapterMaioUtils.h"
#import "GADMMaioConstants.h"
#import "GADMMaioError.h"

@interface GADMediationAdapterMaio ()

@property(nonatomic) GADMAdapterMaioRewardedAd *rewardedAd;
@property(nonatomic) GADMAdapterMaioInterstitialAd *interstitial;

@end

@implementation GADMediationAdapterMaio

+ (void)setUpWithConfiguration:(GADMediationServerConfiguration *)configuration
             completionHandler:(GADMediationAdapterSetUpCompletionBlock)completionHandler {
  NSMutableSet *zoneIDs = [[NSMutableSet alloc] init];
  NSMutableSet *publisherIDs = [[NSMutableSet alloc] init];
  for (GADMediationCredentials *cred in configuration.credentials) {
    NSString *zoneID = cred.settings[kGADMMaioAdapterZoneId];
    GADMAdapterMaioMutableSetAddObject(zoneIDs, zoneID);
    NSString *publisherID = cred.settings[kGADMMaioAdapterPublisherId];
    GADMAdapterMaioMutableSetAddObject(publisherIDs, publisherID);
  }

  if (zoneIDs.count == 0 && publisherIDs.count == 0) {
    NSError *error = [GADMMaioError
        errorWithDescription:@"Maio mediation configurations did not contain valid zone ID and publisher ID."];
    completionHandler(error);
    return;
  }

  completionHandler(nil);
}

+ (GADVersionNumber)adSDKVersion {
  NSString *versionString = @"2.0.0";
  NSArray *versionComponents = [versionString componentsSeparatedByString:@"."];

  GADVersionNumber version = {0};
  if (versionComponents.count >= 3) {
    version.majorVersion = [versionComponents[0] integerValue];
    version.minorVersion = [versionComponents[1] integerValue];
    version.patchVersion = [versionComponents[2] integerValue];
  }
  return version;
}

+ (nullable Class<GADAdNetworkExtras>)networkExtrasClass {
  return nil;
}

+ (GADVersionNumber)version {
  return [GADMediationAdapterMaio adapterVersion];
}

+ (GADVersionNumber)adapterVersion {
  NSArray *versionComponents = [kGADMMaioAdapterVersion componentsSeparatedByString:@"."];
  GADVersionNumber version = {0};
  if (versionComponents.count >= 4) {
    version.majorVersion = [versionComponents[0] integerValue];
    version.minorVersion = [versionComponents[1] integerValue];
    version.patchVersion =
        [versionComponents[2] integerValue] * 100 + [versionComponents[3] integerValue];
  }
  return version;
}

- (void)collectSignalsForRequestParameters:(nonnull GADRTBRequestParameters *)params completionHandler:(nonnull GADRTBSignalCompletionHandler)completionHandler {

  NSString *signal = @"maio-signal";
  completionHandler(signal, nil);
}

- (void)loadRewardedAdForAdConfiguration:(GADMediationRewardedAdConfiguration *)adConfiguration
                       completionHandler:
                           (GADMediationRewardedLoadCompletionHandler)completionHandler {
  self.rewardedAd = [[GADMAdapterMaioRewardedAd alloc] init];
  [self.rewardedAd loadRewardedAdForAdConfiguration:adConfiguration
                                  completionHandler:completionHandler];
}

- (void)loadInterstitialForAdConfiguration:(GADMediationInterstitialAdConfiguration *)adConfiguration completionHandler:(GADMediationInterstitialLoadCompletionHandler)completionHandler {
  self.interstitial = [[GADMAdapterMaioInterstitialAd alloc] init];
  [self.interstitial loadInterstitialForAdConfiguration:adConfiguration
                                      completionHandler:completionHandler];
}

@end
