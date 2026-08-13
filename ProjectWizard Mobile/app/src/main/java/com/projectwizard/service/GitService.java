package com.projectwizard.service;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;

/**
 * GitService - Detects and manages Git repository information
 * Ported from Desktop version
 */
public class GitService {

    private final File projectRoot;
    private boolean isGitRepository = false;
    private String remoteUrl = "";
    private String currentBranch = "unknown";

    public GitService(File projectRoot) {
        this.projectRoot = projectRoot;
        detectGitRepository();
    }

    /**
     * Detects if folder is a Git repository
     */
    private void detectGitRepository() {
        if (projectRoot == null)
            return;

        File gitDir = new File(projectRoot, ".git");
        isGitRepository = gitDir.exists() && gitDir.isDirectory();

        if (isGitRepository) {
            readGitConfig();
            readCurrentBranch();
        }
    }

    /**
     * Reads git remote URL from .git/config
     */
    private void readGitConfig() {
        try {
            File configFile = new File(projectRoot, ".git/config");
            if (configFile.exists()) {
                String content = readFileToString(configFile);
                // Simple parsing for remote url
                if (content.contains("url = ")) {
                    String[] lines = content.split("\n");
                    for (String line : lines) {
                        if (line.contains("url = ")) {
                            remoteUrl = line.replace("url = ", "").trim();
                            break;
                        }
                    }
                }
            }
        } catch (Exception e) {
            // Ignore errors
        }
    }

    /**
     * Reads current branch name
     */
    private void readCurrentBranch() {
        try {
            File headFile = new File(projectRoot, ".git/HEAD");
            if (headFile.exists()) {
                String content = readFileToString(headFile).trim();
                if (content.startsWith("ref: refs/heads/")) {
                    currentBranch = content.replace("ref: refs/heads/", "");
                }
            }
        } catch (Exception e) {
            // Ignore errors
        }
    }

    private String readFileToString(File file) throws IOException {
        StringBuilder sb = new StringBuilder();
        try (BufferedReader reader = new BufferedReader(new InputStreamReader(new FileInputStream(file), StandardCharsets.UTF_8))) {
            String line;
            while ((line = reader.readLine()) != null) {
                sb.append(line).append("\n");
            }
        }
        return sb.toString();
    }

    // Getters
    public boolean isGitRepository() {
        return isGitRepository;
    }

    public String getRemoteUrl() {
        return remoteUrl;
    }

    public String getCurrentBranch() {
        return currentBranch;
    }

    public String getRepositoryInfo() {
        if (!isGitRepository)
            return "Not a Git repository";

        StringBuilder info = new StringBuilder();
        info.append("📌 Git Repository\n");
        info.append("Branch: ").append(currentBranch).append("\n");
        if (!remoteUrl.isEmpty()) {
            info.append("Remote: ").append(remoteUrl);
        }
        return info.toString();
    }

}
