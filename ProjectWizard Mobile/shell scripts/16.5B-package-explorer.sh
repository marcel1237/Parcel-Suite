#!/usr/bin/env bash
set -e

echo "==========================================="
echo " Project Wizard - Etapa 16.5B"
echo " Package Explorer"
echo "==========================================="

mkdir -p src/main/java/com/projectwizard/view/explorer

###############################################################################
# PackageExplorer.java
###############################################################################

cat > src/main/java/com/projectwizard/view/explorer/PackageExplorer.java <<'EOF'
package com.projectwizard.view.explorer;

import java.io.File;

import javafx.scene.control.TreeItem;
import javafx.scene.control.TreeView;

public class PackageExplorer extends TreeView<File> {

    public PackageExplorer() {

        setShowRoot(true);

    }

    public void openProject(File rootFolder) {

        if (rootFolder == null)
            return;

        TreeItem<File> root = create(rootFolder);

        setRoot(root);

        root.setExpanded(true);

    }

    private TreeItem<File> create(File file) {

        TreeItem<File> item = new TreeItem<>(file);

        if (file.isDirectory()) {

            File[] files = file.listFiles();

            if (files != null) {

                java.util.Arrays.sort(files);

                for (File child : files) {

                    item.getChildren().add(create(child));

                }

            }

        }

        return item;

    }

}
EOF

###############################################################################
# File Cell Factory
###############################################################################

cat > src/main/java/com/projectwizard/view/explorer/FileTreeCell.java <<'EOF'
package com.projectwizard.view.explorer;

import java.io.File;

import javafx.scene.control.TreeCell;

public class FileTreeCell extends TreeCell<File> {

    @Override
    protected void updateItem(File item, boolean empty) {

        super.updateItem(item, empty);

        if (empty || item == null) {

            setText(null);

        } else {

            setText(item.getName().isBlank()
                    ? item.getAbsolutePath()
                    : item.getName());

        }

    }

}
EOF

###############################################################################
echo
echo "==========================================="
echo "Package Explorer criado."
echo "==========================================="
echo
echo "Próximo passo:"
echo
echo "No OpenProjectView,"
echo "substituir o Alert"
echo "por:"
echo
echo "PackageExplorer explorer = new PackageExplorer();"
echo "explorer.setCellFactory(v -> new FileTreeCell());"
echo "explorer.openProject(selectedDirectory);"
echo
echo "na etapa 16.5C."