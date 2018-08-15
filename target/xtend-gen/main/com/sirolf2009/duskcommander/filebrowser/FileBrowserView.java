package com.sirolf2009.duskcommander.filebrowser;

import com.google.common.collect.Iterables;
import com.kodedu.terminalfx.Terminal;
import com.kodedu.terminalfx.config.TerminalConfig;
import com.sirolf2009.duskcommander.filebrowser.ActionButton;
import com.sirolf2009.duskcommander.filebrowser.FileBrowser;
import com.sirolf2009.duskcommander.filebrowser.PathButton;
import com.sirolf2009.duskcommander.util.RXExtensions;
import io.reactivex.Observable;
import io.reactivex.functions.Consumer;
import io.reactivex.functions.Function;
import io.reactivex.functions.Predicate;
import io.reactivex.rxjavafx.observables.JavaFxObservable;
import java.io.File;
import java.io.Writer;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;
import javafx.beans.property.SimpleObjectProperty;
import javafx.collections.ObservableList;
import javafx.event.EventHandler;
import javafx.geometry.Orientation;
import javafx.scene.Node;
import javafx.scene.control.SplitPane;
import javafx.scene.input.KeyCode;
import javafx.scene.input.KeyEvent;
import javafx.scene.layout.HBox;
import javafx.scene.layout.Priority;
import javafx.scene.layout.VBox;
import javafx.scene.paint.Color;
import org.eclipse.xtend.lib.annotations.Accessors;
import org.eclipse.xtext.xbase.lib.CollectionLiterals;
import org.eclipse.xtext.xbase.lib.Conversions;
import org.eclipse.xtext.xbase.lib.ExclusiveRange;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.Functions.Function2;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.eclipse.xtext.xbase.lib.ObjectExtensions;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1;
import org.eclipse.xtext.xbase.lib.Pure;

@Accessors
@SuppressWarnings("all")
public class FileBrowserView extends SplitPane {
  private final HBox commandElements;
  
  private final HBox pathElements;
  
  private final FileBrowser fileBrowser;
  
  private final Terminal terminal;
  
  public FileBrowserView() {
    this(new File("."));
  }
  
  public FileBrowserView(final File root) {
    this.setOrientation(Orientation.VERTICAL);
    FileBrowser _fileBrowser = new FileBrowser(root);
    this.fileBrowser = _fileBrowser;
    VBox.setVgrow(this.fileBrowser, Priority.ALWAYS);
    Terminal _terminal = new Terminal();
    this.terminal = _terminal;
    TerminalConfig _terminalConfig = new TerminalConfig();
    final Procedure1<TerminalConfig> _function = (TerminalConfig it) -> {
      it.setUnixTerminalStarter("/usr/bin/fish");
      it.setBackgroundColor(Color.web("#002b36"));
      it.setForegroundColor(Color.web("#839496"));
      it.setCursorColor(Color.web("#93a1a1", 0.5d));
    };
    TerminalConfig _doubleArrow = ObjectExtensions.<TerminalConfig>operator_doubleArrow(_terminalConfig, _function);
    this.terminal.updatePrefs(_doubleArrow);
    HBox _hBox = new HBox();
    final Procedure1<HBox> _function_1 = (HBox it) -> {
      it.getStyleClass().add("background");
    };
    HBox _doubleArrow_1 = ObjectExtensions.<HBox>operator_doubleArrow(_hBox, _function_1);
    this.pathElements = _doubleArrow_1;
    final Consumer<File> _function_2 = (File it) -> {
      this.getButtons().clear();
      Writer _outputWriter = this.terminal.getOutputWriter();
      Writer _append = null;
      if (_outputWriter!=null) {
        _append=_outputWriter.append((("cd " + it) + "\n"));
      }
      if (_append!=null) {
        _append.flush();
      }
    };
    final Function<File, Iterable<PathButton>> _function_3 = (File it) -> {
      PathButton _fileBrowserButton = this.fileBrowserButton("/");
      final Function1<Path, PathButton> _function_4 = (Path it_1) -> {
        return this.fileBrowserButton(it_1.toString());
      };
      Iterable<PathButton> _map = IterableExtensions.<Path, PathButton>map(it.toPath(), _function_4);
      return Iterables.<PathButton>concat(Collections.<PathButton>unmodifiableList(CollectionLiterals.<PathButton>newArrayList(_fileBrowserButton)), _map);
    };
    final Consumer<Throwable> _function_4 = (Throwable it) -> {
      it.printStackTrace();
    };
    final Consumer<Iterable<PathButton>> _function_5 = (Iterable<PathButton> it) -> {
      Iterables.<Node>addAll(this.getButtons(), it);
    };
    RXExtensions.<Iterable<PathButton>>platform(RXExtensions.<File>computation(RXExtensions.<File>platform(JavaFxObservable.<File>valuesOf(this.pathProperty())).doOnNext(_function_2)).<Iterable<PathButton>>map(_function_3)).doOnError(_function_4).subscribe(_function_5);
    HBox _hBox_1 = new HBox();
    final Procedure1<HBox> _function_6 = (HBox it) -> {
      it.getStyleClass().add("background");
    };
    HBox _doubleArrow_2 = ObjectExtensions.<HBox>operator_doubleArrow(_hBox_1, _function_6);
    this.commandElements = _doubleArrow_2;
    final Consumer<File> _function_7 = (File it) -> {
      this.getCommands().clear();
    };
    final Function<File, Observable<File>> _function_8 = (File it) -> {
      return Observable.<File>fromArray(it.listFiles());
    };
    final Predicate<File> _function_9 = (File it) -> {
      return (it.isFile() && it.getName().equals(".duskcommander"));
    };
    final Function<File, List<ActionButton>> _function_10 = (File it) -> {
      final java.util.function.Predicate<String> _function_11 = (String it_1) -> {
        boolean _startsWith = it_1.startsWith("#");
        return (!_startsWith);
      };
      final java.util.function.Function<String, String[]> _function_12 = (String it_1) -> {
        return it_1.split(":");
      };
      final java.util.function.Function<String[], ActionButton> _function_13 = (String[] it_1) -> {
        String _get = it_1[0];
        int _size = ((List<String>)Conversions.doWrapArray(it_1)).size();
        final Function1<Integer, String> _function_14 = (Integer index) -> {
          return it_1[(index).intValue()];
        };
        final Function2<String, String, String> _function_15 = (String a, String b) -> {
          return (a + b);
        };
        String _reduce = IterableExtensions.<String>reduce(IterableExtensions.<Integer, String>map(new ExclusiveRange(1, _size, true), _function_14), _function_15);
        return new ActionButton(this.terminal, _get, _reduce);
      };
      return Files.lines(it.toPath()).filter(_function_11).<String[]>map(_function_12).<ActionButton>map(_function_13).collect(Collectors.<ActionButton>toList());
    };
    final Consumer<Throwable> _function_11 = (Throwable it) -> {
      it.printStackTrace();
    };
    final Consumer<List<ActionButton>> _function_12 = (List<ActionButton> it) -> {
      this.getCommands().addAll(it);
    };
    RXExtensions.<List<ActionButton>>platform(RXExtensions.<File>computation(RXExtensions.<File>platform(JavaFxObservable.<File>valuesOf(this.pathProperty())).doOnNext(_function_7)).<File>flatMap(_function_8).filter(_function_9).<List<ActionButton>>map(_function_10)).doOnError(_function_11).subscribe(_function_12);
    final EventHandler<KeyEvent> _function_13 = (KeyEvent it) -> {
      if ((it.getCode().isDigitKey() && it.isControlDown())) {
        final int index = Collections.<KeyCode>unmodifiableList(CollectionLiterals.<KeyCode>newArrayList(KeyCode.DIGIT1, KeyCode.DIGIT2, KeyCode.DIGIT3, KeyCode.DIGIT4, KeyCode.DIGIT5, KeyCode.DIGIT6, KeyCode.DIGIT7, KeyCode.DIGIT8, KeyCode.DIGIT9, KeyCode.DIGIT0)).indexOf(it.getCode());
        int _size = this.getCommands().size();
        boolean _greaterThan = (_size > index);
        if (_greaterThan) {
          Node _get = this.getCommands().get(index);
          ((ActionButton) _get).sendCommand();
        }
      }
    };
    this.<KeyEvent>addEventFilter(KeyEvent.KEY_PRESSED, _function_13);
    ObservableList<Node> _items = this.getItems();
    VBox _vBox = new VBox(this.commandElements, this.pathElements, this.fileBrowser);
    _items.addAll(_vBox, this.terminal);
    this.setDividerPositions(0.8);
  }
  
  public SimpleObjectProperty<File> pathProperty() {
    return this.fileBrowser.getPathProperty();
  }
  
  public ObservableList<Node> getCommands() {
    return this.commandElements.getChildren();
  }
  
  public ObservableList<Node> getButtons() {
    return this.pathElements.getChildren();
  }
  
  public PathButton fileBrowserButton(final String path) {
    SimpleObjectProperty<File> _pathProperty = this.fileBrowser.getPathProperty();
    return new PathButton(_pathProperty, path);
  }
  
  @Pure
  public HBox getCommandElements() {
    return this.commandElements;
  }
  
  @Pure
  public HBox getPathElements() {
    return this.pathElements;
  }
  
  @Pure
  public FileBrowser getFileBrowser() {
    return this.fileBrowser;
  }
  
  @Pure
  public Terminal getTerminal() {
    return this.terminal;
  }
}
