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

class DebugUtil
{
	public static function debug($text, $object) {
		if (is_null($object)) {
			echo '['.$text.']: '.PHP_EOL;
		} else {
			$arrays = self::recursiveDump($object);
			echo '['.$text.']: '.$arrays.PHP_EOL;
		}
	}

	public static function recursiveDump($object) {
		if (is_array($object)) {
			$arrays = [];
			foreach($object as $key => $value){
				if (is_array($value)) {
					$tmp = $key.':'.self::recursiveDump($value);
				} else {
					$tmp = $key.':'.$value;
				}
				array_push($arrays, $tmp);
			}
			return '['.implode(',', $arrays).']';			
		}

		return $object;
	}

	public static function echo($text, $object) {
		echo '&'.$text.'='.$object;
	}
}