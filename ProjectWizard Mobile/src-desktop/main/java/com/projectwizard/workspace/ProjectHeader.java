package com.projectwizard.workspace;

import javafx.geometry.Insets;
import javafx.geometry.Pos;
import javafx.scene.control.Label;
import javafx.scene.layout.HBox;
import javafx.scene.layout.Priority;
import javafx.scene.layout.VBox;
import javafx.scene.text.Font;
import javafx.scene.text.FontWeight;

import com.projectwizard.model.Project;
import com.projectwizard.service.git.GitService;

public class ProjectHeader extends VBox {

    private Project project;
    private GitService gitService;

    public ProjectHeader(Project project) {
        this.project = project;
        this.gitService = new GitService(project.getRootDirectory());

        setStyle("-fx-background-color: #f5f5f5; -fx-border-color: #ddd; "
                + "-fx-border-width: 0 0 1 0;");
        setPadding(new Insets(15, 20, 15, 20));
        setSpacing(8);

        getChildren().addAll(createTitleRow(), createInfoRow());
    }

    private HBox createTitleRow() {
        HBox hbox = new HBox(15);
        hbox.setAlignment(Pos.CENTER_LEFT);

        Label titleLabel = new Label("📁 " + project.getName());
        titleLabel.setFont(Font.font("System", FontWeight.BOLD, 18));

        if (gitService.isGitRepository()) {
            Label gitBadge = new Label("🌿 Git");
            gitBadge.setStyle("-fx-background-color: #e8f5e9; "
                    + "-fx-text-fill: #2e7d32; -fx-padding: 3 8; "
                    + "-fx-border-radius: 3; -fx-background-radius: 3;");
            hbox.getChildren().addAll(titleLabel, gitBadge);
        } else {
            hbox.getChildren().add(titleLabel);
        }

        HBox spacer = new HBox();
        HBox.setHgrow(spacer, Priority.ALWAYS);
        hbox.getChildren().add(spacer);

        return hbox;
    }

    private HBox createInfoRow() {
        HBox hbox = new HBox(20);
        hbox.setAlignment(Pos.CENTER_LEFT);

        Label pathLabel = new Label("📍 " + project.getRootDirectory().getAbsolutePath());
        pathLabel.setStyle("-fx-text-fill: #666;");
        hbox.getChildren().add(pathLabel);

        if (gitService.isGitRepository()) {
            String branchInfo = "🔀 Branch: " + gitService.getCurrentBranch();
            Label branchLabel = new Label(branchInfo);
            branchLabel.setStyle("-fx-text-fill: #1976d2;");
            hbox.getChildren().add(branchLabel);

            if (!gitService.getRemoteUrl().isEmpty()) {
                Label remoteLabel = new Label("🔗 " + gitService.getRemoteUrl());
                remoteLabel.setStyle("-fx-text-fill: #666; -fx-font-size: 11;");
                hbox.getChildren().add(remoteLabel);
            }
        }

        return hbox;
    }

}
