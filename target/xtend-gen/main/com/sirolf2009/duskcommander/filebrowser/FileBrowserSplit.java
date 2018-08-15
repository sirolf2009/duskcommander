package com.sirolf2009.duskcommander.filebrowser;

import com.google.common.base.Objects;
import com.sirolf2009.duskcommander.DuskCommander;
import com.sirolf2009.duskcommander.filebrowser.FileBrowserView;
import com.sirolf2009.duskcommander.util.RXExtensions;
import io.reactivex.functions.Consumer;
import java.io.File;
import java.util.Optional;
import javafx.scene.control.SplitPane;
import org.eclipse.xtend.lib.annotations.Data;
import org.eclipse.xtext.xbase.lib.Pure;
import org.eclipse.xtext.xbase.lib.util.ToStringBuilder;

@SuppressWarnings("all")
public class FileBrowserSplit extends SplitPane {
  @Data
  public static class NavigateTo {
    private final File file;
    
    public NavigateTo(final File file) {
      super();
      this.file = file;
    }
    
    @Override
    @Pure
    public int hashCode() {
      final int prime = 31;
      int result = 1;
      result = prime * result + ((this.file== null) ? 0 : this.file.hashCode());
      return result;
    }
    
    @Override
    @Pure
    public boolean equals(final Object obj) {
      if (this == obj)
        return true;
      if (obj == null)
        return false;
      if (getClass() != obj.getClass())
        return false;
      FileBrowserSplit.NavigateTo other = (FileBrowserSplit.NavigateTo) obj;
      if (this.file == null) {
        if (other.file != null)
          return false;
      } else if (!this.file.equals(other.file))
        return false;
      return true;
    }
    
    @Override
    @Pure
    public String toString() {
      ToStringBuilder b = new ToStringBuilder(this);
      b.add("file", this.file);
      return b.toString();
    }
    
    @Pure
    public File getFile() {
      return this.file;
    }
  }
  
  @Data
  public static class NavigateToInOther {
    private final File file;
    
    public NavigateToInOther(final File file) {
      super();
      this.file = file;
    }
    
    @Override
    @Pure
    public int hashCode() {
      final int prime = 31;
      int result = 1;
      result = prime * result + ((this.file== null) ? 0 : this.file.hashCode());
      return result;
    }
    
    @Override
    @Pure
    public boolean equals(final Object obj) {
      if (this == obj)
        return true;
      if (obj == null)
        return false;
      if (getClass() != obj.getClass())
        return false;
      FileBrowserSplit.NavigateToInOther other = (FileBrowserSplit.NavigateToInOther) obj;
      if (this.file == null) {
        if (other.file != null)
          return false;
      } else if (!this.file.equals(other.file))
        return false;
      return true;
    }
    
    @Override
    @Pure
    public String toString() {
      ToStringBuilder b = new ToStringBuilder(this);
      b.add("file", this.file);
      return b.toString();
    }
    
    @Pure
    public File getFile() {
      return this.file;
    }
  }
  
  @Data
  public static class SetSame {
    @Override
    @Pure
    public int hashCode() {
      int result = 1;
      return result;
    }
    
    @Override
    @Pure
    public boolean equals(final Object obj) {
      if (this == obj)
        return true;
      if (obj == null)
        return false;
      if (getClass() != obj.getClass())
        return false;
      return true;
    }
    
    @Override
    @Pure
    public String toString() {
      ToStringBuilder b = new ToStringBuilder(this);
      return b.toString();
    }
  }
  
  @Data
  public static class Open {
    @Override
    @Pure
    public int hashCode() {
      int result = 1;
      return result;
    }
    
    @Override
    @Pure
    public boolean equals(final Object obj) {
      if (this == obj)
        return true;
      if (obj == null)
        return false;
      if (getClass() != obj.getClass())
        return false;
      return true;
    }
    
    @Override
    @Pure
    public String toString() {
      ToStringBuilder b = new ToStringBuilder(this);
      return b.toString();
    }
  }
  
  @Data
  public static class OpenInOther {
    @Override
    @Pure
    public int hashCode() {
      int result = 1;
      return result;
    }
    
    @Override
    @Pure
    public boolean equals(final Object obj) {
      if (this == obj)
        return true;
      if (obj == null)
        return false;
      if (getClass() != obj.getClass())
        return false;
      return true;
    }
    
    @Override
    @Pure
    public String toString() {
      ToStringBuilder b = new ToStringBuilder(this);
      return b.toString();
    }
  }
  
  @Data
  public static class OpenInBoth {
    @Override
    @Pure
    public int hashCode() {
      int result = 1;
      return result;
    }
    
    @Override
    @Pure
    public boolean equals(final Object obj) {
      if (this == obj)
        return true;
      if (obj == null)
        return false;
      if (getClass() != obj.getClass())
        return false;
      return true;
    }
    
    @Override
    @Pure
    public String toString() {
      ToStringBuilder b = new ToStringBuilder(this);
      return b.toString();
    }
  }
  
  @Data
  public static class Ascend {
    @Override
    @Pure
    public int hashCode() {
      int result = 1;
      return result;
    }
    
    @Override
    @Pure
    public boolean equals(final Object obj) {
      if (this == obj)
        return true;
      if (obj == null)
        return false;
      if (getClass() != obj.getClass())
        return false;
      return true;
    }
    
    @Override
    @Pure
    public String toString() {
      ToStringBuilder b = new ToStringBuilder(this);
      return b.toString();
    }
  }
  
  @Data
  public static class AscendInOther {
    @Override
    @Pure
    public int hashCode() {
      int result = 1;
      return result;
    }
    
    @Override
    @Pure
    public boolean equals(final Object obj) {
      if (this == obj)
        return true;
      if (obj == null)
        return false;
      if (getClass() != obj.getClass())
        return false;
      return true;
    }
    
    @Override
    @Pure
    public String toString() {
      ToStringBuilder b = new ToStringBuilder(this);
      return b.toString();
    }
  }
  
  private final FileBrowserView left;
  
  private final FileBrowserView right;
  
  public FileBrowserSplit() {
    String _property = System.getProperty("user.home");
    File _file = new File(_property);
    FileBrowserView _fileBrowserView = new FileBrowserView(_file);
    this.left = _fileBrowserView;
    String _property_1 = System.getProperty("user.home");
    File _file_1 = new File(_property_1);
    FileBrowserView _fileBrowserView_1 = new FileBrowserView(_file_1);
    this.right = _fileBrowserView_1;
    this.getItems().addAll(this.left, this.right);
    final Consumer<FileBrowserSplit.NavigateTo> _function = (FileBrowserSplit.NavigateTo it) -> {
      this.getPrimary().pathProperty().set(it.getFile());
    };
    RXExtensions.<FileBrowserSplit.NavigateTo>type(DuskCommander.eventBus, FileBrowserSplit.NavigateTo.class).subscribe(_function);
    final Consumer<FileBrowserSplit.NavigateToInOther> _function_1 = (FileBrowserSplit.NavigateToInOther it) -> {
      this.getSecundary().pathProperty().set(it.getFile());
    };
    RXExtensions.<FileBrowserSplit.NavigateToInOther>type(DuskCommander.eventBus, FileBrowserSplit.NavigateToInOther.class).subscribe(_function_1);
    final Consumer<FileBrowserSplit.SetSame> _function_2 = (FileBrowserSplit.SetSame it) -> {
      this.getSecundary().pathProperty().set(this.getPrimary().pathProperty().get());
    };
    RXExtensions.<FileBrowserSplit.SetSame>type(DuskCommander.eventBus, FileBrowserSplit.SetSame.class).subscribe(_function_2);
    final Consumer<FileBrowserSplit.Open> _function_3 = (FileBrowserSplit.Open it) -> {
      final java.util.function.Consumer<File> _function_4 = (File it_1) -> {
        this.getPrimary().pathProperty().set(it_1);
      };
      this.getPrimaryFile().ifPresent(_function_4);
    };
    RXExtensions.<FileBrowserSplit.Open>type(DuskCommander.eventBus, FileBrowserSplit.Open.class).subscribe(_function_3);
    final Consumer<FileBrowserSplit.OpenInOther> _function_4 = (FileBrowserSplit.OpenInOther it) -> {
      final java.util.function.Consumer<File> _function_5 = (File it_1) -> {
        this.getSecundary().pathProperty().set(it_1);
      };
      this.getPrimaryFile().ifPresent(_function_5);
    };
    RXExtensions.<FileBrowserSplit.OpenInOther>type(DuskCommander.eventBus, FileBrowserSplit.OpenInOther.class).subscribe(_function_4);
    final Consumer<FileBrowserSplit.OpenInBoth> _function_5 = (FileBrowserSplit.OpenInBoth it) -> {
      final java.util.function.Consumer<File> _function_6 = (File it_1) -> {
        this.getPrimary().pathProperty().set(it_1);
        this.getSecundary().pathProperty().set(it_1);
      };
      this.getPrimaryFile().ifPresent(_function_6);
    };
    RXExtensions.<FileBrowserSplit.OpenInBoth>type(DuskCommander.eventBus, FileBrowserSplit.OpenInBoth.class).subscribe(_function_5);
    final Consumer<FileBrowserSplit.Ascend> _function_6 = (FileBrowserSplit.Ascend it) -> {
      final java.util.function.Consumer<File> _function_7 = (File it_1) -> {
        this.getPrimary().pathProperty().set(it_1);
      };
      Optional.<File>ofNullable(this.getPrimary().pathProperty().get().getParentFile()).ifPresent(_function_7);
    };
    RXExtensions.<FileBrowserSplit.Ascend>type(DuskCommander.eventBus, FileBrowserSplit.Ascend.class).subscribe(_function_6);
    final Consumer<FileBrowserSplit.AscendInOther> _function_7 = (FileBrowserSplit.AscendInOther it) -> {
      final java.util.function.Consumer<File> _function_8 = (File it_1) -> {
        this.getSecundary().pathProperty().set(it_1);
      };
      Optional.<File>ofNullable(this.getPrimary().pathProperty().get().getParentFile()).ifPresent(_function_8);
    };
    RXExtensions.<FileBrowserSplit.AscendInOther>type(DuskCommander.eventBus, FileBrowserSplit.AscendInOther.class).subscribe(_function_7);
  }
  
  public Optional<File> getPrimaryFile() {
    return Optional.<File>ofNullable(this.getPrimary().getFileBrowser().getSelectionModel().getSelectedItem());
  }
  
  public Optional<File> getSecundaryFile() {
    return Optional.<File>ofNullable(this.getSecundary().getFileBrowser().getSelectionModel().getSelectedItem());
  }
  
  public FileBrowserView getPrimary() {
    if ((this.left.isFocused() || this.left.getFileBrowser().isFocused())) {
      return this.left;
    }
    if ((this.right.isFocused() || this.right.getFileBrowser().isFocused())) {
      return this.right;
    }
    return this.left;
  }
  
  public FileBrowserView getSecundary() {
    FileBrowserView _primary = this.getPrimary();
    boolean _equals = Objects.equal(_primary, this.left);
    if (_equals) {
      return this.right;
    }
    return this.left;
  }
}
