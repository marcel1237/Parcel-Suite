#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_NAME="ProjectWizard"
PACKAGE="com/projectwizard"

echo "========================================="
echo " Criando $PROJECT_NAME"
echo "========================================="

rm -rf "$PROJECT_NAME"

mkdir -p "$PROJECT_NAME"
cd "$PROJECT_NAME"

mkdir -p src/main/java/$PACKAGE
mkdir -p src/main/resources
mkdir -p src/test/java

cat > pom.xml <<'EOF'
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
                             https://maven.apache.org/xsd/maven-4.0.0.xsd">

    <modelVersion>4.0.0</modelVersion>

    <groupId>com.projectwizard</groupId>
    <artifactId>ProjectWizard</artifactId>
    <version>1.0.0</version>

    <properties>

        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>

        <maven.compiler.source>17</maven.compiler.source>
        <maven.compiler.target>17</maven.compiler.target>

        <javafx.version>17.0.15</javafx.version>

    </properties>

    <dependencies>

        <dependency>
            <groupId>org.openjfx</groupId>
            <artifactId>javafx-controls</artifactId>
            <version>${javafx.version}</version>
        </dependency>

    </dependencies>

    <build>

        <plugins>

            <plugin>

                <groupId>org.apache.maven.plugins</groupId>

                <artifactId>maven-compiler-plugin</artifactId>

                <version>3.14.0</version>

                <configuration>

                    <source>17</source>
                    <target>17</target>

                </configuration>

            </plugin>

            <plugin>

                <groupId>org.openjfx</groupId>

                <artifactId>javafx-maven-plugin</artifactId>

                <version>0.0.8</version>

                <configuration>

                    <mainClass>com.projectwizard.Main</mainClass>

                </configuration>

            </plugin>

        </plugins>

    </build>

</project>
EOF

cat > src/main/java/com/projectwizard/Main.java <<'EOF'
package com.projectwizard;

import javafx.application.Application;
import javafx.scene.Scene;
import javafx.scene.control.Label;
import javafx.scene.layout.StackPane;
import javafx.stage.Stage;

public class Main extends Application {

    @Override
    public void start(Stage stage) {

        Label label = new Label("Welcome to Project Wizard!");

        Scene scene = new Scene(new StackPane(label), 900, 600);

        stage.setTitle("Project Wizard");
        stage.setScene(scene);
        stage.show();

    }

    public static void main(String[] args) {
        launch(args);
    }

}
EOF

cat > README.md <<'EOF'
# Project Wizard

Gerador de projetos Java com interface gráfica em JavaFX.

## Requisitos

- Java 17
- Maven 3.9+

## Executar

```bash
mvn clean javafx:run
```
EOF

echo
echo "========================================="
echo " Projeto criado com sucesso!"
echo "========================================="
echo
echo "Execute:"
echo
echo "cd $PROJECT_NAME"
echo "mvn clean javafx:run"
