package com.sirolf2009.duskcommander.filebrowser.dialog

import com.sirolf2009.duskcommander.DuskDialog
import java.io.File
import javafx.scene.control.ButtonBar.ButtonData
import javafx.scene.control.ButtonType
import javafx.scene.control.Label
import javafx.scene.control.TextField

class MoveDialog extends DuskDialog<Pair<File, File>> {

	val TextField txtFrom
	val TextField txtTo

	new(File from, File to) {
		setTitle("Move Dialog")
		getDialogPane().getButtonTypes().addAll(ButtonType.OK, ButtonType.CANCEL)
		txtFrom = new TextField(from.getAbsolutePath())
		txtTo = new TextField(to.getAbsolutePath())
		getDialogPane().setContent(formMigLayout() => [
			add(new Label("From"))
			add(txtFrom, "wrap")
			add(new Label("To"))
			add(txtTo, "wrap")
		])
		setResultConverter = [
			if(getButtonData() == ButtonData.OK_DONE) {
				return new File(txtFrom.getText()) -> new File(txtTo.getText())
			}
		]
	}

}
