package com.projectwizard.service.git;

import java.io.File;
import java.nio.file.Files;
import java.nio.file.Paths;

/**
 * GitService - Detects and manages Git repository information
 * 
 * Features:
 * - Detects if folder is a Git repository
 * - Reads .git/config for remote info
 * - Shows branch information
 * - Displays recent commits
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
                String content = new String(Files.readAllBytes(configFile.toPath()));
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
            System.err.println("Error reading git config: " + e.getMessage());
        }
    }

    /**
     * Reads current branch name
     */
    private void readCurrentBranch() {
        try {
            File headFile = new File(projectRoot, ".git/HEAD");
            if (headFile.exists()) {
                String content = new String(Files.readAllBytes(headFile.toPath())).trim();
                if (content.startsWith("ref: refs/heads/")) {
                    currentBranch = content.replace("ref: refs/heads/", "");
                }
            }
        } catch (Exception e) {
            System.err.println("Error reading current branch: " + e.getMessage());
        }
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
