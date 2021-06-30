var Admob = require('ti.admob');

var rootWindow = Ti.UI.createWindow({
    backgroundColor: 'white',
});

rootWindow.add(Ti.UI.createLabel({ text: 'Preparing …' }));

rootWindow.addEventListener('open', onOpen);
rootWindow.open();

function openTestAdsWin() {
  var win = Ti.UI.createWindow({
      backgroundColor: 'white',
      orientationModes: [Ti.UI.PORTRAIT, Ti.UI.LANDSCAPE_LEFT, Ti.UI.LANDSCAPE_RIGHT]
  });

  win.addEventListener('postlayout', function onPostLayout(event) {
    win.removeEventListener('postlayout', onPostLayout);
    bannerAdView.bottom = event.source.safeAreaPadding.bottom;
  });

  /* Banner ads */

  var bannerAdView = Admob.createView({
      height: 50,
      bottom: 0,
      adType: Admob.AD_TYPE_BANNER,
      adUnitId: 'ca-app-pub-3940256099942544/2934735716', // You can get your own at http: //www.admob.com/
      adBackgroundColor: 'black',
      contentURL: 'https://admob.com', // URL string for a webpage whose content matches the app content.
      requestAgent: 'Titanium Mobile App', // String that identifies the ad request's origin.
      extras: {
         'version': 1.0,
         'name': 'My App'
      }, // Object of additional infos
      tagForChildDirectedTreatment: false, // http:///business.ftc.gov/privacy-and-security/childrens-privacy for more infos
      keywords: ['keyword1', 'keyword2']
  });
  win.add(bannerAdView);

  bannerAdView.addEventListener('didReceiveAd', function(e) {
      Ti.API.info('Did receive ad: ' + e.adUnitId + '!');
  });
  bannerAdView.addEventListener('didFailToReceiveAd', function(e) {
      Ti.API.error('Failed to receive ad: ' + e.error);
  });
  bannerAdView.addEventListener('didPresentScreen', function() {
      Ti.API.info('Presenting screen!');
  });
  bannerAdView.addEventListener('willDismissScreen', function() {
      Ti.API.info('Dismissing screen!');
  });
  bannerAdView.addEventListener('didDismissScreen', function() {
      Ti.API.info('Dismissed screen!');
  });

  /* Interstitial Ads */

  var interstitialAdButton = Ti.UI.createButton({
      title: 'Show interstitial ad'
  });

  interstitialAdButton.addEventListener('click', function() {
      var ad2 = Admob.createView({
          adType: Admob.AD_TYPE_INTERSTITIAL,
          adUnitId: 'ca-app-pub-3940256099942544/5135589807', // You can get your own at http: //www.admob.com/
          keywords: ['keyword1', 'keyword2']
      });
      ad2.receive();
    
      ad2.addEventListener('adloaded', function() {
        ad2.showInterstitial();
      });
    
      ad2.addEventListener('didReceiveAd', function(e) {
          Ti.API.info('Did receive ad!');
      });

      ad2.addEventListener('didFailToReceiveAd', function(e) {
          Ti.API.error('Failed to receive ad: ' + e.error);
      });
  });

  win.add(interstitialAdButton);

  /* Rewarded Video Ads */

  var rewardedVideoButton = Ti.UI.createButton({
      title: 'Show Rewarded Video Ad',
      width: Ti.UI.FILL,
      center: {
          y: '55%'
      }
  });

  rewardedVideoButton.addEventListener('click', function() {
      rewardedVideoButton.title = 'Loading Rewarded Video ...';

      var rewardedVideo = Admob.createView({
          adUnitId: 'ca-app-pub-3940256099942544/1712485313',
          adType: Admob.AD_TYPE_REWARDED_VIDEO,
      });
      rewardedVideo.receive();

      rewardedVideo.addEventListener('adloaded', function() {
          rewardedVideo.showRewardedVideo();
          rewardedVideoButton.title = 'Show Rewarded Video Ad';
      });
      rewardedVideo.addEventListener('adrewarded', function (reward) {
          Ti.API.debug(`Received reward! type: ${reward.type}, amount: ${reward.amount}`);
          // pre load next rewarded video
          // rewardedVideo.loadRewardedVideo('ad-unit-id');
      });
      rewardedVideo.addEventListener('adclosed', function() {
          Ti.API.debug('No gold for you!');
      });
      rewardedVideo.addEventListener('adfailedtoload', function(error) {
          rewardedVideoButton.title = 'Show Rewarded Video Ad';
          Ti.API.debug('Rewarded video ad failed to load: ' + error.message);
      });
  });
  win.add(rewardedVideoButton);

  win.add(Ti.UI.createLabel({
      text: 'Loading the ads now! ' +
          'Note that there may be a several minute delay ' +
          'if you have not viewed an ad in over 24 hours.',
      top: 40,
      textAlign: 'center'
  }));

  win.open();
}

function resetConsent() {
  Admob.resetConsent();
  alert("Reset consent done!");
}

function loadConsentForm(e) {
  requestConsent();
}

// check trackingAuthorizationStatus on iOS >= 14
function checkTrackingAuthorizationStatus() {
  if (parseInt(Ti.Platform.version.split(".")[0]) >= 14 &&
    Admob.trackingAuthorizationStatus === Admob.TRACKING_AUTHORIZATION_STATUS_NOT_DETERMINED
  ) {
    requestTrackingAuthorization();
  } else {
    requestConsent();
  }
}

function requestTrackingAuthorization() {
  function getStatus(e) {
    console.log(e);
    if (e.status === Admob.TRACKING_AUTHORIZATION_STATUS_NOT_DETERMINED) {
      console.log('TRACKING_AUTHORIZATION_STATUS_NOT_DETERMINED');
    } else if (e.status === Admob.TRACKING_AUTHORIZATION_STATUS_RESTRICTED) {
      console.log('TRACKING_AUTHORIZATION_STATUS_RESTRICTED');
    } else if (e.status === Admob.TRACKING_AUTHORIZATION_STATUS_DENIED) {
      console.log('TRACKING_AUTHORIZATION_STATUS_DENIED');
    } else if (e.status === Admob.TRACKING_AUTHORIZATION_STATUS_AUTHORIZED) {
      console.log('TRACKING_AUTHORIZATION_STATUS_AUTHORIZED');
    } else {
      console.log('TRACKING_AUTHORIZATION_STATUS_NOT_DETERMINED');
    }
  }
  Admob.requestTrackingAuthorization({
    callback: e => {
      requestConsent();
    }
  });
};

function requestConsent() {
  console.log("request consent");
  Admob.requestConsentInfoUpdateWithParameters({
    publisherIdentifiers: "pub-3940256099942544",
    tagForUnderAgeOfConsent: false,
    callback: function (e) {
      console.log("requestConsentInfoUpdateWithParameters callback");
      console.log(e);
      console.log(
        `
        debugIdentifiers: ${Admob.debugIdentifiers};
        debugGeography: ${Admob.debugGeography};
        Admob.CONSENT_FORM_STATUS_UNKNOWN: ${Admob.CONSENT_FORM_STATUS_UNKNOWN};
        Admob.CONSENT_FORM_STATUS_AVAILABLE: ${Admob.CONSENT_FORM_STATUS_AVAILABLE};
        Admob.CONSENT_FORM_STATUS_UNAVAILABLE: ${Admob.CONSENT_FORM_STATUS_UNAVAILABLE};
        Admob.CONSENT_STATUS_UNKNOWN: ${Admob.CONSENT_STATUS_UNKNOWN};
        Admob.CONSENT_STATUS_REQUIRED: ${Admob.CONSENT_STATUS_REQUIRED};
        Admob.CONSENT_STATUS_NOT_REQUIRED: ${Admob.CONSENT_STATUS_NOT_REQUIRED};
        Admob.CONSENT_STATUS_OBTAINED: ${Admob.CONSENT_STATUS_OBTAINED};
        `
      );
      if (Admob.adProviders) {
        if (Admob.adProviders.length > 0) {
          if (Admob.adProviders[0].privacyPolicyURL) {
            Ti.API.info('adProviders.length:', adProviders.length);
            Ti.API.info('adProviders[0].privacyPolicyUR');
            //adProviders = Admob.adProviders;
          };
        };
      };
      if (e.success) {
        Admob.loadForm({
          callback: (e) => {
            if (e.dismissError || e.loadError) {
              alert(e.dismissError || e.loadError);
              return;
            }
            console.log("Admob.loadConsentForm callback:");
            console.log(e);
            
            // If the status is "obtained" (freshly granted) or not required (already granted) continue
            if ([ Admob.CONSENT_STATUS_NOT_REQUIRED, Admob.CONSENT_STATUS_OBTAINED ].includes(e.status)) {
              openTestAdsWin();
            } else {
              alert('Not ready to show ads! Status = ' + e.status);
            }
          }
        })
      }
    }
  });
};

function onOpen() {
    checkTrackingAuthorizationStatus();
    Ti.API.info("************");
  
//    setTimeout(() => {
//      Admob.setInMobi_updateGDPRConsent(false);
//      //Admob.setAdvertiserTrackingEnabled("ue");
//      Ti.API.info("************");
//    }, 1000);
}
