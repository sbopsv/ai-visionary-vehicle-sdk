<?php
/* Copyright 2021-present SB Cloud Corp.
*
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

include_once 'Util/Autoloader.php';

#######################################################################################
# read config file
Config::setConfigDirectory('config');

# for api
$host = Config::get('host');
$parts_path = Config::get('parts_path');
$damage_path = Config::get('damage_path');

# for signature
$appKey = Config::get('appKey');
$appSecret = Config::get('appSecret');

# for parameter
$file_name = Config::get('file_name');
$file_url = Config::get('file_url');

#######################################################################################
# for Vehicle Parts API
// execute with file_name
$response= ApiExecutor::doPostStream($host, $parts_path, $appKey, $appSecret, $file_name, NULL);
ApiExecutor::dumpResponse($response, 'hood', 0.4);

// DebugUtil::debug('----------------------------------', NULL);

// execute with file_url
$response= ApiExecutor::doPostStream($host, $parts_path, $appKey, $appSecret, NULL, $file_url);
ApiExecutor::dumpResponse($response, 'front_bumper', 0.4);

#######################################################################################
# for Vehicle Damage API
// execute with file_name
$response= ApiExecutor::doPostStream($host, $damage_path, $appKey, $appSecret, $file_name, NULL);
ApiExecutor::dumpResponse($response, '14', 0.4);

// DebugUtil::debug('----------------------------------', NULL);

// execute with file_url
$response= ApiExecutor::doPostStream($host, $damage_path, $appKey, $appSecret, NULL, $file_url);
ApiExecutor::dumpResponse($response, '6', 0.4);

#######################################################################################