package com.sirolf2009.duskcommander;

import com.sirolf2009.duskcommander.filebrowser.FileBrowserSplit
import io.reactivex.subjects.PublishSubject
import io.reactivex.subjects.Subject
import javafx.application.Application
import javafx.scene.Scene
import javafx.scene.control.Menu
import javafx.scene.control.MenuBar
import javafx.scene.input.KeyCode
import javafx.scene.input.KeyCodeCombination
import javafx.scene.input.KeyCombination
import javafx.scene.layout.BorderPane
import javafx.stage.Stage

class DuskCommander extends Application {
	
	public static Subject<Object> eventBus = PublishSubject.create()

	def static void main(String[] args) {
		launch(args)
	}

	override start(Stage primaryStage) throws Exception {
		val root = new BorderPane()
		root.getStyleClass().add("background")
		
		root.setTop(new MenuBar(new Menu("_File")))
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

}
