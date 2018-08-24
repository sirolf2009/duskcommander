package com.sirolf2009.duskcommander.filebrowser

import java.io.File
import javafx.beans.value.ObservableValue

interface IBrowser {
	
	def File getSelectedItem()
	def ObservableValue<Boolean> hasFocusProperty()
	def ObservableValue<?> navigateTo(File file)
	
}