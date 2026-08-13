package com.projectwizard.model;

import java.io.File;
import java.time.LocalDateTime;

public class Project {

    private File rootDirectory;
    private String name;
    private String description;
    private boolean isGitRepository;
    private String gitBranch;
    private String gitRemote;
    private LocalDateTime lastOpened;
    private LocalDateTime created;

    public Project(File rootDirectory) {
        this.rootDirectory = rootDirectory;
        this.name = rootDirectory.getName();
        this.lastOpened = LocalDateTime.now();
        this.created = LocalDateTime.now();
    }

    public File getRootDirectory() {
        return rootDirectory;
    }

    public void setRootDirectory(File rootDirectory) {
        this.rootDirectory = rootDirectory;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public boolean isGitRepository() {
        return isGitRepository;
    }

    public void setGitRepository(boolean gitRepository) {
        isGitRepository = gitRepository;
    }

    public String getGitBranch() {
        return gitBranch;
    }

    public void setGitBranch(String gitBranch) {
        this.gitBranch = gitBranch;
    }

    public String getGitRemote() {
        return gitRemote;
    }

    public void setGitRemote(String gitRemote) {
        this.gitRemote = gitRemote;
    }

    public LocalDateTime getLastOpened() {
        return lastOpened;
    }

    public void setLastOpened(LocalDateTime lastOpened) {
        this.lastOpened = lastOpened;
    }

    public LocalDateTime getCreated() {
        return created;
    }

    public void setCreated(LocalDateTime created) {
        this.created = created;
    }

    @Override
    public String toString() {
        return "Project{" +
                "name='" + name + '\'' +
                ", path='" + rootDirectory.getAbsolutePath() + '\'' +
                '}';
    }

}
