package com.sbc.model;

import java.util.List;

public class Parts {
    public Integer ret;
    public String message;
    public String version;
    public Result results;
    private Integer statusCode;
    
    public class Result {
        public Integer ret;
        public String modelName;
        public List<Bbox> bbox;
        public String image_id;
        public String message;

    }

    public class Bbox {
        private Float score;
        private String poly;
        private List<Integer> location;
        private String type;
        public Info image_info;

        public Float getScore() {return this.score;}
        public String getPoly() {return this.poly;}
        public List<Integer> getLocation() {return this.location;}
        public String getType() {return this.type;}
    }

    public class Info {
        public List<Integer> orig_shape;
    }

    private void setCode(Integer code) {
        this.statusCode = code;
    }

    public void full(Integer code) {
        this.setCode(code);
    }

    public Integer getCode() {
        return this.statusCode;
    }

}
