package com.sbc;

import com.sbc.model.Damage;
import com.sbc.model.Parts;

public class Sample {
    public static void main(String[] args) {
        // test the Parts API
        String json;
        Parts result;
        ReadImageUtil reader = new ReadImageUtil();
        reader.SetFilename("file");
        json = reader.Read();
        result = ApiExecutor.SBCPartDetection_prodHttpsSync(json);
        System.out.println(result.results.bbox.get(0).getLocation());

        // test the Damage API
        Damage result2;
        result2 = ApiExecutor.SBCDamageRfcn_prodHttpsSync(json);
        System.out.println(result2.results.bbox.get(0).getLocation());
    }
}
