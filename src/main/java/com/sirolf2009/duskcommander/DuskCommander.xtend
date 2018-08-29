package com.sirolf2009.duskcommander;

import com.sirolf2009.duskcommander.extensionpoint.FileExtensionPoint
import com.sirolf2009.duskcommander.extensionpoint.FileSystemExtensionPoint
import com.sirolf2009.duskcommander.extensionpoint.ViewExtensionPoint
import com.sirolf2009.duskcommander.filebrowser.FileBrowserSplit
import com.sirolf2009.duskcommander.filebrowser.FileBrowserSplit.NavigateTo
import io.reactivex.subjects.PublishSubject
import io.reactivex.subjects.Subject
import java.io.File
import java.nio.file.Files
import java.nio.file.Paths
import java.util.ArrayList
import java.util.stream.Collectors
import javafx.application.Application
import javafx.beans.property.SimpleBooleanProperty
import javafx.scene.Scene
import javafx.scene.control.Menu
import javafx.scene.control.MenuBar
import javafx.scene.control.MenuItem
import javafx.scene.control.SeparatorMenuItem
import javafx.scene.input.KeyCode
import javafx.scene.input.KeyCodeCombination
import javafx.scene.input.KeyCombination
import javafx.scene.layout.BorderPane
import javafx.stage.Stage
import org.pf4j.DefaultPluginManager

class DuskCommander extends Application {

	public static val debugProperty = new SimpleBooleanProperty(false)
	public static val Subject<Object> eventBus = PublishSubject.create()
	public static val File configurationFolder = new File(System.getProperty("user.home"), ".duskcommander")

	def static void main(String[] args) {
		launch(args)
	}

	override start(Stage primaryStage) throws Exception {
		val pluginManager = new DefaultPluginManager()
				
		val root = new BorderPane()
		root.getStyleClass().add("background")

		root.setTop(new MenuBar(new Menu("_File") => [
			getItems().add(new MenuItem("Toggle Debug") => [
				onAction = [debugProperty.set(!debugProperty.get())]
			])
			val plugins = pluginManager.getExtensions(FileExtensionPoint)
			if(plugins.size() > 0) {
				getItems().add(new SeparatorMenuItem())
				plugins.forEach [ plugin |
					getItems().add(plugin.getMenuItem())
				]
			}
		], new Menu("_Bookmarks") => [
			getItems().addAll(getBookmarks())
			getItems().add(new SeparatorMenuItem())
			getItems().add(new MenuItem("Reload") => [ reload |
				onAction = [ evt |
					getItems().clear()
					getItems().addAll(getBookmarks())
					getItems().add(new SeparatorMenuItem())
					getItems().add(reload)
				]
			])
		], new Menu("_View") => [
			getItems().add(commandMenuItem("Set Same", new FileBrowserSplit.SetSame()))
			getItems().add(commandMenuItem("Open", new FileBrowserSplit.Open()))
			getItems().add(commandMenuItem("Open In Other", new FileBrowserSplit.OpenInOther()))
			getItems().add(commandMenuItem("Open In Both", new FileBrowserSplit.OpenInBoth()))
			getItems().add(commandMenuItem("Ascend", new FileBrowserSplit.Ascend()))
			getItems().add(commandMenuItem("Ascend In Other", new FileBrowserSplit.AscendInOther()))
			getItems().add(commandMenuItem("Refresh", new FileBrowserSplit.Refresh()))
			getItems().add(new SeparatorMenuItem())
			getItems().add(commandMenuItem("Copy", new FileBrowserSplit.Copy()))
			getItems().add(commandMenuItem("Move", new FileBrowserSplit.Move()))
			getItems().add(commandMenuItem("Delete", new FileBrowserSplit.Delete()))
			val plugins = pluginManager.getExtensions(ViewExtensionPoint)
			if(plugins.size() > 0) {
				getItems().add(new SeparatorMenuItem())
				plugins.forEach [ plugin |
					getItems().add(plugin.getMenuItem())
				]
			}
		], new Menu("_FileSystem") => [
			pluginManager.getExtensions(FileSystemExtensionPoint).forEach [ plugin |
				getItems().add(plugin.getMenuItem())
			]
		]))
		root.setCenter(new FileBrowserSplit())
		val scene = new Scene(root, 1200, 600)
		scene.getAccelerators().put(new KeyCodeCombination(KeyCode.Q, KeyCombination.CONTROL_DOWN)) [
			System.exit(0)
		]
		scene.getStylesheets().add("/application.css")
		primaryStage.setOnCloseRequest[System.exit(0)]
		primaryStage.setScene(scene)
		primaryStage.show()
	}

	def static commandMenuItem(String name, Object command) {
		return new MenuItem(name) => [
			setOnAction = [
				eventBus.onNext(command)
			]
		]
	}

	def private static getBookmarks() {
		new ArrayList(Files.lines(new File(configurationFolder, ".sdirs").toPath()).map[replaceFirst("export", "".trim())].map [
			val data = split("=")
			val name = data.get(0).replaceFirst("DIR", "")
			val path = data.get(1).replace("\"", "").replace("$HOME", System.getProperty("user.home"))
			return new MenuItem(name) => [
				onAction = [eventBus.onNext(new NavigateTo(Paths.get(path)))]
			]
		].collect(Collectors.toList()))
	}

}
