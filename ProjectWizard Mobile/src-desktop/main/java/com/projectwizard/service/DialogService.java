package com.projectwizard.service;

import javafx.scene.control.Alert;
import javafx.scene.control.Alert.AlertType;

public class DialogService {
    public void showError(String title, String message) {
        Alert alert = new Alert(AlertType.ERROR);
        alert.setTitle(title);
        alert.setHeaderText(null);
        alert.setContentText(message);
        alert.showAndWait();
    }
    
    public void showInfo(String title, String message) {
        showInformation(title, message);
    }

    public void showInformation(String title, String message) {
        Alert alert = new Alert(AlertType.INFORMATION);
        alert.setTitle(title);
        alert.setHeaderText(null);
        alert.setContentText(message);
        alert.showAndWait();
    }
}
