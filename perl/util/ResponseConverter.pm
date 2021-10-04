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

package util::ResponseConverter;

use strict;
use warnings;
use utf8;
use Data::Dumper;
use Encode;
use JSON;

use util::DebugUtil;

sub new {
    my($class, $response) = @_;     
    my($self) = {};                 
    bless($self, $class);           

    &convert($self, $response);
    $self->{response} = $response;  

    return $self;                   
}

sub convert {
    my($self, $response) = @_;

    # util::DebugUtil::debug('=======================', undef);

    my @splitted = split('&', $response);

    $self->{content} = &slice($splitted[1]);
    # util::DebugUtil::debug('CONTENT', $self->{content});

    $self->{content_type} = &slice($splitted[2]);
    # util::DebugUtil::debug('CONTENT_TYPE', $self->{content_type});

    $self->{header} = &slice($splitted[3]);
    # util::DebugUtil::debug('HEADER', $self->{header});

    $self->{request_id} = &slice($splitted[4]);
	# util::DebugUtil::debug('REQUEST_ID', $self->{request_id});

    $self->{status_code} = &slice($splitted[5]);
    # util::DebugUtil::debug('STATUS_CODE', $self->{status_code});

    $self->{error_messages} = &slice($splitted[6]);
    # util::DebugUtil::debug('ERROR_MESSAGES', $self->{error_messages});

    $self->{body} = &slice($splitted[7]);
    # util::DebugUtil::debug('BODY', $self->{body});

    my $jsonBody = decode_json(encode('utf-8', $self->{body}));
    $self->{json_body} = $jsonBody;

    if (defined $self->{error_messages}) {
        return
    }

    my $bbox = $jsonBody->{results}->{bbox};
    $self->{bbox} = $bbox;
}

sub slice {
    my($splitted) = @_;
    my @sliced = split('=', $splitted);
    return $sliced[1];
}

sub getContent {
    my($self) = @_;
    return $self->{content};
}

sub getContentType {
    my($self) = @_;
    return $self->{content_type};
}

sub getHeader {
    my($self) = @_;
    return $self->{header};
}

sub getRequestId {
    my($self) = @_;
    return $self->{request_id};
}

sub getHttpStatusCode {
    my($self) = @_;
    return $self->{status_code};
}

sub getErrorMessage {
    my($self) = @_;
    return $self->{error_messages};
}

sub getBody {
    my($self) = @_;
    return $self->{body};
}

sub getBBox {
    my($self) = @_;
    return $self->{bbox};
}

sub getBBoxIterator {
    my($self, $type_threshold, $score_threshold) = @_;

    my $bbox = $self->{bbox};
    my $bbox_iterator = util::BBoxIterator::filter($bbox, $type_threshold, $score_threshold);

    $self->{bboxIterator} = $bbox_iterator;
    return $self->{bboxIterator};
}
1;

#######################################################################################
package util::BBox;

sub new {
    my($class, $value) = @_;        
    my($self) = {};                 
    bless($self, $class);           

    $self->{type} = $value->{type};            
    $self->{score} = $value->{score}; 
    $self->{location} = $value->{location}; 

    return $self;                   
}

sub getInfo {
    my($self) = @_;

    return $self->{type} . ' : ' . $self->{score} . ' locaton:' . join(',', @{$self->{location}})
}

sub getType {
    my($self) = @_;
    return $self->{type};
}

sub getScore {
    my($self) = @_;
    return $self->{score};
}

sub getLocation {
    my($self) = @_;
    return $self->{location};
}
1;

#######################################################################################
package util::BBoxIterator;

use Iterator::Simple qw(:all);

sub bboxes {
    my $array = shift;
    my $max = scalar(@$array);
    my $i = -1;

    iterator {
        return if $i >= $max -1;

        $i++;
        return util::BBox->new(@$array[$i]);
    }
}

sub filter {
    my $array = shift;
    my $type = shift;
    my $score = shift;
    my $iterator = &bboxes($array);

    my $filterd = ifilter $iterator, sub {
        return if ($score > $_->getScore * 1.0);            # skip
        return if (defined $type && $type ne $_->getType);  # skip
        return $_ ;                                         # pass
    };

    return $filterd;
}
1;