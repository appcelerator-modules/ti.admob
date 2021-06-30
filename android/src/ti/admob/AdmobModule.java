/**
 * Copyright (c) 2011 by Studio Classics. All Rights Reserved.
 * Copyright (c) 2017-present by Axway Appcelerator. All Rights Reserved.
 * Author: Brian Kurzius, Axway Appcelerator
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

package ti.admob;

import android.app.Activity;
import android.content.Context;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Bundle;
import com.google.ads.consent.AdProvider;
import com.google.ads.consent.ConsentForm;
import com.google.ads.consent.ConsentFormListener;
import com.google.ads.consent.ConsentInfoUpdateListener;
import com.google.ads.consent.ConsentInformation;
import com.google.ads.consent.ConsentStatus;
import com.google.ads.consent.DebugGeography;
import com.google.ads.mediation.admob.AdMobAdapter;
import com.inmobi.sdk.InMobiSdk;
import com.google.ads.mediation.inmobi.InMobiConsent;
import com.google.android.gms.ads.AdRequest;
import com.google.android.gms.ads.MobileAds;
import com.google.android.gms.ads.identifier.AdvertisingIdClient;
import com.google.android.gms.common.GooglePlayServicesNotAvailableException;
import com.google.android.gms.common.GooglePlayServicesRepairableException;
import com.google.android.gms.common.GooglePlayServicesUtil;
import java.io.IOException;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import org.appcelerator.kroll.KrollDict;
import org.appcelerator.kroll.KrollFunction;
import org.appcelerator.kroll.KrollModule;
import org.appcelerator.kroll.KrollObject;
import org.appcelerator.kroll.annotations.Kroll;
import org.appcelerator.kroll.common.Log;
import org.appcelerator.titanium.TiApplication;
import org.appcelerator.titanium.TiBlob;
import org.appcelerator.titanium.io.TiBaseFile;
import org.appcelerator.titanium.util.TiConvert;
import org.json.JSONException;
import org.json.JSONObject;

@Kroll.module(name = "Admob", id = "ti.admob")
public class AdmobModule extends KrollModule
{
	// Standard Debugging variables
	private static final String TAG = "AdmobModule";
	public static String MODULE_NAME = "AndroidAdMobModule";

	private final String ANDROID_ADVERTISING_ID = "androidAdId";
	private final String IS_LIMIT_AD_TRACKING_ENABLED = "isLimitAdTrackingEnabled";

	public static Boolean TESTING = false;

	private ConsentForm form = null;

	public static String PUBLISHER_ID;

	// properties
	public static String PROPERTY_AD_SIZE = "adSize";
	public static String PROPERTY_AD_UNIT_ID = "adUnitId";
	public static String PROPERTY_DEBUG_ENABLED = "debugEnabled";
	public static String PROPERTY_COLOR_BG = "adBackgroundColor";
	public static String PROPERTY_COLOR_BG_TOP = "backgroundTopColor";
	public static String PROPERTY_COLOR_BORDER = "borderColor";
	public static String PROPERTY_COLOR_TEXT = "textColor";
	public static String PROPERTY_COLOR_LINK = "linkColor";
	public static String PROPERTY_COLOR_URL = "urlColor";
	public static String PROPERTY_IS_TAGGED_FOR_UNDER_AGE_OF_CONSENT = "isTaggedForUnderAgeOfConsent";

	// new event constans
	public static final String EVENT_AD_LOAD = "load";
	public static final String EVENT_AD_FAIL = "fail";
	public static final String EVENT_AD_CLOSED = "close";
	public static final String EVENT_AD_OPENED = "open";
	public static final String EVENT_AD_LEFT_APP = "leftapp";

	public AdmobModule()
	{
		super();
		Log.d(TAG, "adMob module instantiated");
	}

	// Events for receiving ads
	@Kroll.constant
	public static final String AD_RECEIVED = "ad_received";
	@Kroll.constant
	public static final String AD_NOT_RECEIVED = "ad_not_received";
	@Kroll.constant
	public static final String AD_CLOSED = "ad_closed";
	@Kroll.constant
	public static final String AD_OPENED = "ad_opened";
	@Kroll.constant
	public static final String AD_LEFT_APPLICATION = "ad_left_application";

	// Response from "isGooglePlayServicesAvailable()""
	@Kroll.constant
	public static final int SUCCESS = 0;
	@Kroll.constant
	public static final int SERVICE_MISSING = 1;
	@Kroll.constant
	public static final int SERVICE_VERSION_UPDATE_REQUIRED = 2;
	@Kroll.constant
	public static final int SERVICE_DISABLED = 3;
	@Kroll.constant
	public static final int SERVICE_INVALID = 9;

	// Response from "consentStatus"
	@Kroll.constant
	public static final int CONSENT_STATUS_UNKNOWN = 0;
	@Kroll.constant
	public static final int CONSENT_STATUS_NON_PERSONALIZED = 1;
	@Kroll.constant
	public static final int CONSENT_STATUS_PERSONALIZED = 2;

	// Debug geography constants
	@Kroll.constant
	public static final int DEBUG_GEOGRAPHY_DISABLED = 0;
	@Kroll.constant
	public static final int DEBUG_GEOGRAPHY_EEA = 1;
	@Kroll.constant
	public static final int DEBUG_GEOGRAPHY_NOT_EEA = 3;

	// AdSize constants
	@Kroll.constant
	public static final int AD_SIZE_BANNER = 0;
	@Kroll.constant
	public static final int AD_SIZE_FLUID = 1;
	@Kroll.constant
	public static final int AD_SIZE_FULL_BANNER = 2;
	@Kroll.constant
	public static final int AD_SIZE_LARGE_BANNER = 3;
	@Kroll.constant
	public static final int AD_SIZE_LEADERBOARD = 4;
	@Kroll.constant
	public static final int AD_SIZE_MEDIUM_RECTANGLE = 5;
	@Kroll.constant
	public static final int AD_SIZE_SEARCH = 6;
	@Kroll.constant
	public static final int AD_SIZE_SMART_BANNER = 7;
	@Kroll.constant
	public static final int AD_SIZE_WIDE_SKYSCRAPER = 8;

	@Kroll.constant
	public static final String SIMULATOR_ID = AdRequest.DEVICE_ID_EMULATOR;

	@Kroll.method
	public void initialize(String appID)
	{
		MobileAds.initialize(TiApplication.getInstance(), appID);
	}

	@Kroll.method
	public int isGooglePlayServicesAvailable()
	{
		Log.w(TAG, "isGooglePlayServices in ti.admob is deprecated. Use the same method from ti.playservices instead.");
		return GooglePlayServicesUtil.isGooglePlayServicesAvailable(TiApplication.getAppRootOrCurrentActivity());
	}

	// clang-format off
	@Kroll.setProperty
	@Kroll.method
	public void setPublisherId(String pubId)
	// clang-format on
	{
		Log.d(TAG, "setPublisherId(): " + pubId);
		PUBLISHER_ID = pubId;
	}

	@Kroll.method
	public void setTesting(boolean testing)
	{
		Log.d(TAG, "setTesting(): " + testing);
		TESTING = testing;
	}

	@Kroll.method
	public void isLimitAdTrackingEnabled(KrollFunction callback)
	{
		if (callback != null) {
			new getAndroidAdvertisingIDInfo(callback).execute(IS_LIMIT_AD_TRACKING_ENABLED);
		}
	}

	@Kroll.method
	public void getAndroidAdId(KrollFunction callback)
	{
		if (callback != null) {
			new getAndroidAdvertisingIDInfo(callback).execute(ANDROID_ADVERTISING_ID);
		}
	}

	private void invokeAIDClientInfoCallback(AdvertisingIdClient.Info aaClientIDInfo, String responseKey,
											 KrollFunction callback)
	{
		KrollDict callbackDictionary = new KrollDict();
		Object responseValue = null;
		switch (responseKey) {
			case ANDROID_ADVERTISING_ID:
				responseValue = aaClientIDInfo.getId();
				break;
			case IS_LIMIT_AD_TRACKING_ENABLED:
				responseValue = aaClientIDInfo.isLimitAdTrackingEnabled();
				break;
		}
		callbackDictionary.put(responseKey, responseValue);
		callback.callAsync(getKrollObject(), callbackDictionary);
	}

	private class getAndroidAdvertisingIDInfo extends AsyncTask<String, Integer, String>
	{

		private AdvertisingIdClient.Info aaClientIDInfo = null;
		private KrollFunction aaInfoCallback;

		public getAndroidAdvertisingIDInfo(KrollFunction infoCallback)
		{
			this.aaInfoCallback = infoCallback;
		}

		@Override
		protected String doInBackground(String... responseKey)
		{
			try {
				aaClientIDInfo =
					AdvertisingIdClient.getAdvertisingIdInfo(TiApplication.getInstance().getApplicationContext());
				return responseKey[0];
			} catch (IOException | GooglePlayServicesNotAvailableException | GooglePlayServicesRepairableException e) {
				e.printStackTrace();
				return null;
			}
		}

		@Override
		protected void onPostExecute(String responseKey)
		{
			if (aaClientIDInfo != null) {
				invokeAIDClientInfoCallback(aaClientIDInfo, responseKey, aaInfoCallback);
			}
		}
	}

	@Kroll.method
	public void requestConsentInfoUpdateForPublisherIdentifiers(KrollDict args)
	{
		String[] publisherIdentifiers = args.getStringArray("publisherIdentifiers");
		final KrollFunction callback;
		{
			Object value = args.get("callback");
			if (value instanceof KrollFunction) {
				callback = (KrollFunction) value;
			} else {
				throw new RuntimeException("The 'callback' property is required and must be set to a function.");
			}
		}

		Context appContext = TiApplication.getInstance().getApplicationContext();

		ConsentInformation consentInformation = ConsentInformation.getInstance(appContext);
		consentInformation.requestConsentInfoUpdate(publisherIdentifiers, new ConsentInfoUpdateListener() {
			@Override
			public void onConsentInfoUpdated(ConsentStatus consentStatus)
			{
				Log.d(TAG, "consent info updated");

				KrollObject krollObject = getKrollObject();
				KrollDict event = new KrollDict();

				event.put("consentStatus", consentStatus.ordinal());

				callback.callAsync(krollObject, event);
			}

			@Override
			public void onFailedToUpdateConsentInfo(String errorReason)
			{
				Log.d(TAG, "consent info failed");

				KrollObject krollObject = getKrollObject();
				KrollDict event = new KrollDict();

				event.put("error", errorReason);

				callback.callAsync(krollObject, event);
			}
		});
	}

	@Kroll.method
	public void showConsentForm(KrollDict args)
	{
		URL privacyUrl = null;
		Context currentActivity = TiApplication.getInstance().getCurrentActivity();

		final KrollFunction callback;
		{
			Object value = args.get("callback");
			if (value instanceof KrollFunction) {
				callback = (KrollFunction) value;
			} else {
				throw new RuntimeException("The 'callback' property is required and must be set to a function.");
			}
		}

		boolean shouldOfferPersonalizedAds = args.optBoolean("shouldOfferPersonalizedAds", true);
		boolean shouldOfferNonPersonalizedAds = args.optBoolean("shouldOfferNonPersonalizedAds", true);
		boolean shouldOfferAdFree = args.optBoolean("shouldOfferAdFree", false);

		try {
			privacyUrl = new URL(args.getString("privacyURL"));
		} catch (Exception e) {
			KrollObject krollObject = getKrollObject();
			KrollDict event = new KrollDict();

			event.put("error", e.getMessage());

			callback.callAsync(krollObject, event);
			return;
		}

		ConsentForm.Builder formBuilder =
			new ConsentForm.Builder(currentActivity, privacyUrl).withListener(new ConsentFormListener() {
				@Override
				public void onConsentFormLoaded()
				{
					Log.d(TAG, "consent form loaded");
					if (form != null) {
						form.show();
					}
				}

				@Override
				public void onConsentFormOpened()
				{
					Log.d(TAG, "consent form opened");
				}

				@Override
				public void onConsentFormClosed(ConsentStatus consentStatus, Boolean userPrefersAdFree)
				{
					Log.d(TAG, "consent form closed");

					KrollObject krollObject = getKrollObject();
					KrollDict event = new KrollDict();

					event.put("userPrefersAdFree", userPrefersAdFree);
					event.put("consentStatus", consentStatus.ordinal());
					event.put("error", null);

					callback.callAsync(krollObject, event);
				}

				@Override
				public void onConsentFormError(String errorDescription)
				{
					Log.d(TAG, "consent form error: " + errorDescription);

					KrollObject krollObject = getKrollObject();
					KrollDict event = new KrollDict();

					event.put("error", errorDescription);

					callback.callAsync(krollObject, event);
				}
			});

		if (shouldOfferPersonalizedAds) {
			formBuilder = formBuilder.withPersonalizedAdsOption();
		}

		if (shouldOfferNonPersonalizedAds) {
			formBuilder = formBuilder.withNonPersonalizedAdsOption();
		}

		if (shouldOfferAdFree) {
			formBuilder = formBuilder.withAdFreeOption();
		}

		form = formBuilder.build();
		runOnMainThread(new Runnable() {
			@Override
			public void run()
			{
				form.load();
			}
		});
	}

	// clang-format off
	@Kroll.setProperty
	public void setIsTaggedForUnderAgeOfConsent(boolean underAgeOfConsent)
	// clang-format on
	{
		Context appContext = TiApplication.getInstance().getApplicationContext();
		ConsentInformation.getInstance(appContext).setTagForUnderAgeOfConsent(underAgeOfConsent);
	}

	@Kroll.method
	public void setTagForUnderAgeOfConsent(boolean underAgeOfConsent)
	{
		Log.w(TAG, "setTagForUnderAgeOfConsent is deprecated. Use <setIsTaggedForUnderAgeOfConsent> property instead.");
		Context appContext = TiApplication.getInstance().getApplicationContext();
		ConsentInformation.getInstance(appContext).setTagForUnderAgeOfConsent(underAgeOfConsent);
	}

	@Kroll.getProperty
	@Kroll.method
	public boolean getIsTaggedForUnderAgeOfConsent()
	{
		Context appContext = TiApplication.getInstance().getApplicationContext();
		return ConsentInformation.getInstance(appContext).isTaggedForUnderAgeOfConsent();
	}

	// clang-format off
	@Kroll.getProperty
	@Kroll.method
	public int getConsentStatus()
	// clang-format on
	{
		Context appContext = TiApplication.getInstance().getApplicationContext();
		return ConsentInformation.getInstance(appContext).getConsentStatus().ordinal();
	}

	// clang-format off
	@Kroll.getProperty
	@Kroll.method
	public int getDebugGeography()
	// clang-format on
	{
		Context appContext = TiApplication.getInstance().getApplicationContext();
		return ConsentInformation.getInstance(appContext).getDebugGeography().ordinal();
	}

	// clang-format off
	@Kroll.setProperty
	@Kroll.method
	public void setDebugGeography(int debugGeography)
	// clang-format on
	{
		Context appContext = TiApplication.getInstance().getApplicationContext();
		ConsentInformation.getInstance(appContext).setDebugGeography(DebugGeography.values()[debugGeography]);
	}

	@Kroll.method
	public void resetConsent()
	{
		Context appContext = TiApplication.getInstance().getApplicationContext();
		ConsentInformation.getInstance(appContext).reset();
	}

	// clang-format off
	@Kroll.getProperty
	@Kroll.method
	public KrollDict[] getAdProviders()
	// clang-format on
	{
		Context appContext = TiApplication.getInstance().getApplicationContext();
		List<AdProvider> adProviders = ConsentInformation.getInstance(appContext).getAdProviders();
		KrollDict[] result = new KrollDict[adProviders.size()];

		for (int i = 0; i < adProviders.size(); i++) {
			AdProvider adProvider = adProviders.get(i);
			KrollDict dict = new KrollDict();

			dict.put("identifier", adProvider.getId());
			dict.put("name", adProvider.getName());
			dict.put("privacyPolicyURL", adProvider.getPrivacyPolicyUrlString());

			result[i] = dict;
		}

		return result;
	}

	@Kroll.method
	public void setInMobi_updateGDPRConsent(boolean isEnable)
	{		
		JSONObject consentObject = new JSONObject();
		try {
			if (isEnable){
				consentObject.put(InMobiSdk.IM_GDPR_CONSENT_AVAILABLE, true);
				consentObject.put("gdpr", "1");
				Log.d(TAG, "inMobi GDPR enabled");
			} else {
				consentObject.put(InMobiSdk.IM_GDPR_CONSENT_AVAILABLE, true);
				consentObject.put("gdpr", "0");
				Log.d(TAG, "inMobi GDPR disabled");
			}
		} catch (JSONException exception) {
			Log.e(TAG, "inMobi GDPR error");
			exception.printStackTrace();
			return;
		}

		InMobiConsent.updateGDPRConsent(consentObject);
	}

	public static Bundle mapToBundle(Map<String, Object> map)
	{
		if (map == null) {
			return new Bundle();
		}

		Bundle bundle = new Bundle(map.size());

		for (String key : map.keySet()) {
			Object val = map.get(key);
			if (val == null) {
				bundle.putString(key, null);
			} else if (val instanceof TiBlob) {
				bundle.putByteArray(key, ((TiBlob) val).getBytes());
			} else if (val instanceof TiBaseFile) {
				try {
					bundle.putByteArray(key, ((TiBaseFile) val).read().getBytes());
				} catch (IOException e) {
					Log.e(TAG, "Unable to put '" + key + "' value into bundle: " + e.getLocalizedMessage(), e);
				}
			} else if (val instanceof AdmobSizeProxy) {
				//
			} else {
				bundle.putString(key, TiConvert.toString(val));
			}
		}

		return bundle;
	}

	public static AdRequest.Builder createRequestBuilderWithOptions(KrollDict options)
	{
		AdRequest.Builder adRequestBuilder = new AdRequest.Builder();
		if (options == null) {
			return adRequestBuilder;
		}
		Bundle bundle = createAdRequestExtrasBundleFromDictionary(options.getKrollDict("extras"));
		if (bundle.size() > 0) {
			adRequestBuilder.addNetworkExtrasBundle(AdMobAdapter.class, bundle);
		}
		// Handle keywords
		if (options.containsKeyAndNotNull("keywords")) {
			String[] keywords = options.getStringArray("keywords");
			for (int i = 0; i < keywords.length; i++) {
				adRequestBuilder.addKeyword(keywords[i]);
			}
		}
		// Handle contentURL
		if (options.containsKeyAndNotNull("contentURL")) {
			adRequestBuilder.setContentUrl(options.getString("contentURL"));
		}
		// Handle tagForChildDirectedTreatment
		if (options.containsKeyAndNotNull("tagForChildDirectedTreatment")) {
			adRequestBuilder.tagForChildDirectedTreatment(options.getBoolean("tagForChildDirectedTreatment"));
		}
		// Handle requestAgent
		if (options.containsKeyAndNotNull("requestAgent")) {
			adRequestBuilder.setRequestAgent(options.getString("requestAgent"));
		}
		// Handle testDevices
		if (options.containsKeyAndNotNull("testDevices")) {
			String[] testDevices = options.getStringArray("testDevices");
			for (int i = 0; i < testDevices.length; i++) {
				adRequestBuilder.addTestDevice(testDevices[i]);
			}
		}
		return adRequestBuilder;
	}

	// create the adRequest extras bundle
	private static Bundle createAdRequestExtrasBundleFromDictionary(KrollDict extrasDictionary)
	{
		Bundle bundle = new Bundle();
		if (extrasDictionary.containsKey(AdmobModule.PROPERTY_COLOR_BG)) {
			bundle.putString("color_bg", convertColorProp(extrasDictionary.getString(AdmobModule.PROPERTY_COLOR_BG)));
		}
		if (extrasDictionary.containsKey(AdmobModule.PROPERTY_COLOR_BG_TOP)) {
			bundle.putString("color_bg_top",
							 convertColorProp(extrasDictionary.getString(AdmobModule.PROPERTY_COLOR_BG_TOP)));
		}
		if (extrasDictionary.containsKey(AdmobModule.PROPERTY_COLOR_BORDER)) {
			bundle.putString("color_border",
							 convertColorProp(extrasDictionary.getString(AdmobModule.PROPERTY_COLOR_BORDER)));
		}
		if (extrasDictionary.containsKey(AdmobModule.PROPERTY_COLOR_TEXT)) {
			bundle.putString("color_text",
							 convertColorProp(extrasDictionary.getString(AdmobModule.PROPERTY_COLOR_TEXT)));
		}
		if (extrasDictionary.containsKey(AdmobModule.PROPERTY_COLOR_LINK)) {
			bundle.putString("color_link",
							 convertColorProp(extrasDictionary.getString(AdmobModule.PROPERTY_COLOR_LINK)));
		}
		if (extrasDictionary.containsKey(AdmobModule.PROPERTY_COLOR_URL)) {
			bundle.putString("color_url", convertColorProp(extrasDictionary.getString(AdmobModule.PROPERTY_COLOR_URL)));
		}
		return bundle;
	}

	// modifies the color prop -- removes # and changes constants into hex values
	public static String convertColorProp(String color)
	{
		color = color.replace("#", "");
		if (color.equals("white"))
			color = "FFFFFF";
		if (color.equals("red"))
			color = "FF0000";
		if (color.equals("blue"))
			color = "0000FF";
		if (color.equals("green"))
			color = "008000";
		if (color.equals("yellow"))
			color = "FFFF00";
		if (color.equals("black"))
			color = "000000";
		return color;
	}
}
