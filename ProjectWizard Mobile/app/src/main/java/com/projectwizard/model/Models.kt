package com.projectwizard.model

import android.content.Context
import java.io.File

data class ProjectTemplate(
    val id: String,
    val icon: String,
    val name: String,
    val description: String,
    val category: String,
    val techStack: String,
    val sampleFiles: Map<String, String>
)

data class GeneratedProject(
    val name: String,
    val path: String,
    val language: String,
    val buildTool: String,
    val group: String
)

object WorkspaceManager {
    private const val WORKSPACE_DIR = "ProjectWizardProjects"

    fun getWorkspaceRoot(context: Context): File {
        val root = File(context.filesDir, WORKSPACE_DIR)
        if (!root.exists()) {
            root.mkdirs()
        }
        return root
    }

    fun listProjects(context: Context): List<GeneratedProject> {
        val root = getWorkspaceRoot(context)
        val projectDirs = root.listFiles { file -> file.isDirectory } ?: emptyArray()
        return projectDirs.map { dir: File ->
            // Try to infer info or set defaults
            val language = if (File(dir, "src/main/kotlin").exists()) "Kotlin" else "Java"
            val buildTool = if (File(dir, "build.gradle").exists() || File(dir, "build.gradle.kts").exists()) "Gradle" else "Maven"
            GeneratedProject(
                name = dir.name,
                path = dir.absolutePath,
                language = language,
                buildTool = buildTool,
                group = "com.example"
            )
        }
    }

    fun seedSampleProjects(context: Context) {
        val root = getWorkspaceRoot(context)
        val projects = root.listFiles()
        if (projects.isNullOrEmpty()) {
            // Create Java Console Sample Project
            createProject(
                context = context,
                projectName = "My_Console_App",
                group = "com.example",
                artifact = "console_app",
                language = "Java",
                buildTool = "Maven"
            )

            // Create Spring Boot Sample Project
            createProject(
                context = context,
                projectName = "My_Spring_API",
                group = "com.project",
                artifact = "spring_api",
                language = "Java",
                buildTool = "Gradle"
            )

            // Create JavaFX Desktop Sample Project
            createProject(
                context = context,
                projectName = "My_Desktop_UI",
                group = "com.view",
                artifact = "desktop_app",
                language = "Kotlin",
                buildTool = "Gradle"
            )
        }
    }

    fun createProject(
        context: Context,
        projectName: String,
        group: String,
        artifact: String,
        language: String,
        buildTool: String
    ): File {
        val root = getWorkspaceRoot(context)
        val projectDir = File(root, projectName.replace(" ", "_"))
        projectDir.mkdirs()

        // Create directory structure
        val srcDir = if (language == "Kotlin") {
            File(projectDir, "src/main/kotlin/${group.replace(".", "/")}/$artifact")
        } else {
            File(projectDir, "src/main/java/${group.replace(".", "/")}/$artifact")
        }
        srcDir.mkdirs()

        // Create main source file
        if (language == "Kotlin") {
            val mainKt = File(srcDir, "Main.kt")
            mainKt.writeText("""
                package $group.$artifact

                fun main() {
                    println("Hello, Project Wizard from Kotlin!")
                    val magicNumber = 42
                    println("Magic number is ${"$"}{magicNumber}")
                }
            """.trimIndent())
        } else {
            val mainJava = File(srcDir, "Main.java")
            mainJava.writeText("""
                package $group.$artifact;

                public class Main {
                    public static void main(String[] args) {
                        System.out.println("Hello, Project Wizard from Java!");
                        int magicNumber = 42;
                        System.out.println("Magic number is " + magicNumber);
                    }
                }
            """.trimIndent())
        }

        // Create build configuration files
        if (buildTool == "Maven") {
            val pomXml = File(projectDir, "pom.xml")
            pomXml.writeText("""
                <?xml version="1.0" encoding="UTF-8"?>
                <project xmlns="http://maven.apache.org/POM/4.0.0"
                         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
                    <modelVersion>4.0.0</modelVersion>

                    <groupId>$group</groupId>
                    <artifactId>$artifact</artifactId>
                    <version>1.0-SNAPSHOT</version>

                    <properties>
                        <maven.compiler.source>17</maven.compiler.source>
                        <maven.compiler.target>17</maven.compiler.target>
                        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
                    </properties>

                    <dependencies>
                        <!-- Added by Project Wizard -->
                        <dependency>
                            <groupId>org.junit.jupiter</groupId>
                            <artifactId>junit-jupiter-api</artifactId>
                            <version>5.10.0</version>
                            <scope>test</scope>
                        </dependency>
                    </dependencies>
                </project>
            """.trimIndent())
        } else {
            val buildGradle = File(projectDir, "build.gradle")
            buildGradle.writeText("""
                plugins {
                    id 'java'
                    id 'application'
                }

                group = '$group'
                version = '1.0-SNAPSHOT'

                repositories {
                    mavenCentral()
                }

                dependencies {
                    testImplementation 'org.junit.jupiter:junit-jupiter:5.10.0'
                }

                application {
                    mainClass = '$group.$artifact.Main'
                }

                test {
                    useJUnitPlatform()
                }
            """.trimIndent())
        }

        // Create README.md
        val readme = File(projectDir, "README.md")
        readme.writeText("""
            # $projectName
            
            Generated with **Project Wizard** on Android.
            
            ## Project details
            - **Group**: $group
            - **Artifact**: $artifact
            - **Language**: $language
            - **Build Tool**: $buildTool
            
            ## Running
            Compile and run this project using your favorite compiler.
        """.trimIndent())

        // Create settings.gradle for Gradle projects
        if (buildTool == "Gradle") {
            val settings = File(projectDir, "settings.gradle")
            settings.writeText("rootProject.name = '$projectName'\n")
        }

        return projectDir
    }
}

val ALL_TEMPLATES = listOf(
    ProjectTemplate(
        id = "java_console",
        icon = "☕",
        name = "Java Console",
        description = "Classic terminal-based Java application with unit test integration.",
        category = "Java",
        techStack = "Java 17, JUnit 5, Maven",
        sampleFiles = mapOf(
            "Main.java" to "public class Main { ... }"
        )
    ),
    ProjectTemplate(
        id = "javafx_desktop",
        icon = "🖥",
        name = "JavaFX Desktop",
        description = "Desktop graphical application using JavaFX with AtlantaFX themes.",
        category = "Desktop",
        techStack = "Java 17, JavaFX, AtlantaFX, Maven",
        sampleFiles = mapOf(
            "Main.java" to "public class Main extends Application { ... }"
        )
    ),
    ProjectTemplate(
        id = "spring_boot",
        icon = "🌱",
        name = "Spring Boot",
        description = "Production-ready Spring Boot backend REST API template.",
        category = "Spring",
        techStack = "Java 17, Spring Boot, Spring Web, Maven",
        sampleFiles = mapOf(
            "ApiController.java" to "@RestController public class ApiController { ... }"
        )
    ),
    ProjectTemplate(
        id = "maven",
        icon = "📦",
        name = "Maven",
        description = "Standard bare-bones Maven structure for custom compilation.",
        category = "Library",
        techStack = "Java, Maven Pom",
        sampleFiles = mapOf(
            "pom.xml" to "<project>...</project>"
        )
    ),
    ProjectTemplate(
        id = "gradle",
        icon = "🐘",
        name = "Gradle",
        description = "Standard empty Gradle project for Java/Kotlin multi-project setups.",
        category = "Library",
        techStack = "Kotlin, Gradle DSL",
        sampleFiles = mapOf(
            "build.gradle.kts" to "plugins { ... }"
        )
    ),
    ProjectTemplate(
        id = "java_library",
        icon = "📚",
        name = "Java Library",
        description = "Reusable library template optimized for public jar distribution.",
        category = "Library",
        techStack = "Java 17, Maven, Gradle",
        sampleFiles = mapOf(
            "Library.java" to "public class Library { ... }"
        )
    )
)
