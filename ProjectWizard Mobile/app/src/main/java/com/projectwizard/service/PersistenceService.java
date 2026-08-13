package com.projectwizard.service;

import android.content.Context;
import java.io.*;
import java.util.Properties;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;

/**
 * PersistenceService - Manages application settings and state
 * Updated version ported from Desktop to Mobile
 */
public class PersistenceService {

    private final String configFile;
    private static final String LAST_PROJECT_KEY = "last.project.path";
    private static final String OPEN_FILES_KEY = "open.files";
    private static final String THEME_KEY = "current.theme";

    public PersistenceService(Context context) {
        this.configFile = new File(context.getFilesDir(), ".projectwizard.properties").getAbsolutePath();
    }

    public void saveTheme(String themeName) {
        Properties props = loadProperties();
        props.setProperty(THEME_KEY, themeName);
        saveProperties(props);
    }

    public String getTheme() {
        return loadProperties().getProperty(THEME_KEY);
    }

    public void saveLastProjectPath(String path) {
        Properties props = loadProperties();
        props.setProperty(LAST_PROJECT_KEY, path);
        saveProperties(props);
    }

    public void saveOpenFiles(List<String> filePaths) {
        Properties props = loadProperties();
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
            props.setProperty(OPEN_FILES_KEY, String.join(",", filePaths));
        } else {
            StringBuilder sb = new StringBuilder();
            for (int i = 0; i < filePaths.size(); i++) {
                sb.append(filePaths.get(i));
                if (i < filePaths.size() - 1) sb.append(",");
            }
            props.setProperty(OPEN_FILES_KEY, sb.toString());
        }
        saveProperties(props);
    }

    public String getLastProjectPath() {
        return loadProperties().getProperty(LAST_PROJECT_KEY);
    }

    public List<String> getOpenFiles() {
        String files = loadProperties().getProperty(OPEN_FILES_KEY);
        if (files == null || files.isEmpty()) return Collections.emptyList();
        return Arrays.asList(files.split(","));
    }

    private Properties loadProperties() {
        Properties props = new Properties();
        File file = new File(configFile);
        if (file.exists()) {
            try (InputStream in = new FileInputStream(file)) {
                props.load(in);
            } catch (IOException e) {
                // Ignore load errors
            }
        }
        return props;
    }

    private void saveProperties(Properties props) {
        try (OutputStream out = new FileOutputStream(configFile)) {
            props.store(out, "ProjectWizard Settings");
        } catch (IOException e) {
            android.util.Log.e("PersistenceService", "Error saving properties", e);
        }
    }
}
