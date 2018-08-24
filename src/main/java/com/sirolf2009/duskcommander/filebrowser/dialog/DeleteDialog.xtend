package com.sirolf2009.duskcommander.filebrowser.dialog

import com.sirolf2009.duskcommander.DuskDialog
import java.nio.file.Path
import javafx.scene.control.ButtonBar.ButtonData
import javafx.scene.control.ButtonType
import javafx.scene.control.Label
import javafx.scene.control.TextField

class DeleteDialog extends DuskDialog<Path> {

	val TextField txtPath

	new(Path path) {
		setTitle("Delete Dialog")
		getDialogPane().getButtonTypes().addAll(ButtonType.OK, ButtonType.CANCEL)
		txtPath = new TextField(path.toString())
		getDialogPane().setContent(formMigLayout() => [
			add(new Label("Path"))
			add(txtPath, "wrap")
		])
		setResultConverter = [
			if(getButtonData() == ButtonData.OK_DONE) {
				return path.resolve(txtPath.getText())
			}
		]
	}

}
