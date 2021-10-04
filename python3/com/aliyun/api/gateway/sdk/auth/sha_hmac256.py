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

import base64
import hashlib
import hmac

# TODO shinzato modify for all
def sign(message, key, utf8=True, hex=False):
    key = stringToByte(key, utf8)
    message = stringToByte(message, utf8)

    hash = hmac.new(key, message, hashlib.sha256)
    signature = encodeDigest(hash, hex)
    return signature

def stringToByte(word, utf8=True):
    if utf8 :
        return bytes(word, 'utf-8') # can use 'latin-1'
    else:
        return bytes(word, 'latin-1') # can use 'latin-1'

def encodeDigest(hash, hex=False):
    if hex:
        # to lowercase hexits
        return hash.hexdigest()
    else:
        # to base64
        return base64.b64encode(hash.digest()).decode()