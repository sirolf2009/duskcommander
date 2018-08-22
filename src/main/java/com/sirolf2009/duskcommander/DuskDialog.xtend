package com.sirolf2009.duskcommander

import javafx.scene.control.Dialog
import org.tbee.javafx.scene.layout.MigPane

class DuskDialog<T> extends Dialog<T> {
	
	new() {
		getDialogPane().getStylesheets().add("/application.css")
		getDialogPane().getStyleClass().add("dialog")
		getDialogPane().getStyleClass().add("copy-dialog")
		getDialogPane().setPrefSize(500, 200)
	}
	
	def formMigLayout() {
		new MigPane("fillx", "[right]rel[grow,fill]", "[]2[]")
	}
	
}