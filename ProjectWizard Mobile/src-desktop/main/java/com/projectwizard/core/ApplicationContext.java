package com.projectwizard.core;

import com.projectwizard.service.*;

public class ApplicationContext {
    private static ApplicationContext instance;
    private final ProjectService projectService = new ProjectService();
    private final FileSystemService fileSystemService = new FileSystemService();
    private final DialogService dialogService = new DialogService();

    private ApplicationContext() {}

    public static synchronized ApplicationContext getInstance() {
        if (instance == null) instance = new ApplicationContext();
        return instance;
    }

    public String getApplicationName() { return "Project Wizard"; }
    public String getVersion() { return "1.0.0"; }
    
    public ProjectService getProjectService() { return projectService; }
    public FileSystemService getFileSystemService() { return fileSystemService; }
    public DialogService getDialogService() { return dialogService; }
}
