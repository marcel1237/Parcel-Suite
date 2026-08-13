#!/usr/bin/env bash
set -Eeuo pipefail

echo "========================================="
echo " Project Wizard - Etapa 11"
echo " New Project View"
echo "========================================="

if [ ! -f pom.xml ]; then
    echo "Execute este script dentro da pasta ProjectWizard."
    exit 1
fi

cat > src/main/java/com/projectwizard/view/WorkspacePane.java <<'EOF'
package com.projectwizard.view;

import javafx.geometry.Insets;
import javafx.scene.layout.BorderPane;

public class WorkspacePane extends BorderPane {

    public WorkspacePane() {

        setPadding(new Insets(20));

        setCenter(new NewProjectPane());

    }

}
EOF

cat > src/main/java/com/projectwizard/view/NewProjectPane.java <<'EOF'
package com.projectwizard.view;

import javafx.geometry.Insets;
import javafx.geometry.Pos;
import javafx.scene.control.Button;
import javafx.scene.control.Label;
import javafx.scene.control.RadioButton;
import javafx.scene.control.TextField;
import javafx.scene.control.ToggleGroup;
import javafx.scene.layout.GridPane;
import javafx.scene.layout.HBox;
import javafx.scene.layout.Priority;
import javafx.scene.layout.VBox;

public class NewProjectPane extends VBox {

    public NewProjectPane() {

        setSpacing(20);
        setPadding(new Insets(20));

        Label title = new Label("New Project");
        title.setStyle("-fx-font-size:24px; -fx-font-weight:bold;");

        GridPane grid = new GridPane();

        grid.setHgap(10);
        grid.setVgap(15);

        Label projectNameLabel = new Label("Project Name");

        TextField projectName = new TextField();

        Label groupIdLabel = new Label("Group Id");

        TextField groupId = new TextField("com.example");

        Label artifactIdLabel = new Label("Artifact Id");

        TextField artifactId = new TextField("my-project");

        Label buildToolLabel = new Label("Build Tool");

        ToggleGroup buildGroup = new ToggleGroup();

        RadioButton maven = new RadioButton("Maven");
        maven.setToggleGroup(buildGroup);
        maven.setSelected(true);

        RadioButton gradle = new RadioButton("Gradle");
        gradle.setToggleGroup(buildGroup);

        HBox buildTools = new HBox(20, maven, gradle);

        Button createButton = new Button("Create Project");
        createButton.setPrefWidth(180);

        HBox buttonBox = new HBox(createButton);
        buttonBox.setAlignment(Pos.CENTER);

        grid.add(projectNameLabel,0,0);
        grid.add(projectName,0,1);

        grid.add(groupIdLabel,0,2);
        grid.add(groupId,0,3);

        grid.add(artifactIdLabel,0,4);
        grid.add(artifactId,0,5);

        grid.add(buildToolLabel,0,6);
        grid.add(buildTools,0,7);

        projectName.setMaxWidth(Double.MAX_VALUE);
        groupId.setMaxWidth(Double.MAX_VALUE);
        artifactId.setMaxWidth(Double.MAX_VALUE);

        GridPane.setHgrow(projectName, Priority.ALWAYS);
        GridPane.setHgrow(groupId, Priority.ALWAYS);
        GridPane.setHgrow(artifactId, Priority.ALWAYS);

        getChildren().addAll(
                title,
                grid,
                buttonBox
        );

    }

}
EOF

echo
echo "========================================="
echo " Etapa 11 concluída!"
echo "========================================="
echo
echo "Execute:"
echo
echo "mvn clean javafx:run"
