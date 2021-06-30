exports.title = 'Interstitial Ads';

exports.run = function (UI) {
	const AdMob = require('ti.admob');

	var win = UI.createWindow(exports.title);
	var showInterstitialAdButton = Ti.UI.createButton({
		title: 'Show Interstitial',
		top: '40%',
		height: '10%',
		width: '80%'
	});

	const interstitial = AdMob.createInterstitialAd({
		adUnitId: 'ca-app-pub-3940256099942544/4411468910'
	});
	interstitial.load();

	showInterstitialAdButton.addEventListener('click', function () {
		if (interstitial.isReady) {
			interstitial.show();
		}
	});

	win.add(showInterstitialAdButton);
};
