package com.sirolf2009.duskcommander;

import com.sirolf2009.duskcommander.filebrowser.FileBrowserSplit
import com.sirolf2009.duskcommander.filebrowser.FileBrowserSplit.NavigateTo
import io.reactivex.subjects.PublishSubject
import io.reactivex.subjects.Subject
import java.io.File
import java.nio.file.Files
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

class DuskCommander extends Application {

	public static val debugProperty = new SimpleBooleanProperty(false)
	public static val Subject<Object> eventBus = PublishSubject.create()
	public static val File configurationFolder = new File(System.getProperty("user.home"), ".duskcommander")

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
				onAction = [evt|
					getItems().clear()
					getItems().addAll(getBookmarks())
					getItems().add(new SeparatorMenuItem())
					getItems().add(reload)
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

	def private static getBookmarks() {
		new ArrayList(Files.lines(new File(configurationFolder, ".sdirs").toPath()).map[replaceFirst("export", "".trim())].map [
			val data = split("=")
			val name = data.get(0).replaceFirst("DIR", "")
			val path = data.get(1).replace("\"", "").replace("$HOME", System.getProperty("user.home"))
			return new MenuItem(name) => [
				onAction = [eventBus.onNext(new NavigateTo(new File(path)))]
			]
		].collect(Collectors.toList()))
	}

}
