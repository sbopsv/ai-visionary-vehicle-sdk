package com.sbc;

import java.util.Properties;

import com.alibaba.cloudapi.sdk.constant.SdkConstant;
import com.alibaba.cloudapi.sdk.model.HttpClientBuilderParams;
import com.alibaba.cloudapi.sdk.model.ApiCallback;
import com.alibaba.cloudapi.sdk.model.ApiRequest;
import com.alibaba.cloudapi.sdk.model.ApiResponse;
import com.aliyun.HttpsApiClientDAMO_Vehicle_prod;
import com.google.gson.Gson;
import com.properties.ConfigProperties;
import com.sbc.model.Damage;
import com.sbc.model.Parts;


public class ApiExecutor {

    static {
        HttpClientBuilderParams httpsParam = new HttpClientBuilderParams();
        Properties cfg = ConfigProperties.GetConfig();
        httpsParam.setAppKey(cfg.getProperty("AppKey"));
        httpsParam.setAppSecret(cfg.getProperty("AppSecret"));
        
        HttpsApiClientDAMO_Vehicle_prod.getInstance().init(httpsParam);
    }

    public static void SBCDamageRfcn_prodHttps(String json){
        HttpsApiClientDAMO_Vehicle_prod.getInstance().SBCDamageRfcn_prod(json.getBytes(SdkConstant.CLOUDAPI_ENCODING), new ApiCallback() {
            @Override
            public void onFailure(ApiRequest request, Exception e) {
                e.printStackTrace();
            }

            @Override
            public void onResponse(ApiRequest request, ApiResponse response) {
                try {
                    // System.out.println(getResultString(response));
                    String body = new String(response.getBody());
                    Damage result = new Gson().fromJson(body, Damage.class);
                    System.out.println(result.ret);
                }
                catch (Exception ex) {
                    ex.printStackTrace();
                }
            }
        });
    }

    public static Damage SBCDamageRfcn_prodHttpsSync(String json){
        Damage result = null;
        ApiResponse response = HttpsApiClientDAMO_Vehicle_prod.getInstance().SBCDamageRfcn_prodSyncMode(json.getBytes(SdkConstant.CLOUDAPI_ENCODING));
        try {
            String body = new String(response.getBody());
            result = new Gson().fromJson(body, Damage.class);
            result.full(response.getCode(), response.getMessage(), response.getHeaders());
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return result;
    }


    public static Parts SBCPartDetection_prodHttpsSync(String json){
        Parts result = null;
        ApiResponse response = HttpsApiClientDAMO_Vehicle_prod.getInstance().SBCPartDetection_prodSyncMode(json.getBytes(SdkConstant.CLOUDAPI_ENCODING));
        try {
            String body = new String(response.getBody());
            result = new Gson().fromJson(body, Parts.class);
            result.full(response.getCode(), response.getMessage(), response.getHeaders());
        }catch (Exception ex){
            ex.printStackTrace();
        }

        return result;
    }
}
