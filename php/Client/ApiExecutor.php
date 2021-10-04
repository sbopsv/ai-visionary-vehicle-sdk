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

/**
 * Request example
 * for instance, the complete url is like this, http://api.aaaa.com/createobject?key1=value&key2=value2
 * $host:	http://api.aaaa.com			|
 * $path:	/createobject				| The part from the domain(host) name to the query
 * $query: 	key1=value&key2=value2		| The query part
*/
class APIExecutor
{
	/**
	 * method=POST 且是非表单提交，请求示例
	 * method=POST and non-form submission, request example
	 * method=POST および非フォーム送信、リクエスト例
	*/
	public static function doPostStream($host, $path, $appKey, $appSecret, $file_name, $file_url) {
		$request = new HttpRequest($host, $path, HttpMethod::POST, $appKey, $appSecret);

		// Stream的内容
		// Content of Stream
		$bytes = array();
        if (!is_null($file_name)) {
            // case1) base64 raw data
            // encode to base64
            $file_path = __DIR__ . '/../' . $file_name;
            $data = base64_encode(file_get_contents($file_path));
            $input_array = ['image'=>$data];
        } else {
		    // case2) imageURL on OSS bucket
		    $input_array = ['url'=>$file_url];
        }

		//配列をJSON形式に変換
		$bodyContent =  json_encode($input_array);
		DebugUtil::debug('BODY CONTENT', $bodyContent);

		// 设定Content-Type，根据服务器端接受的值来设置
		// Set Content-Type, depending on the value accepted on the server side
		$request->setHeader(HttpHeader::HTTP_HEADER_CONTENT_TYPE, ContentType::CONTENT_TYPE_STREAM);

		// 设定Accept，根据服务器端接受的值来设置
		// Set Accept, depending on the value accepted on the server side
		$request->setHeader(HttpHeader::HTTP_HEADER_ACCEPT, ContentType::CONTENT_TYPE_JSON);

		// 注意：业务body部分，不能设置key值，只能有value
		// Note: the body part, can not set the key value, can only have value
		foreach($bytes as $byte) {
            $bodyContent .= chr($byte);
        }
		if (0 < strlen($bodyContent)) {
			$request->setHeader(HttpHeader::HTTP_HEADER_CONTENT_MD5, base64_encode(md5($bodyContent, true)));
			$request->setBodyStream($bodyContent);
		}

		// 指定参与签名的header
		// Specify the header of the participating signatures
		$request->setSignHeader(SystemHeader::X_CA_TIMESTAMP);

		$response = HttpClient::execute($request);
		
		return $response;
	}

	public static function dumpResponse($response, $type, $score) {
		$converter = new ResponseConverter($response);

		DebugUtil::debug('----------------------------------', NULL);
		$converter->getContent();
		$converter->getContentType();

		DebugUtil::debug('----------------------------------', NULL);
		$converter->getHeader();
		$converter->getRequestId();
		$converter->getHttpStatusCode();

		DebugUtil::debug('----------------------------------', NULL);
		$converter->getErrorMessage();

		DebugUtil::debug('----------------------------------', NULL);
		$bboxIterator = $converter->getBBoxIterator(NULL, 0.0);
		foreach ($bboxIterator as $bbox_) {
			DebugUtil::debug('BOX', $bbox_->getInfo());
		}

		DebugUtil::debug('----------------------------------', NULL);
		$bboxIterator = $converter->getBBoxIterator($type, $score);
		foreach ($bboxIterator as $bbox_) {
			DebugUtil::debug('BOX', $bbox_->getInfo());
		}

		DebugUtil::debug('DONE', NULL);
	}
}