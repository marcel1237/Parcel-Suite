package com.projectwizard.service;

import java.io.File;
import java.nio.file.Files;
import java.nio.charset.StandardCharsets;

public class FileSystemService {
    public void saveFile(File file, String content) throws Exception {
        if (file == null) return;
        Files.writeString(file.toPath(), content, StandardCharsets.UTF_8);
    }
}
