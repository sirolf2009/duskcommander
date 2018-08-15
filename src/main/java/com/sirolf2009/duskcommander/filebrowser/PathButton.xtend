package com.sirolf2009.duskcommander.filebrowser

import java.io.File
import javafx.beans.property.ObjectProperty
import javafx.scene.control.Button

import static io.reactivex.rxjavafx.observables.JavaFxObservable.*

import static extension com.sirolf2009.duskcommander.util.RXExtensions.*

class PathButton extends Button {
	
	new(ObjectProperty<File> pathProperty, String path) {
		setText(path)
		val file = new File(path)
		actionEventsOf(this).platform().subscribe[
			pathProperty.set(file)
		]
	}
	
}