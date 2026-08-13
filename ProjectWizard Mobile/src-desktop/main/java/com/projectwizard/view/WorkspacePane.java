package com.projectwizard.view;

import com.projectwizard.core.navigation.NavigationController;

import com.projectwizard.view.dashboard.DashboardView;
import javafx.scene.Node;
import javafx.scene.layout.BorderPane;

public class WorkspacePane extends BorderPane {

    private static WorkspacePane instance;

    public WorkspacePane() {

        instance = this;

        NavigationController.getInstance().setWorkspace(this);

        showDashboard();

    }

    public static WorkspacePane getInstance() {

        return instance;

    }

    public void setContent(Node node) {

        setCenter(node);

    }

    public void showDashboard() {

        setContent(new DashboardView());

    }

}
