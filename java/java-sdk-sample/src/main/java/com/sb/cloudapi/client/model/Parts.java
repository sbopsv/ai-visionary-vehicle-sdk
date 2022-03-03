package com.sb.cloudapi.client.model;

import java.util.List;
import java.util.Map;

public class Parts {
    public Integer ret;
    public String message;
    public String version;
    public Result results;
    public Headers headers;
    private Integer statusCode;
    private String Message;

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

    private void setMessage(String m) {
        this.Message = m;
    }

    public void full(Integer code, String m, Map<String, List<String>> H) {
        this.setCode(code);
        this.setMessage(m);
        this.headers = new Headers(H);
    }

    public Integer getCode() {
        return this.statusCode;
    }

    public String getMessage() {
        return this.Message;
    }

}
