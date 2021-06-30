exports.title = 'Banner Ads';

exports.run = function (UI) {
	const AdMob = require('ti.admob');
	var win = UI.createWindow(exports.title);

	const bannerViewSmart = AdMob.createBannerView({
		adUnitId: 'ca-app-pub-3940256099942544/2934735716',
		adSize: AdMob.AD_SIZE_SMART_BANNER
	});
	bannerViewSmart.load();
	win.add(bannerViewSmart);

	const bannerViewFull = AdMob.createBannerView({
		adUnitId: 'ca-app-pub-3940256099942544/2934735716',
		adSize: AdMob.AD_SIZE_FULL_BANNER,
		bottom: 70
	});
	bannerViewFull.load();
	win.add(bannerViewFull);

	const bannerViewLarge = AdMob.createBannerView({
		adUnitId: 'ca-app-pub-3940256099942544/2934735716',
		adSize: AdMob.AD_SIZE_LARGE_BANNER,
		bottom: 140
	});
	bannerViewLarge.load();
	win.add(bannerViewLarge);

	const bannerViewBanneer = AdMob.createBannerView({
		adUnitId: 'ca-app-pub-3940256099942544/2934735716',
		adSize: AdMob.AD_SIZE_BANNER,
		bottom: 240
	});
	bannerViewBanneer.load();
	win.add(bannerViewBanneer);

	const bannerViewMediumRect = AdMob.createBannerView({
		adUnitId: 'ca-app-pub-3940256099942544/2934735716',
		adSize: AdMob.AD_SIZE_MEDIUM_RECTANGLE,
		bottom: 290
	});
	bannerViewMediumRect.load();
	win.add(bannerViewMediumRect);
};
