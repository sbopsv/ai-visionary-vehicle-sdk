# -*- coding:utf-8 -*-
# Copyright 2021-present SB Cloud Corp.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#
# See the License for the specific language governing permissions and
# limitations under the License.
#
# coding=utf-8

from com.aliyun.api.gateway.sdk import client
from com.aliyun.api.gateway.sdk.common import constant
from com.aliyun.api.gateway.sdk.http import request

from com.sbc.response import ResponseConverter
from com.sbc.debug_util import DebugUtil

import base64
import json

#######################################################################################
class ApiExecutor():

    ##################################################
    # Post BodyStream
    def postStream(host, path, appKey, appSecret, file_name=None, file_url=None):
        cli = client.DefaultClient(app_key=appKey, app_secret=appSecret)
        req_post = request.Request(host=host, protocol=constant.HTTPS, url=path, method='POST', time_out=30000)
        bodyMap = {}

        if file_name is not None :
            # case1) base64 raw data
            # encode to base64
            with open(file_name, 'rb') as f1:
                # print(str(b64_img))  # iVBORw0KGgoAAAANSUhEU・・
                b64_img = base64.b64encode(f1.read()).decode('utf-8')
                bodyMap['image'] = b64_img
        else:
            # case2) imageURL on OSS bucket
            bodyMap['url'] = file_url

        req_post.set_body(bytearray(source=json.dumps(bodyMap), encoding='utf8'))
        req_post.set_content_type(constant.CONTENT_TYPE_STREAM)
        response = cli.execute(req_post)
        return response

    ##################################################
    # Dump Response
    def dumpResponse(response, type, score):
        converter = ResponseConverter(response)
        
        DebugUtil.debug('----------------------------------', None)
        converter.get_context_type()

        DebugUtil.debug('----------------------------------', None)
        converter.get_header()
        converter.get_request_id()
        converter.get_status()

        DebugUtil.debug('----------------------------------', None)
        errors = converter.get_error_messages()

        if len(errors) > 0:
            return

        DebugUtil.debug('----------------------------------', None)
        bboxIterator = converter.get_bbox_iterator(None, 0.0)
        for bbox_ in bboxIterator :
            DebugUtil.debug('BOX', bbox_.get_info())
		
        DebugUtil.debug('----------------------------------', None)
        bboxIterator = converter.get_bbox_iterator(type, score)
        for bbox_ in bboxIterator :
            DebugUtil.debug('BOX', bbox_.get_info())

        DebugUtil.debug('DONE', None)