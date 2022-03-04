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

import com.alibaba.cloudapi.sdk.client.ApacheHttpClient;
import com.alibaba.cloudapi.sdk.enums.HttpMethod;
import com.alibaba.cloudapi.sdk.enums.Scheme;
import com.alibaba.cloudapi.sdk.model.ApiCallback;
import com.alibaba.cloudapi.sdk.model.ApiRequest;
import com.alibaba.cloudapi.sdk.model.ApiResponse;
import com.alibaba.cloudapi.sdk.model.HttpClientBuilderParams;

import com.sb.cloudapi.client.config.ConfigProperties;

public class HttpsApiClientDAMO_Vehicle_prod extends ApacheHttpClient {

    private static HttpsApiClientDAMO_Vehicle_prod instance = new HttpsApiClientDAMO_Vehicle_prod();
    public static HttpsApiClientDAMO_Vehicle_prod getInstance() {return instance;}

    public void init(HttpClientBuilderParams httpClientBuilderParams) {
        String HOST = ConfigProperties.getProperty("Host");
        httpClientBuilderParams.setScheme(Scheme.HTTPS);
        httpClientBuilderParams.setHost(HOST);
        super.init(httpClientBuilderParams);
    }

    public void SBCDamageRfcn_prod(byte[] body , ApiCallback callback) {
        String path = ConfigProperties.getProperty("Damage");
        ApiRequest request = new ApiRequest(HttpMethod.POST_BODY , path, body);

        sendAsyncRequest(request , callback);
    }

    public ApiResponse SBCDamageRfcn_prodSyncMode(byte[] body) {
        String path = ConfigProperties.getProperty("Damage");
        ApiRequest request = new ApiRequest(HttpMethod.POST_BODY , path, body);

        return sendSyncRequest(request);
    }
    
    public void SBCPartDetection_prod(byte[] body , ApiCallback callback) {
        String path = ConfigProperties.getProperty("Parts");
        ApiRequest request = new ApiRequest(HttpMethod.POST_BODY , path, body);
    
        sendAsyncRequest(request , callback);
    }

    public ApiResponse SBCPartDetection_prodSyncMode(byte[] body) {
        String path = ConfigProperties.getProperty("Parts");
        ApiRequest request = new ApiRequest(HttpMethod.POST_BODY , path, body);

        return sendSyncRequest(request);
    }

}