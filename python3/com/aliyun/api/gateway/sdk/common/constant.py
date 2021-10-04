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

SYSTEM_HEADERS = (
    X_CA_SIGNATURE, X_CA_SIGNATURE_HEADERS, X_CA_TIMESTAMP, X_CA_NONCE, X_CA_KEY,
    X_CA_REQUEST_ID, X_CA_ERROR_CODE, X_CA_ERROR_MESSAGE
) = (
    'X-Ca-Signature', 'X-Ca-Signature-Headers', 'X-Ca-Timestamp', 'X-Ca-Nonce', 'X-Ca-Key',
    'X-Ca-Request-Id', 'X-Ca-Error-Code', 'X-Ca-Error-Message'
)

HTTP_HEADERS = (
    HTTP_HEADER_ACCEPT, HTTP_HEADER_CONTENT_MD5,
    HTTP_HEADER_CONTENT_TYPE, HTTP_HEADER_USER_AGENT, HTTP_HEADER_DATE
) = (
    'Accept', 'Content-MD5',
    'Content-Type', 'User-Agent', 'Date'
)

HTTP_PROTOCOL = (
    HTTP, HTTPS
) = (
    'http', 'https'
)

HTTP_METHOD = (
    GET, POST, PUT, DELETE, HEADER
) = (
    'GET', 'POST', 'PUT', 'DELETE', 'HEADER'
)

CONTENT_TYPE = (
    CONTENT_TYPE_FORM, CONTENT_TYPE_STREAM,
    CONTENT_TYPE_JSON, CONTENT_TYPE_XML, CONTENT_TYPE_TEXT
) = (
    'application/x-www-form-urlencoded', 'application/octet-stream',
    'application/json', 'application/xml', 'application/text'
)

BODY_TYPE = (
    FORM, STREAM
) = (
    'FORM', 'STREAM'
)



