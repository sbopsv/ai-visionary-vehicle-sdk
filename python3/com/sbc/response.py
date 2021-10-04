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

from com.aliyun.api.gateway.sdk.common import constant
from com.sbc.debug_util import DebugUtil

import json
from simplejson import JSONDecodeError

class ResponseConverter():
    def __init__(self, response_tuple):
        self.__status = response_tuple[0]

        self.set_header(response_tuple[1])

        self.__error_code_gw    = None
        self.__error_message_gw = None
        self.__error_message    = None
        self.__error            = None
        
        self.set_body(response_tuple[2])

    # def get_context(self):
    #     DebugUtil.debug('CONTENT', self.__content)
    #     return self.__content

    def get_context_type(self):
        DebugUtil.debug('CONTENT_TYPE', self.__content_type)
        return self.__content_type

    def set_header(self, header):
        self.__header = header

        for key, value in header:
            if key == constant.HTTP_HEADER_CONTENT_TYPE:
                self.__content_type = value
            elif key == constant.X_CA_REQUEST_ID:
                self.__request_id = value
            elif key == constant.X_CA_ERROR_MESSAGE:
                self.__error_message_gw = value
            elif key == constant.X_CA_ERROR_CODE:
                self.__error_code_gw = value

    def get_header(self):
        DebugUtil.debug('HEADER', self.__header)
        return self.__header

    def get_request_id(self):
        DebugUtil.debug('REQUEST_ID', self.__request_id)
        return self.__request_id

    def get_status(self):
        DebugUtil.debug('STATUS_CODE', self.__status)
        return self.__status

    def get_error_messages(self):
        errorMessages = []
        if self.__error_message_gw is not None:
            errorMessages.append(self.__error_message_gw)

        if self.__error_code_gw is not None:
            errorMessages.append(self.__error_code_gw)

        if self.__error_message is not None:
            errorMessages.append(self.__error_message)

        if self.__error is not None:
            errorMessages.append(self.__error)

        self.__errorMessages = errorMessages
        DebugUtil.debug('ERROR_MESSAGES', self.__errorMessages)
        return self.__errorMessages

    def set_body(self, body):
        self.__body = body

        size = len(body)
        if size == 0:
            DebugUtil.debug('WARN', 'no content')
            self.get_status()
            self.get_header()
            self.get_error_messages()
            return

        try:
            jsonBody = json.loads(body)

            if self.__status != 200:
                self.__error_message = jsonBody['errorMessage']
                if 'error' in jsonBody:
                    self.__error = jsonBody['error']

                self.get_error_messages()
                return

            self.__bbox = jsonBody['results']['bbox']

        except JSONDecodeError as e:
            DebugUtil.debug('JSONDecodeError', e)
            DebugUtil.debug('ERROR', body)
        except:
            DebugUtil.debug('ERROR', body)

    def get_body(self):
        DebugUtil.debug('BODY', self.__body)
        return self.__body

    def get_bbox_iterator(self, type_threshold, score_threshold):
        self.__bbox_iterator = BBoxIterator(self.__bbox, type_threshold, score_threshold)
        return self.__bbox_iterator

    def get_error_message(self):
        return self.__error_message

    def get_error(self):
        return self.__error

    def get_gw_error(self):
        return self.__error_code_gw, self.__error_message_gw

class BBox():
    def __init__(self, value):
        if 'type' in value:
            self.__type = value['type']
        else:
            self.__type = value['Type']

        if 'score' in value:     
            self.__score = float(value['score'])
        else:
            self.__score = float(value['Score'])
        
        if 'location' in value:     
            self._location = value['location']
        else:
            self._location = value['Boxes']

    def get_info(self):
        return '{} : {} location:{}'.format(self.__type, self.__score, self._location) 

    def get_type(self):
        return self.__type

    def get_score(self):
        return self.__score

class BBoxIterator():
    def __init__(self, bbox, type_threshold, score_threshold):
        self.args = []
        self.__type_threshold = type_threshold
        self.__score_threshold = score_threshold

        for value in bbox:
            self.add(BBox(value))
        self.i = 0

    def add(self, bbox):
        self.args.append(bbox)

    def __iter__(self):
        return self

    def __next__(self):
        if self.i == len(self.args):
            raise StopIteration()

        ret = self.args[self.i]
        self.i += 1

        if self.__type_threshold is not None and ret.get_type() != self.__type_threshold:
                return self.__next__()
        
        if ret.get_score() < self.__score_threshold:
                return self.__next__()

        return ret