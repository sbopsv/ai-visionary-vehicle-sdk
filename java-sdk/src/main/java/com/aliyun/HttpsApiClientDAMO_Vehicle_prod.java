//
//  Created by  fred on 2017/1/12.
//  Copyright © 2016年 Alibaba. All rights reserved.
//

package com.aliyun;

import com.alibaba.cloudapi.sdk.client.ApacheHttpClient;
import com.alibaba.cloudapi.sdk.enums.HttpMethod;
import com.alibaba.cloudapi.sdk.enums.Scheme;
import com.alibaba.cloudapi.sdk.model.ApiCallback;
import com.alibaba.cloudapi.sdk.model.ApiRequest;
import com.alibaba.cloudapi.sdk.model.ApiResponse;
import com.alibaba.cloudapi.sdk.model.HttpClientBuilderParams;

public class HttpsApiClientDAMO_Vehicle_prod extends ApacheHttpClient{
    public final static String HOST = "host";
    static HttpsApiClientDAMO_Vehicle_prod instance = new HttpsApiClientDAMO_Vehicle_prod();
    public static HttpsApiClientDAMO_Vehicle_prod getInstance(){return instance;}

    public void init(HttpClientBuilderParams httpClientBuilderParams){
        httpClientBuilderParams.setScheme(Scheme.HTTPS);
        httpClientBuilderParams.setHost(HOST);
        super.init(httpClientBuilderParams);
    }



    public void SBCDamageRfcn_prod(byte[] body , ApiCallback callback) {
        String path = "path";
        ApiRequest request = new ApiRequest(HttpMethod.POST_BODY , path, body);
        


        sendAsyncRequest(request , callback);
    }

    public ApiResponse SBCDamageRfcn_prodSyncMode(byte[] body) {
        String path = "path";
        ApiRequest request = new ApiRequest(HttpMethod.POST_BODY , path, body);
        


        return sendSyncRequest(request);
    }
    public void SBCPartDetection_prod(byte[] body , ApiCallback callback) {
        String path = "path";
        ApiRequest request = new ApiRequest(HttpMethod.POST_BODY , path, body);
        


        sendAsyncRequest(request , callback);
    }

    public ApiResponse SBCPartDetection_prodSyncMode(byte[] body) {
        String path = "path";
        ApiRequest request = new ApiRequest(HttpMethod.POST_BODY , path, body);
        


        return sendSyncRequest(request);
    }

}