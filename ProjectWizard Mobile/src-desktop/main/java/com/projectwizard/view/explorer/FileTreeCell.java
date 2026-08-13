package com.projectwizard.view.explorer;

import java.io.File;

import javafx.geometry.Insets;
import javafx.scene.control.TreeCell;
import javafx.scene.layout.HBox;
import javafx.scene.text.Text;

/**
 * FileTreeCell with Smart File Type Icons
 * 
 * Displays appropriate emoji for file types:
 * Java, Build tools, Web, Docs, VCS, etc.
 */
public class FileTreeCell extends TreeCell<File> {

    @Override
    protected void updateItem(File item, boolean empty) {
        super.updateItem(item, empty);

        if (empty || item == null) {
            setText(null);
            setGraphic(null);
        } else {
            String displayName = item.getName().isBlank()
                    ? item.getAbsolutePath()
                    : item.getName();

            String icon = getIcon(item);
            Text iconText = new Text(icon);
            iconText.setStyle("-fx-font-size: 14px;");

            HBox hbox = new HBox(8, iconText, new Text(displayName));
            hbox.setPadding(new Insets(2));

            setGraphic(hbox);
            setText(null);
        }
    }

    private String getIcon(File file) {
        if (file == null)
            return "❓";

        if (file.isDirectory()) {
            String name = file.getName().toLowerCase();
            if (name.equals("src"))
                return "📦";
            if (name.equals("test"))
                return "🧪";
            if (name.equals("resources"))
                return "📚";
            if (name.equals("target") || name.equals("build"))
                return "🔨";
            if (name.equals(".git"))
                return "🌿";
            return "📁";
        }

        String name = file.getName().toLowerCase();

        if (name.endsWith(".java"))
            return "☕";
        if (name.endsWith(".class"))
            return "🔶";
        if (name.endsWith(".jar"))
            return "📦";
        if (name.endsWith(".xml"))
            return "⚙";
        if (name.endsWith(".json"))
            return "📋";
        if (name.endsWith(".md"))
            return "📄";
        if (name.endsWith(".yml") || name.endsWith(".yaml"))
            return "⚙";
        if (name.endsWith(".properties"))
            return "🔧";
        if (name.endsWith(".css"))
            return "🎨";
        if (name.endsWith(".html") || name.endsWith(".fxml"))
            return "🌐";
        if (name.endsWith(".sql"))
            return "🗄";
        if (name.endsWith(".sh") || name.endsWith(".bat"))
            return "⚡";
        if (name.startsWith("."))
            return "🔒";

        return "📄";
    }

}
