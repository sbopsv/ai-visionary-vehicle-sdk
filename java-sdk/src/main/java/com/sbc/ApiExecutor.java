package com.sbc;

import com.alibaba.cloudapi.sdk.constant.SdkConstant;
import com.alibaba.cloudapi.sdk.model.HttpClientBuilderParams;
import com.alibaba.cloudapi.sdk.model.ApiCallback;
import com.alibaba.cloudapi.sdk.model.ApiRequest;
import com.alibaba.cloudapi.sdk.model.ApiResponse;
import com.aliyun.HttpsApiClientDAMO_Vehicle_prod;


public class ApiExecutor {

    static {
        HttpClientBuilderParams httpsParam = new HttpClientBuilderParams();
        httpsParam.setAppKey("key");
        httpsParam.setAppSecret("secret");
        
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
