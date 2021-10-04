#!/usr/bin/perl
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
# See the License for the specific language governing permissions and
# limitations under the License.

use strict;
use warnings;
use utf8;
use Config::Tiny;

use util::ResponseConverter;
use util::DebugUtil;

#######################################################################################
# read config file
my $cfg = Config::Tiny->read( 'config.ini' );
 
# for api
my $host        = $cfg->{'BASE'}->{'host'};
my $parts_path  = $cfg->{'PARTS'}->{'path'};
my $damage_path = $cfg->{'DAMAGE'}->{'path'};
 
# for signature
my $appKey      = $cfg->{'CRED'}->{'appKey'};
my $appSecret   = $cfg->{'CRED'}->{'appSecret'};

# for parameter
my $file_name   = $cfg->{'PARAM'}->{'imgFile'};
my $file_url    = $cfg->{'PARAM'}->{'imgURL'};

util::DebugUtil::debug('----------------------------------', undef);
util::DebugUtil::debug('HOST', $host);
util::DebugUtil::debug('PARTS_PATH', $parts_path);
util::DebugUtil::debug('DAMAGE_PATH', $damage_path);

util::DebugUtil::debug('APP_KEY', $appKey);
util::DebugUtil::debug('APP_SECRET', $appSecret);

util::DebugUtil::debug('FILE_NAME', $file_name);
util::DebugUtil::debug('FILE_URL', $file_url);

my $file;
my $url;

my $php_receiver = '"./php/PerlReceiver.php"';
util::DebugUtil::debug('EXEC', $php_receiver);

#######################################################################################
# for Vehicle Parts API
# execute with file_name
$file = $file_name;
$url  = '@@';
my $response = `/usr/bin/php -f $php_receiver $host $parts_path $appKey $appSecret $file $url`;
util::DebugUtil::dump($response, undef, 0.0);
util::DebugUtil::dump($response, 'hood', 0.4);

# util::DebugUtil::debug('----------------------------------', undef);

# execute with file_url
$file = '@@';
$url  = $file_url;
$response = `/usr/bin/php -f $php_receiver $host $parts_path $appKey $appSecret $file $url`;
util::DebugUtil::dump($response, undef, 0.0);
util::DebugUtil::dump($response, 'grille', 0.4);

#######################################################################################
# for Vehicle Damage API
# execute with file_name
$file = $file_name;
$url  = '@@';
$response = `/usr/bin/php -f $php_receiver $host $damage_path $appKey $appSecret $file $url`;
util::DebugUtil::dump($response, undef, 0.0);
util::DebugUtil::dump($response, '14', 0.4);

# util::DebugUtil::debug('----------------------------------', undef);

# execute with file_url
$file = '@@';
$url  = $file_url;
$response = `/usr/bin/php -f $php_receiver $host $damage_path $appKey $appSecret $file $url`;
util::DebugUtil::dump($response, undef, 0.0);
util::DebugUtil::dump($response, '6', 0.4);

#######################################################################################