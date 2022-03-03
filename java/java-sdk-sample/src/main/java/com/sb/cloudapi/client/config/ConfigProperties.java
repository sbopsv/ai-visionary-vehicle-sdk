package com.sb.cloudapi.client.config;

import java.io.IOException;
import java.io.InputStream;

import java.io.File;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.PropertyResourceBundle;
import java.util.ResourceBundle;

public class ConfigProperties {

    private static ResourceBundle cfg = null;
    private static ConfigProperties instance = null;

    private ConfigProperties() {
        try {
            InputStream is = Files.newInputStream(getExternalResouceFile("config.properties"));
            cfg = new PropertyResourceBundle(is);
        } catch(IOException e) {
            System.err.println(e.getMessage());
            System.err.println(e.toString());
        }
    }

    private Path getExternalResouceFile(String resouce) {
        Path externalWorksDir = getExternalWorksDirectory();
        Path externalResourceFile = Paths.get(externalWorksDir + "/" + resouce);
        return externalResourceFile;
	}

    public static Path getExternalWorksDirectory() {
        File thisfile = new File(ConfigProperties.class.getClassLoader().getResource("").getPath());
        String parentPath = thisfile.getParentFile().getPath();
        Path externalWorksDir = Paths.get(parentPath + "/works");
        return externalWorksDir;
	}

    private static ConfigProperties getInstance() {
        if (instance == null) {
            instance = new ConfigProperties();
        }
        return instance;
    }

    public static String getProperty(String key) {
        if (cfg == null) {
            getInstance();
        }
        return cfg.getString(key);
    }
}
