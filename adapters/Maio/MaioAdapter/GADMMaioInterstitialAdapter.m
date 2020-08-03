//
//  GADMMaioInterstitialAdapter.m
//  GADMMaioAdapter
//
//  Copyright © 2017 i-mobile, Inc. All rights reserved.
//

#import "GADMMaioInterstitialAdapter.h"
#import "GADMMaioConstants.h"
#import "GADMMaioError.h"

@class MaioRewarded;
#define MaioInterstitial MaioRewarded

@interface GADMMaioInterstitialAdapter ()

@property(nonatomic, weak) id<GADMAdNetworkConnector> interstitialAdConnector;

@property(nonatomic, strong) NSString *zoneId;
@property(nonatomic, strong) MaioInterstitial *interstitial;

@end

@implementation GADMMaioInterstitialAdapter

#pragma mark - GADMAdNetworkAdapter

/// Returns a version string for the adapter. It can be any string that uniquely
/// identifies the version of your adapter. For example, "1.0", or simply a date
/// such as "20110915".
+ (NSString *)adapterVersion {
  return kGADMMaioAdapterVersion;
}

/// The extras class that is used to specify additional parameters for a request
/// to this ad network. Returns Nil if the network does not have extra settings
/// for publishers to send.
+ (Class<GADAdNetworkExtras>)networkExtrasClass {
  return nil;
}

/// Designated initializer. Implementing classes can and should keep the
/// connector in an instance variable. However you must never retain the
/// connector, as doing so will create a circular reference and cause memory
/// leaks.
- (instancetype)initWithGADMAdNetworkConnector:(id<GADMAdNetworkConnector>)connector {
  if (!connector) {
    return nil;
  }

  self = [super init];
  if (self) {
    self.interstitialAdConnector = connector;
  }
  return self;
}

/// Asks the adapter to initiate a banner ad request. The adapter does not need
/// to return anything. The assumption is that the adapter will start an
/// asynchronous ad fetch over the network. Your adapter may act as a delegate
/// to your SDK to listen to callbacks. If your SDK does not support the given
/// ad size, or does not support banner ads, call back to the adapter:didFailAd:
/// method of the connector.
- (void)getBannerWithSize:(GADAdSize)adSize {
  // not supported bunner
  NSString *description = [NSString stringWithFormat:@"%@ is not supported banner.", self.class];
  [self.interstitialAdConnector adapter:self
                              didFailAd:[GADMMaioError errorWithDescription:description]];
}

/// Asks the adapter to initiate an interstitial ad request. The adapter does
/// not need to return anything. The assumption is that the adapter will start
/// an asynchronous ad fetch over the network. Your adapter may act as a
/// delegate to your SDK to listen to callbacks. If your SDK does not support
/// interstitials, call back to the adapter:didFailInterstitial: method of the
/// connector.
- (void)getInterstitial {
  id<GADMAdNetworkConnector> strongConnector = self.interstitialAdConnector;
  NSDictionary *param = [strongConnector credentials];
  if (!param) {
    return;
  }
  self.zoneId = param[kGADMMaioAdapterZoneId];

  dispatch_async(dispatch_get_main_queue(), ^{
    BOOL stubComplete = kGADMAdapterMaioStubLoadComplete;
    if (stubComplete) {
      [self didLoad:nil];
    } else {
      [self didFail:nil errorCode:10000];
    }
  });
}

/// When called, the adapter must remove itself as a delegate or notification
/// observer from the underlying ad network SDK. You should also call this
/// method in your adapter dealloc, so when your adapter goes away, your SDK
/// will not call a freed object. This function should be idempotent and should
/// not crash regardless of when or how many times the method is called.
- (void)stopBeingDelegate {
}

/// Some ad transition types may cause issues with particular Ad SDKs. The
/// adapter may decide whether the given animation type is OK. Defaults to YES.
- (BOOL)isBannerAnimationOK:(GADMBannerAnimationType)animType {
  // default value
  return YES;
}

/// Present an interstitial using the supplied UIViewController, by calling
/// presentViewController:animated:completion:.
///
/// Your interstitial should not immediately present itself when it is received.
/// Instead, you should wait until this method is called on your adapter to
/// present the interstitial.
///
/// Make sure to call adapterWillPresentInterstitial: on the connector when the
/// interstitial is about to be presented, and adapterWillDismissInterstitial:
/// and adapterDidDismissInterstitial: when the interstitial is being dismissed.
- (void)presentInterstitialFromRootViewController:(UIViewController *)rootViewController {
  [self.interstitialAdConnector adapterWillPresentInterstitial:self];

  UIViewController *dummyViewController = [UIViewController new];
  dispatch_async(dispatch_get_main_queue(), ^{
    BOOL stubComplete = kGADMAdapterMaioStubPresentComplete;
    if (stubComplete) {
      [rootViewController presentViewController:dummyViewController animated:YES completion:nil];

      [self didOpen:nil];
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [dummyViewController dismissViewControllerAnimated:YES completion:nil];
        [self didClose:nil];
      });

    } else {
      [rootViewController presentViewController:dummyViewController animated:YES completion:nil];
      [self didOpen:nil];
      [self didFail:nil errorCode:20000];
      [dummyViewController dismissViewControllerAnimated:YES completion:nil];
      [self didClose:nil];
    }
  });}

#pragma mark - MaioInterstitialLoadCallback, MaioInterstitialShowCallback

- (void)didLoad:(MaioInterstitial *)ad {
  [self.interstitialAdConnector adapterDidReceiveInterstitial:self];
}

- (void)didFail:(MaioInterstitial *)ad errorCode:(NSInteger)errorCode {
  NSString *description = [GADMMaioError stringFromErrorCode:errorCode];
  NSError *error = [GADMMaioError errorWithDescription:description errorCode:errorCode];
  [self.interstitialAdConnector adapter:self didFailAd:error];
}

- (void)didOpen:(MaioInterstitial *)ad {
  // NOOP
}

- (void)didClose:(MaioInterstitial *)ad {
  id<GADMAdNetworkConnector> strongConnector = self.interstitialAdConnector;

  [strongConnector adapterWillDismissInterstitial:self];
  [strongConnector adapterDidDismissInterstitial:self];
}

#pragma mark - private methods

@end
