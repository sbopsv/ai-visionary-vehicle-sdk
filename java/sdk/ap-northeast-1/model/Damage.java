package com.sb.cloudapi.client.model;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Map;

public class Damage {
    public String message;
    public String version;
    public Result results;
    public String ret;
    public Headers headers;
    private Integer statusCode;
    private String Message;


    public class Result {
        public String image_id;
        public String modelName;
        public List<Bbox> bbox;
    }

    public class Bbox {
        private Float score;
        private String type;
        private List<Integer> location;
        private String scores;
        
        public Float getScore() {
            return this.score;
        }

        public String getType() {
            return this.type;
        }

        public List<Integer> getLocation() {
            return this.location;
        }

        public List<String> getScores() {
            return new ArrayList<String>(Arrays.asList(this.scores.split(",")));
        }
    }

    
    private void setCode(Integer code) {
        this.statusCode = code;
    }

    private void setMessage(String m) {
        this.Message = m;
    }
    

    public void full(Integer code, String m, Map<String, List<String>> H) {
        this.setCode(code);
        this.setMessage(m);
        this.headers = new Headers(H);
    }

    public Integer getCode() {return this.statusCode;}
    public String getMessage() {return this.Message;}
}
