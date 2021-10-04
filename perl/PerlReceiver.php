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

DebugUtil::debug('----------------------------------', NULL);

#######################################################################################
# receive config and parameter
$host       = $argv[1];
$path       = $argv[2];

$appKey     = $argv[3];
$appSecret  = $argv[4];

$file_name  = $argv[5];
$file_url   = $argv[6];

DebugUtil::debug('HOST', $host);
DebugUtil::debug('PATH', $path);

DebugUtil::debug('APP_KEY', $appKey);
DebugUtil::debug('APP_SECRET', $appSecret);

DebugUtil::debug('FILE_NAME', $file_name);
DebugUtil::debug('FILE_URL', $file_url);

#######################################################################################
# for Vehicle APIs

if ($file_name !== '@@') {
    // execute with file_name
    $file_name = '../'.$file_name;
    $response= ApiExecutor::doPostStream($host, $path, $appKey, $appSecret, $file_name, NULL);
} else {
    // execute with file_url
    $response= ApiExecutor::doPostStream($host, $path, $appKey, $appSecret, NULL, $file_url);
}

// pass API Response to perl
DebugUtil::echo('CONTENT', $response->getContent());
DebugUtil::echo('CONTENT_TYPE', $response->getContentType());

DebugUtil::echo('HEADER', $response->getHeader());
DebugUtil::echo('REQUEST_ID', $response->getRequestId());
DebugUtil::echo('STATUS_CODE', $response->getHttpStatusCode());

DebugUtil::echo('ERROR_MESSAGES', $response->getErrorMessage());

DebugUtil::echo('BODY', $response->getBody());

?>