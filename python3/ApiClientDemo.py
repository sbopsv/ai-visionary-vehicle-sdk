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

from com.aliyun.api.gateway.sdk.http import response

from com.sbc.api_executor import ApiExecutor
from com.sbc.debug_util import DebugUtil

import configparser

#######################################################################################
config = configparser.ConfigParser(interpolation=None)
config.read('config.ini')

host = config.get('BASE', 'host')
parts_path = config.get('PARTS', 'path')
damage_path = config.get('DAMAGE', 'path')

# for signature
appKey = config.get('CRED', 'appKey')
appSecret = config.get('CRED', 'appSecret')

# for parameter
file_url = config.get('PARAM', 'imgURL')
file_name = config.get('PARAM', 'imgFile')

#######################################################################################
# for Vehicle Parts API
# execute with file_name
response = ApiExecutor.postStream(host, parts_path, appKey, appSecret, file_name=file_name)
ApiExecutor.dumpResponse(response, 'hood', 0.4)

# DebugUtil.debug('----------------------------------', None)

# execute with file_url
response = ApiExecutor.postStream(host, parts_path, appKey, appSecret, file_url=file_url)
ApiExecutor.dumpResponse(response, 'front_bumper', 0.4)

#######################################################################################
# for Vehicle Damage API
# execute with file_name
response = ApiExecutor.postStream(host, damage_path, appKey, appSecret, file_name=file_name)
ApiExecutor.dumpResponse(response, '14', 0.4)

# DebugUtil.debug('----------------------------------', None)

# execute with file_url
response = ApiExecutor.postStream(host, damage_path, appKey, appSecret, file_url=file_url)
ApiExecutor.dumpResponse(response, '11', 0.4)

#######################################################################################