/****************************************************************************
Copyright (c) 2008-2010 Ricardo Quesada
Copyright (c) 2010-2012 cocos2d-x.org
Copyright (c) 2011      Zynga Inc.
Copyright (c) 2013-2014 Chukong Technologies Inc.
 
http://www.cocos2d-x.org

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
****************************************************************************/
package org.cocos2dx.lua;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.util.ArrayList;

import org.cocos2dx.lua.AppActivity;
import org.cocos2dx.lib.Cocos2dxActivity;
import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.alipay.sdk.app.PayTask;
import com.hoperun.game.poker.R;
import com.tencent.mm.sdk.modelmsg.SendMessageToWX;
import com.tencent.mm.sdk.modelmsg.WXMediaMessage;
import com.tencent.mm.sdk.modelmsg.WXWebpageObject;
import com.tencent.mm.sdk.modelpay.PayReq;
import com.tencent.mm.sdk.openapi.IWXAPI;
import com.tencent.mm.sdk.openapi.WXAPIFactory;
import com.unionpay.UPPayAssistEx;
import com.unionpay.uppay.PayActivity;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.ContextWrapper;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.provider.Settings;
import android.text.TextUtils;
import android.util.Log;
import android.view.WindowManager;
import android.widget.Toast;


public class AppActivity extends Cocos2dxActivity{
	private static AppActivity __activity;
    static String hostIPAdress = "0.0.0.0";
    public static int callBackPayId;
    private static final int ALI_PAY_FLAG = 1;
    private static final int UP_PAY_FLAG = 2;
	private static IWXAPI wxApi;
	public static int callBackShareId;
	private static final int TIMELINE_SUPPORTED_VERSION = 0x21020001;
	public static final String APP_ID_ANDROID_WECHAT = "wx0786bc98cf3b80ed";
	public static final String SHARE_TO_TIMELINE_STRING = "scene_timeline";
	public static final String SHARE_TO_SESSION_STRING = "scene_session";
	private static Handler mHandler = new Handler() {
		public void handleMessage(Message msg) {
			switch (msg.what) {
			case ALI_PAY_FLAG:
				AliPayResult payResult = new AliPayResult((String)msg.obj);
				String resultInfo = payResult.getResult();
				String resultStatus = payResult.getResultStatus();
				String strResult = "'failed'";
				if (TextUtils.equals(resultStatus, "9000")) {
					//成功
					strResult = "'success'";
				}
				else {
					if (TextUtils.equals(resultInfo, "8000")) {
						//支付结果确认中
						strResult = "'comfirm'";
					}
					else {
						//支付失败
						strResult = "'failed'";
					}
				}
				final String resultString = "{['type'] = 0, ['result'] = " + strResult + "}";
				__activity.runOnGLThread(new Runnable() {
					
					@Override
					public void run() {
						Log.i("AliPayResult", resultString);
						Cocos2dxLuaJavaBridge.callLuaFunctionWithString(callBackPayId, resultString);		
						Cocos2dxLuaJavaBridge.releaseLuaFunction(callBackPayId);	
					}
				});
				break;
			case UP_PAY_FLAG:
				break;
			default: 
				break;
			}
		}
    };
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        __activity = this;

		wxApi = WXAPIFactory.createWXAPI(this, APP_ID_ANDROID_WECHAT, false);
		wxApi.registerApp(APP_ID_ANDROID_WECHAT);
		
        if(nativeIsLandScape()) {
            setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_SENSOR_LANDSCAPE);
        } else {
            setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_SENSOR_PORTRAIT);
        }
        
        //2.Set the format of window
        
        // Check the wifi is opened when the native is debug.
        if(nativeIsDebug())
        {
            getWindow().setFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON, WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
            if(!isNetworkConnected())
            {
                AlertDialog.Builder builder=new AlertDialog.Builder(this);
                builder.setTitle("Warning");
                builder.setMessage("Please open WIFI for debuging...");
                builder.setPositiveButton("OK",new DialogInterface.OnClickListener() {
                    
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        startActivity(new Intent(Settings.ACTION_WIFI_SETTINGS));
                        finish();
                        System.exit(0);
                    }
                });

                builder.setNegativeButton("Cancel", null);
                builder.setCancelable(true);
                builder.show();
            }
            hostIPAdress = getHostIpAddress();
        }
    }
    private boolean isNetworkConnected() {
            ConnectivityManager cm = (ConnectivityManager) getSystemService(Context.CONNECTIVITY_SERVICE);  
            if (cm != null) {  
                NetworkInfo networkInfo = cm.getActiveNetworkInfo();  
            ArrayList networkTypes = new ArrayList();
            networkTypes.add(ConnectivityManager.TYPE_WIFI);
            try {
                networkTypes.add(ConnectivityManager.class.getDeclaredField("TYPE_ETHERNET").getInt(null));
            } catch (NoSuchFieldException nsfe) {
            }
            catch (IllegalAccessException iae) {
                throw new RuntimeException(iae);
            }
            if (networkInfo != null && networkTypes.contains(networkInfo.getType())) {
                    return true;  
                }  
            }  
            return false;  
        } 
     
    public String getHostIpAddress() {
        WifiManager wifiMgr = (WifiManager) getSystemService(WIFI_SERVICE);
        WifiInfo wifiInfo = wifiMgr.getConnectionInfo();
        int ip = wifiInfo.getIpAddress();
        return ((ip & 0xFF) + "." + ((ip >>>= 8) & 0xFF) + "." + ((ip >>>= 8) & 0xFF) + "." + ((ip >>>= 8) & 0xFF));
    }
    
    public static String getAppInfo(){
    	Log.i("getAppInfo", "getAppInfo is called");
    	try {
			PackageManager manager = ((ContextWrapper) GetActivity()).getPackageManager();
			PackageInfo info = manager.getPackageInfo(((ContextWrapper) GetActivity()).getPackageName(), 0);
			String v = "{['app_build'] = '"+ info.versionName
					+"', ['app_version'] = '" + info.versionCode + "'}";
			return v;
		} catch (Exception e) {
			e.printStackTrace();
			return " ";
		}
    }
    
    public void startAliPay(final String orderInfo, int callBack){
    	callBackPayId = callBack;
    	Runnable aliPayRunnable = new Runnable() {
			
			@Override
			public void run() {
				Log.i("AliPayThead", "run");
				PayTask payTask = new PayTask((Activity)GetActivity());
				Log.i("AliPaySign", orderInfo);
				String strResult = payTask.pay(orderInfo);
				Message msg = new Message();
				msg.what = ALI_PAY_FLAG;
				msg.obj = strResult;
				mHandler.handleMessage(msg);
			}
		};
		Thread payThread = new Thread(aliPayRunnable);
		payThread.start();
    }
    
    public static void AliPay(final String orderInfo, final int callBack){
    	Log.i("AliPayApi", orderInfo);
		((AppActivity)GetActivity()).startAliPay(orderInfo, callBack);
    }
    
    public static boolean isWeChatInstalled(){
		boolean isInstalled = wxApi.isWXAppInstalled();
		return isInstalled;
	}
	
	public static boolean isTimeLineSupported(){
		boolean isSupported = wxApi.getWXAppSupportAPI() >= TIMELINE_SUPPORTED_VERSION;
		return isSupported;
	}
	
	//分享至微信，scene为1时分享至朋友圈，否则为发送给好友
	public static void shareToWeChat(int scene, String title, String description, String url, final int callBack){
		Log.i("WXEntryActivity", APP_ID_ANDROID_WECHAT);
		callBackShareId = callBack;
		WXWebpageObject webpage = new WXWebpageObject();
		webpage.webpageUrl = url;
		WXMediaMessage msg = new WXMediaMessage(webpage);
		msg.title = title;
		msg.description = description;
		Bitmap thumb = BitmapFactory.decodeResource(((AppActivity)GetActivity()).getResources(), R.drawable.share_icon);
		msg.setThumbImage(thumb);
		
		SendMessageToWX.Req req = new SendMessageToWX.Req();
		String transaction = scene == 1 ? SHARE_TO_TIMELINE_STRING : SHARE_TO_SESSION_STRING;
		req.transaction = buildTransaction(transaction);
		req.message = msg;
		req.scene = scene == 1 ? SendMessageToWX.Req.WXSceneTimeline : SendMessageToWX.Req.WXSceneSession;
		wxApi.sendReq(req);
	}
	private static String buildTransaction(final String type) {
		return (type == null) ? String.valueOf(System.currentTimeMillis()) : type + System.currentTimeMillis();
	}
	public static void WXPay(String strPayInfo)
	{
		PayReq payReq = new PayReq();
		payReq.appId = APP_ID_ANDROID_WECHAT;
		try {
			JSONArray jsonArray = new JSONArray(strPayInfo);
			JSONObject data = jsonArray.getJSONObject(0);
			payReq.appId = data.getString("appId");
			//todo:完整填充字段
			wxApi.sendReq(payReq);
		} catch (JSONException e) {
			Log.e("WxPay", "JSON erro");
			e.printStackTrace();
		}
	}
	
	public static void UPPay(final String strTn, final int callBack){
		Log.i("UPPayApi", strTn);
		callBackPayId = callBack;
		UPPayAssistEx.startPayByJAR((AppActivity) GetActivity(), PayActivity.class, null, null, strTn, "01");
	}
	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data){
		if (data == null) {
			return;
		}
		
		String strResult = "failed";
		
		String str = data.getExtras().getString("pay_result");
		if (str.equalsIgnoreCase("success")) {
			strResult = "'success'";
		}
		else if (str.equalsIgnoreCase("fail")) {
			strResult = "'failed'";
		}
		else if (str.equalsIgnoreCase("cancel")) {
			strResult = "'canceled'";
		}
		final String resultString = "{['type'] = 0, ['result'] = " + strResult + "}";
		Log.i("UPPay", resultString);
		runOnGLThread(new Runnable() {
			
			@Override
			public void run() {
				Cocos2dxLuaJavaBridge.callLuaFunctionWithString(callBackPayId, resultString);
				Cocos2dxLuaJavaBridge.releaseLuaFunction(callBackPayId);
			}
		});
	}
    
    public static String getLocalIpAddress() {
        return hostIPAdress;
    }
    
    public static Object GetActivity() {
		return __activity;
	}
    
    
    private static native boolean nativeIsLandScape();
    private static native boolean nativeIsDebug();
    
}
