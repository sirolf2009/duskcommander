package com.sirolf2009.duskcommander;

import com.pastdev.jsch.DefaultSessionFactory
import com.sirolf2009.duskcommander.filebrowser.FileBrowserSplit
import com.sirolf2009.duskcommander.filebrowser.FileBrowserSplit.NavigateTo
import com.sirolf2009.duskcommander.jsch.filesystem.dialog.ConnectionDialog
import io.reactivex.subjects.PublishSubject
import io.reactivex.subjects.Subject
import java.io.File
import java.net.URI
import java.nio.file.FileSystem
import java.nio.file.FileSystems
import java.nio.file.Files
import java.nio.file.Paths
import java.util.ArrayList
import java.util.HashMap
import java.util.stream.Collectors
import javafx.application.Application
import javafx.beans.property.SimpleBooleanProperty
import javafx.collections.FXCollections
import javafx.collections.ObservableMap
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

import static extension com.sirolf2009.duskcommander.util.RXExtensions.*

class DuskCommander extends Application {

	public static val debugProperty = new SimpleBooleanProperty(false)
	public static val Subject<Object> eventBus = PublishSubject.create()
	public static val File configurationFolder = new File(System.getProperty("user.home"), ".duskcommander")
	public static val ObservableMap<URI, FileSystem> fileSystemMap = FXCollections.observableHashMap()

	def static void main(String[] args) {
		launch(args)
	}

	override start(Stage primaryStage) throws Exception {
		val root = new BorderPane()
		root.getStyleClass().add("background")

		root.setTop(new MenuBar(new Menu("_File") => [
			getItems().add(new MenuItem("Toggle Debug") => [
				onAction = [debugProperty.set(!debugProperty.get())]
			])
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
		], new Menu("_Go") => [
			getItems().add(new MenuItem("Connect") => [
				onAction = [
					new ConnectionDialog().showAndWait().fromOptional().io().map [
						val uri = new URI('''ssh.unix://«user»@«host»:22/''');
						if(fileSystemMap.containsKey(uri)) {
							fileSystemMap.get(uri)
						} else {
							val factory = new DefaultSessionFactory(getUser(), getHost(), getPort())
							factory.setKnownHosts(getKnownHosts())
							factory.setIdentityFromPrivateKey(getPrivateKey())

							val environment = new HashMap<String, Object>()
							environment.put("defaultSessionFactory", factory)
							fileSystemMap.put(uri, FileSystems.newFileSystem(uri, environment))
							fileSystemMap.get(uri)
						}
					].subscribe [
						eventBus.onNext(new NavigateTo(rootDirectories.get(0)))
					]
				]
			])
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
