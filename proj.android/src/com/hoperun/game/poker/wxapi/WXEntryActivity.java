package com.hoperun.game.poker.wxapi;

import org.cocos2dx.lib.Cocos2dxActivity;
import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;
import org.cocos2dx.lua.AppActivity;

import com.tencent.mm.sdk.modelbase.BaseReq;
import com.tencent.mm.sdk.modelbase.BaseResp;
import com.tencent.mm.sdk.openapi.IWXAPI;
import com.tencent.mm.sdk.openapi.IWXAPIEventHandler;
import com.tencent.mm.sdk.openapi.WXAPIFactory;

import android.annotation.SuppressLint;
import android.os.Bundle;
import android.util.Log;

public class WXEntryActivity extends Cocos2dxActivity implements IWXAPIEventHandler {
	
	private IWXAPI api;
	private static final String TAG = "WXEntryActivity";
	@Override
	public void onCreate(Bundle savedInstanceState) {
		Log.i(TAG, "onCreate");
		super.onCreate(savedInstanceState);
		api = WXAPIFactory.createWXAPI(this, AppActivity.APP_ID_ANDROID_WECHAT,
				false);
		api.handleIntent(getIntent(), this);
	}

	@Override
	public void onReq(BaseReq req) {
		req.getType();
	}

	@SuppressLint("ShowToast") @Override
	public void onResp(BaseResp resp) {
		String transaction = resp.transaction;
		Log.i(TAG, transaction);
		String strResult = "{['type'] = 0, ['result'] = 'failed'}";
		switch (resp.errCode) {
		case BaseResp.ErrCode.ERR_OK:
			Log.i(TAG, "ERR_OK");
			if (transaction.contains(AppActivity.SHARE_TO_SESSION_STRING)) {
				strResult = "{['type'] = 0, ['result'] = 'success'}";
			} else if (transaction.contains(AppActivity.SHARE_TO_TIMELINE_STRING)) {
				strResult = "{['type'] = 1, ['result'] = 'success'}";
			}
			break;
		case BaseResp.ErrCode.ERR_USER_CANCEL:
		case BaseResp.ErrCode.ERR_AUTH_DENIED:
		default:
			break;
		}
		final String resultString = strResult;
		runOnGLThread(new Runnable() {
			
			@Override
			public void run() {
				Log.i(TAG, resultString);
				int ret = Cocos2dxLuaJavaBridge.callLuaFunctionWithString(AppActivity.callBackShareId, resultString);	
				Cocos2dxLuaJavaBridge.releaseLuaFunction(AppActivity.callBackShareId);
				Log.i(TAG, "" + ret);
			}
		});
		finish();
	}

}
