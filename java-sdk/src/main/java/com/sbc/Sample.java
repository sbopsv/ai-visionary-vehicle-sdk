package com.sbc;

import com.sbc.model.Damage;

public class Sample {
    public static void main(String[] args) {
        String json;
        Damage result;
        ReadImageUtil reader = new ReadImageUtil();
        reader.SetFilename("/Users/teik87/zhengx/ai-visionary-vehicle-sdk/java-sdk/testImage.jpg");
        json = reader.Read();
        result = ApiExecutor.SBCDamageRfcn_prodHttpsSync(json);
        System.out.println(result.getCode());
    }
}
