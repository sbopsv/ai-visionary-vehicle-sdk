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

# TODO shinzato modify for all
def _get_md5(content):
    m = hashlib.md5()
    m.update(content)
    return m.digest()

def get_md5_base64_str(content):
    _md5 = base64.encodebytes(_get_md5(content)).strip()
    return _md5.decode('utf-8')
