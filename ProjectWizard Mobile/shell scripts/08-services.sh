#!/usr/bin/env bash
set -Eeuo pipefail

echo "========================================="
echo " Project Wizard - Etapa 08"
echo " Camada de Services"
echo "========================================="

if [ ! -f pom.xml ]; then
    echo "Execute este script dentro da pasta ProjectWizard."
    exit 1
fi

mkdir -p src/main/java/com/projectwizard/service

cat > src/main/java/com/projectwizard/service/DialogService.java <<'EOF'
package com.projectwizard.service;

public class DialogService {

    public void showInformation(String title, String message) {

        System.out.println("[" + title + "] " + message);

    }

}
EOF

cat > src/main/java/com/projectwizard/service/FileSystemService.java <<'EOF'
package com.projectwizard.service;

import java.nio.file.Files;
import java.nio.file.Path;

public class FileSystemService {

    public boolean exists(Path path) {

        return Files.exists(path);

    }

}
EOF

cat > src/main/java/com/projectwizard/service/SettingsService.java <<'EOF'
package com.projectwizard.service;

public class SettingsService {

    public String getTheme() {

        return "Default";

    }

}
EOF

cat > src/main/java/com/projectwizard/service/ProjectService.java <<'EOF'
package com.projectwizard.service;

public class ProjectService {

    public void createProject() {

        System.out.println("Project creation will be implemented in a future step.");

    }

}
EOF

cat > src/main/java/com/projectwizard/core/ApplicationContext.java <<'EOF'
package com.projectwizard.core;

import com.projectwizard.service.DialogService;
import com.projectwizard.service.FileSystemService;
import com.projectwizard.service.ProjectService;
import com.projectwizard.service.SettingsService;

public class ApplicationContext {

    private final DialogService dialogService;
    private final FileSystemService fileSystemService;
    private final ProjectService projectService;
    private final SettingsService settingsService;

    public ApplicationContext() {

        dialogService = new DialogService();
        fileSystemService = new FileSystemService();
        projectService = new ProjectService();
        settingsService = new SettingsService();

    }

    public String getApplicationName() {

        return Constants.APPLICATION_NAME;

    }

    public String getVersion() {

        return Version.VERSION;

    }

    public DialogService getDialogService() {

        return dialogService;

    }

    public FileSystemService getFileSystemService() {

        return fileSystemService;

    }

    public ProjectService getProjectService() {

        return projectService;

    }

    public SettingsService getSettingsService() {

        return settingsService;

    }

}
EOF

echo
echo "========================================="
echo " Services criados com sucesso!"
echo "========================================="
echo
echo "Execute:"
echo
echo "mvn clean javafx:run"
