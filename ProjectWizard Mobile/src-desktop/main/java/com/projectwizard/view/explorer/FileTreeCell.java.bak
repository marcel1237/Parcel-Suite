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
