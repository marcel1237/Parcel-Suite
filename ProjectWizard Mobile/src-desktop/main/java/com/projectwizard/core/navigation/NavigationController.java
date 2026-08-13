package com.projectwizard.core.navigation;

import java.io.File;

import com.projectwizard.view.WorkspacePane;
import com.projectwizard.view.about.AboutView;
import com.projectwizard.view.dashboard.DashboardView;
import com.projectwizard.view.git.GitView;
import com.projectwizard.view.github.GitHubView;
import com.projectwizard.view.newproject.NewProjectView;
import com.projectwizard.view.openproject.OpenProjectView;
import com.projectwizard.view.settings.SettingsView;
import com.projectwizard.view.templates.TemplatesView;
import com.projectwizard.workspace.ProjectWorkspace;

public final class NavigationController {

    private static final NavigationController INSTANCE = new NavigationController();
    private WorkspacePane workspace;
    private ProjectWorkspace projectWorkspace;

    private NavigationController() {
    }

    public static NavigationController getInstance() {
        return INSTANCE;
    }

    public void setWorkspace(WorkspacePane workspace) {
        this.workspace = workspace;
    }

    public void navigate(NavigationTarget target) {
        if (workspace == null) return;

        switch (target) {
            case HOME -> workspace.setContent(new DashboardView());
            case NEW_PROJECT -> workspace.setContent(new NewProjectView());
            case OPEN_PROJECT -> workspace.setContent(new OpenProjectView());
            case TEMPLATES -> workspace.setContent(new TemplatesView());
            case GIT -> workspace.setContent(new GitView());
            case GITHUB -> workspace.setContent(new GitHubView());
            case SETTINGS -> workspace.setContent(new SettingsView());
            case ABOUT -> workspace.setContent(new AboutView());
            case WORKSPACE -> {
                if (projectWorkspace == null) {
                    projectWorkspace = new ProjectWorkspace();
                }
                workspace.setContent(projectWorkspace);
            }
        }
    }

    public void navigateWithProject(NavigationTarget target, File projectRoot) {
        if (workspace == null || projectRoot == null) return;

        if (target == NavigationTarget.WORKSPACE) {
            projectWorkspace = new ProjectWorkspace();
            projectWorkspace.loadProject(projectRoot);
            workspace.setContent(projectWorkspace);
        }
    }

}
