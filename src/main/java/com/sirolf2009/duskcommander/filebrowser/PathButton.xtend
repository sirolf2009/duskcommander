package com.sirolf2009.duskcommander.filebrowser

import java.nio.file.Path
import javafx.scene.control.Button

import static io.reactivex.rxjavafx.observables.JavaFxObservable.*

import static extension com.sirolf2009.duskcommander.util.RXExtensions.*

class PathButton extends Button {
	
	new(FileBrowserView browser, String name, Path path) {
		setText(name)
		getStyleClass().add("path-button")
		actionEventsOf(this).platform().subscribe[
			browser.navigateTo(path).subscribe()
		]
	}
	
}