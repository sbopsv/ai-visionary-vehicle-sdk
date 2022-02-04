//
//  Created by  fred on 2017/1/12.
//  Copyright © 2016年 Alibaba. All rights reserved.
//

package com.aliyun;
import com.alibaba.cloudapi.sdk.client.ApacheHttpClient;
import com.alibaba.cloudapi.sdk.enums.Scheme;
import com.alibaba.cloudapi.sdk.model.HttpClientBuilderParams;
import com.fasterxml.jackson.databind.ObjectMapper;


public class HttpApiClientDAMO_Vehicle_prod extends ApacheHttpClient{
    public final static String HOST = "host";
    static HttpApiClientDAMO_Vehicle_prod instance = new HttpApiClientDAMO_Vehicle_prod();
    public static HttpApiClientDAMO_Vehicle_prod getInstance(){return instance;}
    public static final ObjectMapper mapper = new ObjectMapper();

    public void init(HttpClientBuilderParams httpClientBuilderParams){
        httpClientBuilderParams.setScheme(Scheme.HTTP);
        httpClientBuilderParams.setHost(HOST);
        super.init(httpClientBuilderParams);
    }
}