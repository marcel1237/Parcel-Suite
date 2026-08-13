#!/usr/bin/env bash
set -Eeuo pipefail

echo "========================================="
echo " Project Wizard - Etapa 12.1"
echo " AtlantaFX Dracula Theme"
echo "========================================="

if [ ! -f pom.xml ]; then
    echo "Execute este script dentro da pasta ProjectWizard."
    exit 1
fi

mkdir -p src/main/resources/themes

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

        <dependency>
            <groupId>io.github.mkpaz</groupId>
            <artifactId>atlantafx-base</artifactId>
            <version>2.0.1</version>
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

cat > src/main/resources/themes/projectwizard.css <<'EOF'
/*

Project Wizard

Customizações do tema.

AtlantaFX Dracula será carregado primeiro.

Este arquivo conterá apenas customizações.

*/
EOF

cat > src/main/java/com/projectwizard/App.java <<'EOF'
package com.projectwizard;

import com.projectwizard.view.MainWindow;
import io.github.mkpaz.atlantafx.theme.Dracula;
import javafx.application.Application;
import javafx.scene.Scene;
import javafx.stage.Stage;

public class App {

    public void start(Stage stage) {

        Application.setUserAgentStylesheet(
                new Dracula().getUserAgentStylesheet()
        );

        MainWindow window = new MainWindow();
        window.show(stage);

        Scene scene = stage.getScene();

        if (scene != null) {

            scene.getStylesheets().add(
                    getClass()
                            .getResource("/themes/projectwizard.css")
                            .toExternalForm()
            );

        }

    }

}
EOF

echo
echo "========================================="
echo " AtlantaFX instalado!"
echo "========================================="
echo
echo "Agora execute:"
echo
echo "mvn clean javafx:run"
