#!/usr/bin/env bash
set -e

echo "========================================="
echo " Project Wizard - Etapa 14.2"
echo " Multi-Step New Project Wizard"
echo "========================================="

FILE="src/main/java/com/projectwizard/view/newproject/NewProjectView.java"

cp "$FILE" "$FILE.bak"

cat > "$FILE" <<'EOF'
package com.projectwizard.view.newproject;

import javafx.geometry.Insets;
import javafx.geometry.Pos;
import javafx.scene.control.Button;
import javafx.scene.control.ComboBox;
import javafx.scene.control.Label;
import javafx.scene.control.Separator;
import javafx.scene.control.TextField;
import javafx.scene.layout.BorderPane;
import javafx.scene.layout.GridPane;
import javafx.scene.layout.HBox;
import javafx.scene.layout.VBox;

public class NewProjectView extends BorderPane {

    public NewProjectView() {

        setPadding(new Insets(20));

        VBox left = new VBox(15);

        left.getChildren().addAll(
                createStep("① Project"),
                createStep("② Language"),
                createStep("③ Framework"),
                createStep("④ Dependencies"),
                createStep("⑤ Git"),
                createStep("⑥ Summary")
        );

        left.setPrefWidth(220);

        GridPane form = new GridPane();

        form.setHgap(10);
        form.setVgap(12);

        Label title = new Label("Create New Project");

        title.setStyle(
                "-fx-font-size:26px;" +
                "-fx-font-weight:bold;"
        );

        TextField projectName = new TextField();

        TextField group = new TextField("com.example");

        TextField artifact = new TextField();

        ComboBox<String> language = new ComboBox<>();

        language.getItems().addAll(
                "Java",
                "Kotlin",
                "Groovy"
        );

        language.getSelectionModel().selectFirst();

        ComboBox<String> build = new ComboBox<>();

        build.getItems().addAll(
                "Maven",
                "Gradle"
        );

        build.getSelectionModel().selectFirst();

        form.add(title,0,0,2,1);

        form.add(new Label("Project Name"),0,1);
        form.add(projectName,1,1);

        form.add(new Label("Group"),0,2);
        form.add(group,1,2);

        form.add(new Label("Artifact"),0,3);
        form.add(artifact,1,3);

        form.add(new Label("Language"),0,4);
        form.add(language,1,4);

        form.add(new Label("Build Tool"),0,5);
        form.add(build,1,5);

        HBox buttons = new HBox(10);

        Button back = new Button("◀ Back");

        Button next = new Button("Next ▶");

        Button finish = new Button("Finish");

        buttons.getChildren().addAll(
                back,
                next,
                finish
        );

        buttons.setAlignment(Pos.CENTER_RIGHT);

        VBox center = new VBox(20);

        center.getChildren().addAll(

                form,

                new Separator(),

                buttons

        );

        setLeft(left);

        setCenter(center);

    }

    private Label createStep(String text){

        Label label = new Label(text);

        label.setMaxWidth(Double.MAX_VALUE);

        label.setStyle(
                "-fx-font-size:15px;" +
                "-fx-padding:8;"
        );

        return label;

    }

}
EOF

echo
echo "========================================="
echo " Etapa 14.2 concluída."
echo "========================================="
echo
echo "Execute:"
echo
echo "mvn clean javafx:run"
echo
echo "Abra:"
echo
echo "New Project"