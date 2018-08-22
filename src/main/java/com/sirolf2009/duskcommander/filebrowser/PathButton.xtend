package com.sirolf2009.duskcommander.filebrowser

import java.io.File
import javafx.scene.control.Button

import static io.reactivex.rxjavafx.observables.JavaFxObservable.*

import static extension com.sirolf2009.duskcommander.util.RXExtensions.*

class PathButton extends Button {
	
	new(FileBrowserView browser, String name, String path) {
		setText(name)
		val file = new File(path)
		getStyleClass().add("path-button")
		actionEventsOf(this).platform().subscribe[
			browser.navigateTo(file).subscribe()
		]
	}
	
}