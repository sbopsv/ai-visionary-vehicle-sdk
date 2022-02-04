package com.sbc;


public class Sample {
    public static void main(String[] args) {
        String json;
        ReadImageUtil reader = new ReadImageUtil();
        reader.SetFilename("file");
        json = reader.Read();
        ApiExecutor.SBCDamageRfcn_prodHttps(json);
    }
}
