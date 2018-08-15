package com.sirolf2009.duskcommander;

import com.sirolf2009.duskcommander.filebrowser.FileBrowserSplit;
import io.reactivex.subjects.PublishSubject;
import io.reactivex.subjects.Subject;
import javafx.application.Application;
import javafx.collections.ObservableMap;
import javafx.event.EventHandler;
import javafx.scene.Scene;
import javafx.scene.control.Menu;
import javafx.scene.control.MenuBar;
import javafx.scene.input.KeyCode;
import javafx.scene.input.KeyCodeCombination;
import javafx.scene.input.KeyCombination;
import javafx.scene.layout.BorderPane;
import javafx.stage.Stage;
import javafx.stage.WindowEvent;

@SuppressWarnings("all")
public class DuskCommander extends Application {
  public static Subject<Object> eventBus = PublishSubject.<Object>create();
  
  public static void main(final String[] args) {
    Application.launch(args);
  }
  
  @Override
  public void start(final Stage primaryStage) throws Exception {
    final BorderPane root = new BorderPane();
    root.getStyleClass().add("background");
    Menu _menu = new Menu("_File");
    MenuBar _menuBar = new MenuBar(_menu);
    root.setTop(_menuBar);
    FileBrowserSplit _fileBrowserSplit = new FileBrowserSplit();
    root.setCenter(_fileBrowserSplit);
    final Scene scene = new Scene(root, 1200, 600);
    ObservableMap<KeyCombination, Runnable> _accelerators = scene.getAccelerators();
    KeyCodeCombination _keyCodeCombination = new KeyCodeCombination(KeyCode.Q, KeyCombination.CONTROL_DOWN);
    final Runnable _function = () -> {
      System.exit(0);
    };
    _accelerators.put(_keyCodeCombination, _function);
    scene.getStylesheets().add("/application.css");
    final EventHandler<WindowEvent> _function_1 = (WindowEvent it) -> {
      System.exit(0);
    };
    primaryStage.setOnCloseRequest(_function_1);
    primaryStage.setScene(scene);
    primaryStage.show();
  }
}
