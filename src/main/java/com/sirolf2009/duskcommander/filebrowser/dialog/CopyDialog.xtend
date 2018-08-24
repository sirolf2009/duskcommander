package com.sirolf2009.duskcommander.filebrowser.dialog

import com.sirolf2009.duskcommander.DuskDialog
import java.nio.file.Path
import javafx.scene.control.ButtonBar.ButtonData
import javafx.scene.control.ButtonType
import javafx.scene.control.Label
import javafx.scene.control.TextField

class CopyDialog extends DuskDialog<Pair<Path, Path>> {

	val TextField txtFrom
	val TextField txtTo

	new(Path from, Path to) {
		setTitle("Copy Dialog")
		getDialogPane().getButtonTypes().addAll(ButtonType.OK, ButtonType.CANCEL)
		txtFrom = new TextField(from.toString())
		txtTo = new TextField(to.toString())
		getDialogPane().setContent(formMigLayout() => [
			add(new Label("From"))
			add(txtFrom, "wrap")
			add(new Label("To"))
			add(txtTo, "wrap")
		])
		setResultConverter = [
			if(getButtonData() == ButtonData.OK_DONE) {
				return from.resolve(txtFrom.getText()) -> to.resolve(txtTo.getText())
			}
		]
	}

}
