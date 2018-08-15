package com.sirolf2009.duskcommander.filebrowser;

import com.kodedu.terminalfx.Terminal;
import com.sirolf2009.duskcommander.util.RXExtensions;
import io.reactivex.functions.Consumer;
import io.reactivex.rxjavafx.observables.JavaFxObservable;
import javafx.event.ActionEvent;
import javafx.scene.control.Button;

@SuppressWarnings("all")
public class ActionButton extends Button {
  private final Terminal terminal;
  
  private final String command;
  
  public ActionButton(final Terminal terminal, final String text, final String command) {
    this.terminal = terminal;
    this.command = command;
    this.setText(text);
    final Consumer<ActionEvent> _function = (ActionEvent it) -> {
      this.sendCommand();
    };
    RXExtensions.<ActionEvent>platform(JavaFxObservable.actionEventsOf(this)).subscribe(_function);
  }
  
  public void sendCommand() {
    this.terminal.command((this.command + "\n"));
  }
}
