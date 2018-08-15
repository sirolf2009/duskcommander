package com.sirolf2009.duskcommander.filebrowser;

import com.sirolf2009.duskcommander.DuskCommander;
import com.sirolf2009.duskcommander.filebrowser.FileBrowserSplit;
import io.reactivex.functions.Consumer;
import io.reactivex.rxjavafx.observables.JavaFxObservable;
import io.reactivex.rxjavafx.schedulers.JavaFxScheduler;
import io.reactivex.schedulers.Schedulers;
import java.io.File;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.attribute.PosixFilePermission;
import java.nio.file.attribute.PosixFilePermissions;
import java.util.Collections;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.function.Function;
import java.util.function.Predicate;
import javafx.beans.property.SimpleObjectProperty;
import javafx.beans.property.SimpleStringProperty;
import javafx.beans.value.ChangeListener;
import javafx.beans.value.ObservableValue;
import javafx.collections.FXCollections;
import javafx.collections.ObservableList;
import javafx.collections.transformation.FilteredList;
import javafx.event.EventHandler;
import javafx.scene.Node;
import javafx.scene.control.TableCell;
import javafx.scene.control.TableColumn;
import javafx.scene.control.TableView;
import javafx.scene.control.TextField;
import javafx.scene.image.Image;
import javafx.scene.image.ImageView;
import javafx.scene.input.KeyCode;
import javafx.scene.input.KeyEvent;
import javafx.scene.layout.AnchorPane;
import javafx.util.Callback;
import org.eclipse.xtend.lib.annotations.Accessors;
import org.eclipse.xtext.xbase.lib.CollectionLiterals;
import org.eclipse.xtext.xbase.lib.Conversions;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.eclipse.xtext.xbase.lib.ObjectExtensions;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1;
import org.eclipse.xtext.xbase.lib.Pure;
import org.eclipse.xtext.xbase.lib.StringExtensions;
import tornadofx.SmartResize;

@Accessors
@SuppressWarnings("all")
public class FileBrowser extends AnchorPane {
  private final SimpleObjectProperty<File> pathProperty = new SimpleObjectProperty<File>();
  
  private final SimpleStringProperty filterText = new SimpleStringProperty("");
  
  private final TableView<File> table;
  
  public FileBrowser(final File root) {
    this.getStyleClass().add("background");
    TableView<File> _tableView = new TableView<File>();
    this.table = _tableView;
    this.table.setItems(FXCollections.<File>emptyObservableList());
    SmartResize.Companion.getPOLICY().requestResize(this.table);
    this.getChildren().add(this.table);
    this.maximize(this.table);
    ObservableList<TableColumn<File, ?>> _columns = this.table.getColumns();
    TableColumn<File, File> _tableColumn = new TableColumn<File, File>("Type");
    final Procedure1<TableColumn<File, File>> _function = (TableColumn<File, File> it) -> {
      final Callback<TableColumn.CellDataFeatures<File, File>, ObservableValue<File>> _function_1 = (TableColumn.CellDataFeatures<File, File> it_1) -> {
        File _value = it_1.getValue();
        return new SimpleObjectProperty<File>(_value);
      };
      it.setCellValueFactory(_function_1);
      final Callback<TableColumn<File, File>, TableCell<File, File>> _function_2 = (TableColumn<File, File> it_1) -> {
        return new TableCell<File, File>() {
          @Override
          protected void updateItem(final File item, final boolean empty) {
            super.updateItem(item, empty);
            if (((item == null) || empty)) {
              this.setGraphic(null);
            } else {
              Image _xifexpression = null;
              boolean _isFile = item.isFile();
              if (_isFile) {
                InputStream _resourceAsStream = FileBrowser.class.getResourceAsStream("/file.png");
                _xifexpression = new Image(_resourceAsStream);
              } else {
                InputStream _resourceAsStream_1 = FileBrowser.class.getResourceAsStream("/folder.png");
                _xifexpression = new Image(_resourceAsStream_1);
              }
              final Image image = _xifexpression;
              ImageView _imageView = new ImageView(image);
              final Procedure1<ImageView> _function = (ImageView it_2) -> {
                it_2.setFitWidth(24);
                it_2.setFitHeight(24);
              };
              ImageView _doubleArrow = ObjectExtensions.<ImageView>operator_doubleArrow(_imageView, _function);
              this.setGraphic(_doubleArrow);
            }
          }
        };
      };
      it.setCellFactory(_function_2);
    };
    TableColumn<File, File> _doubleArrow = ObjectExtensions.<TableColumn<File, File>>operator_doubleArrow(_tableColumn, _function);
    _columns.add(_doubleArrow);
    ObservableList<TableColumn<File, ?>> _columns_1 = this.table.getColumns();
    TableColumn<File, String> _tableColumn_1 = new TableColumn<File, String>("Name");
    final Procedure1<TableColumn<File, String>> _function_1 = (TableColumn<File, String> it) -> {
      final Callback<TableColumn.CellDataFeatures<File, String>, ObservableValue<String>> _function_2 = (TableColumn.CellDataFeatures<File, String> it_1) -> {
        File _value = it_1.getValue();
        String _name = null;
        if (_value!=null) {
          _name=_value.getName();
        }
        return new SimpleStringProperty(_name);
      };
      it.setCellValueFactory(_function_2);
    };
    TableColumn<File, String> _doubleArrow_1 = ObjectExtensions.<TableColumn<File, String>>operator_doubleArrow(_tableColumn_1, _function_1);
    _columns_1.add(_doubleArrow_1);
    ObservableList<TableColumn<File, ?>> _columns_2 = this.table.getColumns();
    TableColumn<File, String> _tableColumn_2 = new TableColumn<File, String>("Permissions");
    final Procedure1<TableColumn<File, String>> _function_2 = (TableColumn<File, String> it) -> {
      final Callback<TableColumn.CellDataFeatures<File, String>, ObservableValue<String>> _function_3 = (TableColumn.CellDataFeatures<File, String> it_1) -> {
        final Function<File, Set<PosixFilePermission>> _function_4 = (File it_2) -> {
          Set<PosixFilePermission> _xtrycatchfinallyexpression = null;
          try {
            _xtrycatchfinallyexpression = Files.getPosixFilePermissions(it_2.toPath());
          } catch (final Throwable _t) {
            if (_t instanceof Exception) {
              final Exception e = (Exception)_t;
              return null;
            } else {
              throw Exceptions.sneakyThrow(_t);
            }
          }
          return _xtrycatchfinallyexpression;
        };
        final Predicate<Set<PosixFilePermission>> _function_5 = (Set<PosixFilePermission> it_2) -> {
          return (it_2 != null);
        };
        final Function<Set<PosixFilePermission>, String> _function_6 = (Set<PosixFilePermission> it_2) -> {
          return PosixFilePermissions.toString(it_2);
        };
        String _orElse = Optional.<File>ofNullable(it_1.getValue()).<Set<PosixFilePermission>>map(_function_4).filter(_function_5).<String>map(_function_6).orElse(null);
        return new SimpleStringProperty(_orElse);
      };
      it.setCellValueFactory(_function_3);
    };
    TableColumn<File, String> _doubleArrow_2 = ObjectExtensions.<TableColumn<File, String>>operator_doubleArrow(_tableColumn_2, _function_2);
    _columns_2.add(_doubleArrow_2);
    final io.reactivex.functions.Function<File, Iterable<File>> _function_3 = (File it) -> {
      final Function1<File, Boolean> _function_4 = (File it_1) -> {
        boolean _isHidden = it_1.isHidden();
        return Boolean.valueOf((!_isHidden));
      };
      return IterableExtensions.<File>filter(((Iterable<File>)Conversions.doWrapArray(it.listFiles())), _function_4);
    };
    final io.reactivex.functions.Function<Iterable<File>, List<File>> _function_4 = (Iterable<File> it) -> {
      final Function1<File, String> _function_5 = (File it_1) -> {
        return it_1.getName();
      };
      return IterableExtensions.<File, String>sortBy(it, _function_5);
    };
    final Consumer<List<File>> _function_5 = (List<File> it) -> {
      this.filterText.unbind();
      this.filterText.set("");
      ObservableList<File> _observableArrayList = FXCollections.<File>observableArrayList(it);
      FilteredList<File> _filteredList = new FilteredList<File>(_observableArrayList);
      this.table.setItems(_filteredList);
    };
    JavaFxObservable.<File>valuesOf(this.pathProperty).observeOn(Schedulers.io()).<Iterable<File>>map(_function_3).<List<File>>map(_function_4).observeOn(JavaFxScheduler.platform()).subscribe(_function_5);
    this.pathProperty.set(root);
    final EventHandler<KeyEvent> _function_6 = (KeyEvent it) -> {
      boolean _contains = Collections.<KeyCode>unmodifiableList(CollectionLiterals.<KeyCode>newArrayList(KeyCode.RIGHT, KeyCode.LEFT)).contains(it.getCode());
      if (_contains) {
        it.consume();
      }
    };
    this.<KeyEvent>addEventFilter(KeyEvent.ANY, _function_6);
    final EventHandler<KeyEvent> _function_7 = (KeyEvent it) -> {
      KeyCode _code = it.getCode();
      if (_code != null) {
        switch (_code) {
          case RIGHT:
            final File selected = Optional.<File>ofNullable(this.table.getSelectionModel().getSelectedItem()).orElse(this.table.getItems().get(0));
            boolean _isFile = selected.isFile();
            boolean _not = (!_isFile);
            if (_not) {
              this.filterText.unbind();
              this.filterText.set("");
              FileBrowserSplit.Open _open = new FileBrowserSplit.Open();
              DuskCommander.eventBus.onNext(_open);
            }
            break;
          case LEFT:
            FileBrowserSplit.Ascend _ascend = new FileBrowserSplit.Ascend();
            DuskCommander.eventBus.onNext(_ascend);
            break;
          case DOWN:
            boolean _isFocused = this.table.isFocused();
            boolean _not_1 = (!_isFocused);
            if (_not_1) {
              this.table.getSelectionModel().select(0);
            }
            this.table.requestFocus();
            break;
          default:
            boolean _isLetterKey = it.getCode().isLetterKey();
            if (_isLetterKey) {
              boolean _isEmpty = this.filterText.get().isEmpty();
              if (_isEmpty) {
                String _text = it.getText();
                final TextField textField = new TextField(_text);
                this.filterText.bind(textField.textProperty());
                final ChangeListener<String> _function_8 = (ObservableValue<? extends String> obs, String oldVal, String newVal) -> {
                  boolean _isNullOrEmpty = StringExtensions.isNullOrEmpty(newVal);
                  if (_isNullOrEmpty) {
                    this.getChildren().remove(textField);
                    this.filterText.unbind();
                    ObservableList<File> _items = this.table.getItems();
                    final Predicate<File> _function_9 = (File it_1) -> {
                      return true;
                    };
                    ((FilteredList<File>) _items).setPredicate(_function_9);
                    this.table.requestFocus();
                  } else {
                    ObservableList<File> _items_1 = this.table.getItems();
                    final Predicate<File> _function_10 = (File it_1) -> {
                      return it_1.getName().toLowerCase().startsWith(this.filterText.get().toLowerCase());
                    };
                    ((FilteredList<File>) _items_1).setPredicate(_function_10);
                  }
                };
                this.filterText.addListener(_function_8);
                ObservableList<File> _items = this.table.getItems();
                final Predicate<File> _function_9 = (File it_1) -> {
                  return it_1.getName().toLowerCase().startsWith(this.filterText.get().toLowerCase());
                };
                ((FilteredList<File>) _items).setPredicate(_function_9);
                AnchorPane.setTopAnchor(textField, Double.valueOf(0d));
                AnchorPane.setRightAnchor(textField, Double.valueOf(0d));
                this.getChildren().add(textField);
                textField.requestFocus();
                textField.positionCaret(1);
              }
            }
            break;
        }
      } else {
        boolean _isLetterKey = it.getCode().isLetterKey();
        if (_isLetterKey) {
          boolean _isEmpty = this.filterText.get().isEmpty();
          if (_isEmpty) {
            String _text = it.getText();
            final TextField textField = new TextField(_text);
            this.filterText.bind(textField.textProperty());
            final ChangeListener<String> _function_8 = (ObservableValue<? extends String> obs, String oldVal, String newVal) -> {
              boolean _isNullOrEmpty = StringExtensions.isNullOrEmpty(newVal);
              if (_isNullOrEmpty) {
                this.getChildren().remove(textField);
                this.filterText.unbind();
                ObservableList<File> _items = this.table.getItems();
                final Predicate<File> _function_9 = (File it_1) -> {
                  return true;
                };
                ((FilteredList<File>) _items).setPredicate(_function_9);
                this.table.requestFocus();
              } else {
                ObservableList<File> _items_1 = this.table.getItems();
                final Predicate<File> _function_10 = (File it_1) -> {
                  return it_1.getName().toLowerCase().startsWith(this.filterText.get().toLowerCase());
                };
                ((FilteredList<File>) _items_1).setPredicate(_function_10);
              }
            };
            this.filterText.addListener(_function_8);
            ObservableList<File> _items = this.table.getItems();
            final Predicate<File> _function_9 = (File it_1) -> {
              return it_1.getName().toLowerCase().startsWith(this.filterText.get().toLowerCase());
            };
            ((FilteredList<File>) _items).setPredicate(_function_9);
            AnchorPane.setTopAnchor(textField, Double.valueOf(0d));
            AnchorPane.setRightAnchor(textField, Double.valueOf(0d));
            this.getChildren().add(textField);
            textField.requestFocus();
            textField.positionCaret(1);
          }
        }
      }
    };
    this.<KeyEvent>addEventFilter(KeyEvent.KEY_RELEASED, _function_7);
  }
  
  public TableView.TableViewSelectionModel<File> getSelectionModel() {
    return this.table.getSelectionModel();
  }
  
  public void maximize(final Node node) {
    AnchorPane.setTopAnchor(node, Double.valueOf(0d));
    AnchorPane.setRightAnchor(node, Double.valueOf(0d));
    AnchorPane.setBottomAnchor(node, Double.valueOf(0d));
    AnchorPane.setLeftAnchor(node, Double.valueOf(0d));
  }
  
  @Pure
  public SimpleObjectProperty<File> getPathProperty() {
    return this.pathProperty;
  }
  
  @Pure
  public SimpleStringProperty getFilterText() {
    return this.filterText;
  }
  
  @Pure
  public TableView<File> getTable() {
    return this.table;
  }
}
