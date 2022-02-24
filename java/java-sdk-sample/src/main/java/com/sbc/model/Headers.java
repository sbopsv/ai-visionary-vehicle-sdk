package com.sbc.model;

import java.util.List;
import java.util.Map;

public class Headers {
    public List<String> Date;
    public List<String> ContentLength;
    public List<String> Server;
    public List<String> XCaRequestId;
    public List<String> ContentType;
    public List<String> Connection;

    private void setHeaders(Map<String, List<String>> H) {
        this.Date = H.get("date");
        this.ContentLength = H.get("content-length");
        this.Server = H.get("server");
        this.XCaRequestId = H.get("x-ca-request-id");
        this.ContentType = H.get("content-type");
        this.Connection = H.get("connection");
    }

    public Headers(Map<String, List<String>> H) {
        this.setHeaders(H);
    }

}
