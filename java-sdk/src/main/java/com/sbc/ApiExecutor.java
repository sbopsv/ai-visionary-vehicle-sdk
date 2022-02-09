package com.sbc;

import java.util.Properties;

import com.alibaba.cloudapi.sdk.constant.SdkConstant;
import com.alibaba.cloudapi.sdk.model.HttpClientBuilderParams;
import com.alibaba.cloudapi.sdk.model.ApiCallback;
import com.alibaba.cloudapi.sdk.model.ApiRequest;
import com.alibaba.cloudapi.sdk.model.ApiResponse;
import com.aliyun.HttpsApiClientDAMO_Vehicle_prod;

import com.properties.ConfigProperties;


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
                    System.out.println(response.getCode());
                }
                catch (Exception ex) {
                    ex.printStackTrace();
                }
            }
        });
    }
}
