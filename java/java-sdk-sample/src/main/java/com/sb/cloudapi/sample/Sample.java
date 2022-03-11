package com.sb.cloudapi.sample;

import com.sb.cloudapi.client.ApiExecutorDAMO_Vehicle_prod;
import com.sb.cloudapi.client.config.ConfigProperties;
import com.sb.cloudapi.client.model.Damage;
import com.sb.cloudapi.client.model.Parts;
import com.sb.cloudapi.client.util.ReadImageUtil;

import java.nio.file.Path;

public class Sample {

    public static void main(String[] args) {
        // // test the Parts API
        String json;
        Parts result;
        ReadImageUtil reader = new ReadImageUtil();
        Path externalWorksDir = ConfigProperties.getExternalWorksDirectory();
        reader.SetFilename(externalWorksDir + "/img5.jpg");
        json = reader.Read();
        result = ApiExecutorDAMO_Vehicle_prod.SBCPartDetection_prodHttpsSync(json);
        System.out.println(result.results.bbox.get(0).getLocation());

        // test the Damage API
        Damage result2;
        result2 = ApiExecutorDAMO_Vehicle_prod.SBCDamageRfcn_prodHttpsSync(json);
        System.out.println(result2.results.bbox.get(0).getLocation());
    }
}