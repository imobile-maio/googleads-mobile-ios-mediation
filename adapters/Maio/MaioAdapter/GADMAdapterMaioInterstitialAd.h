//
//  GADMAdapterMaioInterstitialAd.h
//  Adapter
//
//  Copyright © 2017 i-mobile, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
@import GoogleMobileAds;

NS_ASSUME_NONNULL_BEGIN

@interface GADMAdapterMaioInterstitialAd : NSObject <GADMediationInterstitialAd>

- (void)loadInterstitialForAdConfiguration:(GADMediationInterstitialAdConfiguration *)adConfiguration
                         completionHandler:(GADMediationInterstitialLoadCompletionHandler)completionHandler;
@end

NS_ASSUME_NONNULL_END
