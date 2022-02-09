package com.sbc.model;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class Damage {
    public String message;
    public String version;
    public Result results;
    public String ret;
    private Integer statusCode;

    public class Result{
        public String image_id;
        public String modelName;
        public List<Bbox> bbox;
    }

    public class Bbox {
        private Float score;
        private String type;
        private List<Integer> location;
        private String scores;
        
        public Float getScore(){
            return this.score;
        }

        public String getType(){
            return this.type;
        }

        public List<Integer> getLocation(){
            return this.location;
        }

        public List<String> getScores(){
            return new ArrayList<String>(Arrays.asList(this.scores.split(",")));
        }
    }
    
    private void setCode(Integer code){
        this.statusCode = code;
    }

    public void full(Integer code){
        this.setCode(code);
    }

    public Integer getCode(){return this.statusCode;}
}
