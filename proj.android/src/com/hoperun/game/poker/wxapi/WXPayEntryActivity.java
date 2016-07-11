package com.hoperun.game.poker.wxapi;


import org.cocos2dx.lib.Cocos2dxActivity;
import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;
import org.cocos2dx.lua.AppActivity;

import com.hoperun.game.poker.R;
import com.tencent.mm.sdk.constants.ConstantsAPI;
import com.tencent.mm.sdk.modelbase.BaseReq;
import com.tencent.mm.sdk.modelbase.BaseResp;
import com.tencent.mm.sdk.openapi.IWXAPI;
import com.tencent.mm.sdk.openapi.IWXAPIEventHandler;
import com.tencent.mm.sdk.openapi.WXAPIFactory;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;

public class WXPayEntryActivity extends Cocos2dxActivity implements IWXAPIEventHandler{
	
	private static final String TAG = "MicroMsg.SDKSample.WXPayEntryActivity";
	
    private IWXAPI api;
	
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        
    	api = WXAPIFactory.createWXAPI(this, AppActivity.APP_ID_ANDROID_WECHAT);

        api.handleIntent(getIntent(), this);
    }

	@Override
	protected void onNewIntent(Intent intent) {
		super.onNewIntent(intent);
		setIntent(intent);
        api.handleIntent(intent, this);
	}

	@Override
	public void onReq(BaseReq req) {
	}

	@Override
	public void onResp(BaseResp resp) {
		Log.d(TAG, "onPayFinish, errCode = " + resp.errCode);
		String strResult = "failed";
		if (resp.getType() == ConstantsAPI.COMMAND_PAY_BY_WX) {
			//AlertDialog.Builder builder = new AlertDialog.Builder(this);
			//builder.setTitle(R.string.app_tip);
			//builder.setMessage(getString(R.string.pay_result_callback_msg, resp.errStr +";code=" + String.valueOf(resp.errCode)));
			//builder.show();
			switch (resp.errCode) {
			case 0:
				strResult = "'success'";
				break;
			case -1:
				strResult = "'error'";
				break;
			case -2:
				strResult = "'canceled'";
				break;

			default:
				break;
			}
			final String resultString = "{['type'] = 0, ['result'] = " + strResult + "}";
			runOnGLThread(new Runnable() {
				
				@Override
				public void run() {
					Log.i("AliPayResult", resultString);
					Cocos2dxLuaJavaBridge.callLuaFunctionWithString(AppActivity.callBackPayId, resultString);	
					Cocos2dxLuaJavaBridge.releaseLuaFunction(AppActivity.callBackPayId);		
				}
			});			
		}
		finish();
	}
}