/*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*    http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/
package com.sb.cloudapi.client;

import com.alibaba.cloudapi.sdk.constant.SdkConstant;
import com.alibaba.cloudapi.sdk.model.ApiCallback;
import com.alibaba.cloudapi.sdk.model.ApiRequest;
import com.alibaba.cloudapi.sdk.model.ApiResponse;
import com.alibaba.cloudapi.sdk.model.HttpClientBuilderParams;

import com.sb.cloudapi.client.config.ConfigProperties;
import com.sb.cloudapi.client.model.Damage;
import com.sb.cloudapi.client.model.Parts;

import com.google.gson.Gson;

public class ApiExecutor {

    static {
        //HTTPS Client init
        HttpClientBuilderParams httpsParam = new HttpClientBuilderParams();

        httpsParam.setAppKey(ConfigProperties.getProperty("AppKey"));
        httpsParam.setAppSecret(ConfigProperties.getProperty("AppSecret"));
        
        HttpsApiClientDAMO_Vehicle_prod.getInstance().init(httpsParam);
    }

    public static void SBCPartDetection_prodHttps(String json) {
        HttpsApiClientDAMO_Vehicle_prod.getInstance().SBCPartDetection_prod(json.getBytes(SdkConstant.CLOUDAPI_ENCODING), new ApiCallback() {
            @Override
            public void onFailure(ApiRequest request, Exception e) {
                e.printStackTrace();
            }

            @Override
            public void onResponse(ApiRequest request, ApiResponse response) {
                try {
                    String body = new String(response.getBody());
                    Damage result = new Gson().fromJson(body, Damage.class);
                    System.out.println(result.ret);
                } catch (Exception ex) {
                    ex.printStackTrace();
                }
            }
        });
    }

    public static Parts SBCPartDetection_prodHttpsSync(String json) {
        Parts result = null;
        ApiResponse response = HttpsApiClientDAMO_Vehicle_prod.getInstance().SBCPartDetection_prodSyncMode(json.getBytes(SdkConstant.CLOUDAPI_ENCODING));
        try {
            String body = new String(response.getBody());
            result = new Gson().fromJson(body, Parts.class);
            result.full(response.getCode(), response.getMessage(), response.getHeaders());
        } catch (Exception ex) {
            ex.printStackTrace();
        }

        return result;
    }



    public static void SBCDamageRfcn_prodHttps(String json) {
        HttpsApiClientDAMO_Vehicle_prod.getInstance().SBCDamageRfcn_prod(json.getBytes(SdkConstant.CLOUDAPI_ENCODING), new ApiCallback() {
            @Override
            public void onFailure(ApiRequest request, Exception e) {
                e.printStackTrace();
            }

            @Override
            public void onResponse(ApiRequest request, ApiResponse response) {
                try {
                    String body = new String(response.getBody());
                    Damage result = new Gson().fromJson(body, Damage.class);
                    System.out.println(result.ret);
                } catch (Exception ex) {
                    ex.printStackTrace();
                }
            }
        });
    }

    public static Damage SBCDamageRfcn_prodHttpsSync(String json) {
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
}
