package com.sirolf2009.duskcommander.filebrowser;

import com.sirolf2009.duskcommander.util.RXExtensions;
import io.reactivex.functions.Consumer;
import io.reactivex.rxjavafx.observables.JavaFxObservable;
import java.io.File;
import javafx.beans.property.ObjectProperty;
import javafx.event.ActionEvent;
import javafx.scene.control.Button;

@SuppressWarnings("all")
public class PathButton extends Button {
  public PathButton(final ObjectProperty<File> pathProperty, final String path) {
    this.setText(path);
    final File file = new File(path);
    final Consumer<ActionEvent> _function = (ActionEvent it) -> {
      pathProperty.set(file);
    };
    RXExtensions.<ActionEvent>platform(JavaFxObservable.actionEventsOf(this)).subscribe(_function);
  }
}
