package com.sirolf2009.duskcommander

import javafx.scene.control.Dialog
import org.tbee.javafx.scene.layout.MigPane
import javafx.scene.control.TextFormatter
import javafx.scene.control.TextField

class DuskDialog<T> extends Dialog<T> {

	new() {
		getDialogPane().getStylesheets().add("/application.css")
		getDialogPane().getStyleClass().add("dialog")
		getDialogPane().getStyleClass().add("copy-dialog")
		getDialogPane().setPrefSize(500, 200)
	}

	def numberField(String content) {
		val textFormatter = new TextFormatter [
			if(getText().matches("[0-9]")) {
				return it
			}
			return null
		]
		return new TextField(content) =>[
			setTextFormatter(textFormatter)
		]
	}

	def formMigLayout() {
		new MigPane("fillx", "[right]rel[grow,fill]", "[]2[]")
	}

}
