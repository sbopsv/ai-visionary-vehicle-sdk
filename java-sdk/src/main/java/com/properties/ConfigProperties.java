package com.properties;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

public class ConfigProperties {
    public static Properties GetConfig() {
        Properties pps = new Properties();
        try {
            InputStream in = ConfigProperties.class.getClassLoader().getResourceAsStream("com/properties/config/configure.properties");
            pps.load(
                in
            );
        }catch(IOException e){
            e.printStackTrace();
        }
        return pps;
    }
}
