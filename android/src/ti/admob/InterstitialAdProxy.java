/**
 * Copyright (c) 2011 by Studio Classics. All Rights Reserved.
 * Copyright (c) 2017-present by Axway Appcelerator. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

package ti.admob;

import android.os.Bundle;
import com.google.ads.mediation.admob.AdMobAdapter;
import com.google.android.gms.ads.AdRequest;
import com.google.android.gms.ads.InterstitialAd;
import org.appcelerator.kroll.KrollDict;
import org.appcelerator.kroll.KrollProxy;
import org.appcelerator.kroll.annotations.Kroll;
import org.appcelerator.kroll.common.Log;
import org.appcelerator.titanium.TiApplication;

@Kroll.proxy(creatableInModule = AdmobModule.class)
public class InterstitialAdProxy extends KrollProxy
{

	private final String TAG = "InterstitialAd";
	private InterstitialAd interstitialAd;

	public InterstitialAdProxy()
	{
		this.interstitialAd = new InterstitialAd(getActivity());
		this.interstitialAd.setAdListener(new CommonAdListener(this, TAG));
	}

	@Override
	public void handleCreationDict(KrollDict dict)
	{
		super.handleCreationDict(dict);
		if (dict.containsKeyAndNotNull(AdmobModule.PROPERTY_AD_UNIT_ID)) {
			this.interstitialAd.setAdUnitId(dict.getString(AdmobModule.PROPERTY_AD_UNIT_ID));
		}
	}

	// clang format off
	@Kroll.method
	@Kroll.setProperty
	public void setAdUnitId(String adUnitId)
	// clang format on
	{
		// Validate the parameter
		if (adUnitId != null && adUnitId instanceof String) {
			this.interstitialAd.setAdUnitId(adUnitId);
		}
	}

	// clang format off
	@Kroll.method
	@Kroll.getProperty
	public String getAdUnitId()
	// clang format on
	{
		return this.interstitialAd.getAdUnitId();
	}

	@Kroll.method
	public void load(@Kroll.argument(optional = true) KrollDict options)
	{
		AdRequest.Builder adRequestBuilder = AdmobModule.createRequestBuilderWithOptions(options);
		if (!TiApplication.getInstance().runOnMainThread()) {
			getActivity().runOnUiThread(new Runnable() {
				@Override
				public void run()
				{
					interstitialAd.loadAd(new AdRequest.Builder().build());
				}
			});
		} else {
			this.interstitialAd.loadAd(new AdRequest.Builder().build());
		}
	}

	@Kroll.method
	public void show()
	{
		if (!TiApplication.getInstance().runOnMainThread()) {
			getActivity().runOnUiThread(new Runnable() {
				@Override
				public void run()
				{
					showInterstitial();
				}
			});
		} else {
			showInterstitial();
		}
	}

	private void showInterstitial()
	{
		if (this.interstitialAd.isLoaded()) {
			this.interstitialAd.show();
		} else {
			Log.w(TAG, "Trying to show an ad that has not been loaded.");
		}
	}
}