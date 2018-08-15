package com.sirolf2009.duskcommander.filebrowser

import com.sirolf2009.duskcommander.DuskCommander
import java.io.File
import java.util.Optional
import javafx.scene.control.SplitPane
import org.eclipse.xtend.lib.annotations.Data

import static extension com.sirolf2009.duskcommander.util.RXExtensions.*

class FileBrowserSplit extends SplitPane {

	val FileBrowserView left
	val FileBrowserView right

	new() {
		left = new FileBrowserView(new File(System.getProperty("user.home")))
		right = new FileBrowserView(new File(System.getProperty("user.home")))
		getItems().addAll(left, right)

		DuskCommander.eventBus.type(NavigateTo).subscribe[getPrimary().pathProperty().set(getFile())]
		DuskCommander.eventBus.type(NavigateToInOther).subscribe[getSecundary().pathProperty().set(getFile())]
		DuskCommander.eventBus.type(SetSame).subscribe [
			getSecundary().pathProperty().set(getPrimary().pathProperty().get())
		]
		DuskCommander.eventBus.type(Open).subscribe [
			getPrimaryFile().ifPresent[getPrimary().pathProperty().set(it)]
		]
		DuskCommander.eventBus.type(OpenInOther).subscribe [
			getPrimaryFile().ifPresent[getSecundary().pathProperty().set(it)]
		]
		DuskCommander.eventBus.type(OpenInBoth).subscribe [
			getPrimaryFile().ifPresent [
				getPrimary().pathProperty().set(it)
				getSecundary().pathProperty().set(it)
			]
		]
		DuskCommander.eventBus.type(Ascend).subscribe [
			Optional.ofNullable(getPrimary().pathProperty().get().getParentFile()).ifPresent[getPrimary().pathProperty().set(it)]
		]
		DuskCommander.eventBus.type(AscendInOther).subscribe [
			Optional.ofNullable(getPrimary().pathProperty().get().getParentFile()).ifPresent[getSecundary().pathProperty().set(it)]
		]
	}

	def getPrimaryFile() {
		return Optional.ofNullable(getPrimary().getFileBrowser().getSelectionModel().getSelectedItem())
	}

	def getSecundaryFile() {
		return Optional.ofNullable(getSecundary().getFileBrowser().getSelectionModel().getSelectedItem())
	}

	def getPrimary() {
		if(left.isFocused() || left.getFileBrowser().isFocused()) {
			return left
		}
		if(right.isFocused() || right.fileBrowser.isFocused()) {
			return right
		}
		return left
	}

	def getSecundary() {
		if(getPrimary() == left) {
			return right
		}
		return left
	}

	@Data static class NavigateTo {
		val File file
	}

	@Data static class NavigateToInOther {
		val File file
	}

	@Data static class SetSame {
	}

	@Data static class Open {
	}

	@Data static class OpenInOther {
	}

	@Data static class OpenInBoth {
	}

	@Data static class Ascend {
	}

	@Data static class AscendInOther {
	}

}
