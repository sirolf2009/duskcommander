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
			getPrimaryFile().ifPresent[getPrimary().navigateTo(it)]
		]
		DuskCommander.eventBus.type(OpenInOther).subscribe [
			getPrimaryFile().ifPresent[getSecundary().navigateTo(it)]
		]
		DuskCommander.eventBus.type(OpenInBoth).subscribe [
			getPrimaryFile().ifPresent [
				getPrimary().navigateTo(it)
				getSecundary().navigateTo(it)
			]
		]
		DuskCommander.eventBus.type(Ascend).subscribe [
			Optional.ofNullable(getPrimary().pathProperty().get().getParentFile()).ifPresent[getPrimary().navigateTo(it)]
		]
		DuskCommander.eventBus.type(AscendInOther).subscribe [
			Optional.ofNullable(getPrimary().pathProperty().get().getParentFile()).ifPresent[getSecundary().navigateTo(it)]
		]
	}

	def getPrimaryFile() {
		return getPrimary().getFile()
	}

	def getSecundaryFile() {
		return getSecundary().getFile()
	}
	
	def getFile(FileBrowserView fileBrowser) {
		if(fileBrowser.getFileBrowser().getSelectionModel().getSelectedItem() !== null) {
			return Optional.of(fileBrowser.getFileBrowser().getSelectionModel().getSelectedItem())
		} else if (fileBrowser.getFileBrowser().getTable().getItems().size() > 0) {
			return Optional.of(fileBrowser.getFileBrowser().getTable().getItems().get(0))
		} else {
			return Optional.empty()
		}
	}

	def getPrimary() {
		if(left.hasFocusProperty().get()) {
			return left
		}
		if(right.hasFocusProperty().get()) {
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
