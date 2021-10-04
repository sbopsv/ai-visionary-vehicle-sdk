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

class ResponseConverter
{
	private $_response;
	
	private $_content;
	private $_contentType;
	private $_header;
	private $_httpStatusCode;
	private $_requestId;

	private $_body;
	private $_jsonBody;
	private $_bbox;
	private $_bboxIterator;
	private $_errorMessages;

	function  __construct($response)
	{
		$this->_response = $response;

		$this->_content = $response->getContent();
		$this->_contentType = $response->getContentType();
		$this->_header = $response->getHeader();
		$this->_httpStatusCode = $response->getHttpStatusCode();
		$this->_requestId = $response->getRequestId();

		self::setBody();
	}

	public function getContent()
	{
		DebugUtil::debug('CONTENT', $this->_content);
		return $this->_content;
	}

	public function getContentType()
	{
		DebugUtil::debug('CONTENT_TYPE', $this->_contentType);
		return $this->_contentType;
	}
	
	public function getHeader()
	{
		DebugUtil::debug('HEADER', $this->_header);
		return $this->_header;
	}

	public function getRequestId()
	{
		DebugUtil::debug('REQUEST_ID', $this->_requestId);
		return $this->_requestId;
	}

	public function getHttpStatusCode()
	{
		DebugUtil::debug('STATUS_CODE', $this->_httpStatusCode);
		return $this->_httpStatusCode;
	}

	private function setBody()
	{
		$this->_body = $this->_response->getBody();

		$jsonBody = json_decode($this->_body,true);
		$this->_jsonBody = $jsonBody;

		$errorMessages = [];
		if ($this->_httpStatusCode > 200) {
			$error1 = $this->_response->getErrorMessage();
			if (!is_null($error1)) {
				array_push($errorMessages, $error1);
			}

			$message = $jsonBody['message'];
			if (!is_null($message)) {
				array_push($errorMessages, $message);
			}

			$error2 = $jsonBody['errorMessage'];
			if (!is_null($error2)) {
				array_push($errorMessages, $error2);
			}

			$this->_errorMessages = $errorMessages;

			return;
		}

		$this->_errorMessages = $errorMessages;

		$this->_bbox = $jsonBody['results']['bbox'];
	}

	public function getBody()
	{
		DebugUtil::debug('BODY', $this->_body);
		return $this->_body;
	}

	public function getBBoxIterator($type_threshold, $score_threshold) {
		$bbox = new BBoxIteratorAggregate($type_threshold, $score_threshold);

		foreach($this->_bbox as $key => $value){
			$bbox->add(new BBox($value));
		}
		
		$this->_bboxIterator = $bbox->getIterator();
		return $this->_bboxIterator;
	}


	public function getErrorMessage()
	{
		DebugUtil::debug('ERROR_MESSAGES', $this->_errorMessages);
		return $this->_errorMessages;
	}
			
	public function getSuccess()
	{
		if(200 <= $this->_httpStatusCode && 300 > $this->_httpStatusCode)
		{
			return true;
		}
		return false;
	}
}

class BBox
{
	private $_type;
    private $_score;
	private $_location;

	public function __construct($value)
    {	
		$this->_type  		= $value['type'];
		$this->_score   	= $value['score'];
		$this->_location	= $value['location'];
    }
 
    public function getInfo()
    {
		return $this->_type . ' : ' . $this->_score . ' location:' . DebugUtil::recursiveDump($this->_location);
    }
 
    public function getType()
    {
        return $this->_type;
    }

	public function getScore()
    {
        return $this->_score;
    }

	public function getLocation()
    {
        return $this->_location;
    }
}

class BBoxIteratorAggregate implements IteratorAggregate
{
    private $_bbox;
	private $_type_threshold;
	private $_score_threshold;
 
    public function __construct($type_threshold, $score_threshold)
    {
        $this->_bbox = new ArrayObject();
		$this->_type_threshold = $type_threshold;
		$this->_score_threshold = $score_threshold;
    }
 
    public function add(BBox $bbox)
    {
        $this->_bbox[] = $bbox;
    }
 
    public function getIterator()
    {
        return new BBoxFilterIterator($this->_bbox->getIterator(), $this->_type_threshold, $this->_score_threshold);
    }
}

class BBoxFilterIterator extends FilterIterator
{
	private $_type_threshold;
	private $_score_threshold;

    public function __construct($iterator, $type_threshold, $score_threshold)
    {
        parent::__construct($iterator);
		$this->_type_threshold = $type_threshold;
		$this->_score_threshold = $score_threshold;
    }
 
    public function accept()
    {
        $bbox = $this->current();

		if (is_null($this->_type_threshold)) {
			return ($bbox->getScore() >= $this->_score_threshold) ? true : false;
		}

        return ($bbox->getType() === $this->_type_threshold) ? (($bbox->getScore() >= $this->_score_threshold) ? true : false): false;
    }
}