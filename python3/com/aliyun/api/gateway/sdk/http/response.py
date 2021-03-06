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
from com.aliyun.api.gateway.sdk.http.request import Request
import http.client as httplib
from urllib.parse import urlsplit, urlencode

class Response(Request):
    def __init__(self, host=None, url=None, method=constant.GET, headers={}, protocol=constant.HTTP, content_type=None, content=None, port=None,
                    key_file=None, cert_file=None, time_out=None):
        Request.__init__(self, host=host, protocol=protocol, url=url, headers=headers, method=method, time_out=time_out)
        self.__ssl_enable = False
        if protocol == constant.HTTPS:
            self.__ssl_enable = True
        self.__key_file = key_file
        self.__cert_file = cert_file
        self.__port = port
        self.__connection = None
        self.set_body(content)
        self.set_content_type(content_type)

    def set_ssl_enable(self, enable):
        self.__ssl_enable = enable

    def get_ssl_enable(self):
        return self.__ssl_enable

    def get_response(self):
        if self.get_ssl_enabled():
            return self.get_https_response()
        else:
            return self.get_http_response()

    def get_response_object(self):
        if self.get_ssl_enabled():
            return self.get_https_response_object()
        else:
            return self.get_http_response_object()

    # TODO shinzato modify
    def parse_host(self):
        splits = urlsplit(self.get_host())
        host = splits.netloc
        return host

    def get_http_response(self):
        if self.__port is None or self.__port == '':
            self.__port = 80
        try:
            self.__connection = httplib.HTTPConnection(self.parse_host(), self.__port)
            self.__connection.connect()
            post_data = None
            if self.get_content_type() == constant.CONTENT_TYPE_FORM and self.get_body():
                # TODO shinzato modify
                post_data = urlencode(self.get_body())
            else:
                post_data = self.get_body()
            self.__connection.request(method=self.get_method(), url=self.get_url(), body=post_data,
                                        headers=self.get_headers())
            response = self.__connection.getresponse()
            return response.status, response.getheaders(), response.read()
        except Exception as e:
            return None, None, None
        finally:
            self.__close_connection()

    def get_http_response_object(self):
        if self.__port is None or self.__port == '':
            self.__port = 80
        try:
            self.__connection = httplib.HTTPConnection(self.parse_host(self.get_host()), self.__port)
            self.__connection.connect()
            self.__connection.request(method=self.get_method(), url=self.get_url(), body=self.get_body(),
                                        headers=self.get_headers())
            response = self.__connection.getresponse()
            return response.status, response.getheaders(), response.read()
        except Exception as e:
            return None, None, None
        finally:
            self.__close_connection()

    def get_https_response(self):
        try:
            self.__port = 443
            self.__connection = httplib.HTTPSConnection(self.parse_host(), self.__port,
                                                        cert_file=self.__cert_file,
                                                        key_file=self.__key_file)
            self.__connection.connect()
            post_data = None
            if self.get_content_type() == constant.CONTENT_TYPE_FORM and self.get_body():
                # TODO shinzato modify
                post_data = urlencode(self.get_body())
            else:
                post_data = self.get_body()
            self.__connection.request(method=self.get_method(), url=self.get_url(), body=post_data,
                                        headers=self.get_headers())
            response = self.__connection.getresponse()
            return response.status, response.getheaders(), response.read()
        except Exception as e:
            return None, None, None
        finally:
            self.__close_connection()

    def get_https_response_object(self):
        if self.__port is None or self.__port == '':
            self.__port = 443
        try:
            self.__port = 443
            self.__connection = httplib.HTTPSConnection(self.get_host(), self.__port, cert_file=self.__cert_file,
                                                        key_file=self.__key_file)
            self.__connection.connect()
            self.__connection.request(method=self.get_method(), url=self.get_url(), body=self.get_body(),
                                        headers=self.get_headers())
            response = self.__connection.getresponse()
            return response.status, response.getheaders(), response.read()
        except Exception as e:
            return None, None, None
        finally:
            self.__close_connection()

    def __close_connection(self):
        try:
            if self.__connection is not None:
                self.__connection.close()
        except Exception as e:
            pass