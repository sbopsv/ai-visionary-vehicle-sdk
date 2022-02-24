package com.sbc;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;

import org.apache.commons.codec.binary.Base64;

public class ReadImageUtil {
    public String filename;
    public String url;

    ReadImageUtil(){
        filename = null;
        url = null;
    }

    public void SetFilename(String filename){
        this.filename = filename;
    }

    public void SetUrl(String url) {
        this.url = url;
    }

    public String Read () {
        if(this.filename != null && this.url == null){
            return readImageBase64(this.filename);
        }
        else if(this.filename == null && this.url != null){
            return readImageUrl(this.url);
        }
        else{

            return "error";
        }
    }

    private String readImageBase64(String filename){
        byte[] fileStream = null;
        try{
            File file = new File(filename);
            fileStream = Files.readAllBytes(file.toPath());
        }catch(IOException e) {
            e.printStackTrace();
        }

        return "{\"image\":\"" + Base64.encodeBase64String(fileStream) + "\"}";
    }

    private String readImageUrl(String url){
        return "{\"url\":\"" + url + "\"}";
    }

}