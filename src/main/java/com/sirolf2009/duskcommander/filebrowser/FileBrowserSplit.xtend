package com.sirolf2009.duskcommander.filebrowser

import com.sirolf2009.duskcommander.DuskCommander
import com.sirolf2009.duskcommander.filebrowser.dialog.CopyDialog
import com.sirolf2009.duskcommander.filebrowser.dialog.DeleteDialog
import com.sirolf2009.duskcommander.filebrowser.dialog.MoveDialog
import io.reactivex.Observable
import java.io.File
import java.util.Optional
import javafx.application.Platform
import javafx.scene.control.SplitPane
import javafx.scene.input.KeyCode
import javafx.scene.input.KeyEvent
import org.apache.commons.io.FileUtils
import org.eclipse.xtend.lib.annotations.Data

import static extension com.sirolf2009.duskcommander.util.RXExtensions.*

class FileBrowserSplit extends SplitPane {

	val FileBrowserView left
	val FileBrowserView right

	new() {
		left = new FileBrowserView(new File(System.getProperty("user.home")))
		right = new FileBrowserView(new File(System.getProperty("user.home")))
		getItems().addAll(left, right)

		DuskCommander.eventBus.type(NavigateTo).subscribe[getPrimary().navigateTo(getFile()).subscribe()]
		DuskCommander.eventBus.type(NavigateToInOther).subscribe[getSecundary().navigateTo(getFile()).subscribe()]
		DuskCommander.eventBus.type(SetSame).subscribe [
			getSecundary().pathProperty().set(getPrimary().pathProperty().get())
		]
		DuskCommander.eventBus.type(Open).subscribe [
			getPrimaryFile().ifPresent[getPrimary().navigateTo(it).subscribe()]
		]
		DuskCommander.eventBus.type(OpenInOther).subscribe [
			getPrimaryFile().ifPresent[getSecundary().navigateTo(it).subscribe()]
		]
		DuskCommander.eventBus.type(OpenInBoth).subscribe [
			getPrimaryFile().ifPresent [
				getPrimary().navigateTo(it).subscribe()
				getSecundary().navigateTo(it).subscribe()
			]
		]
		DuskCommander.eventBus.type(Ascend).subscribe [
			getPrimary().ascend()
		]
		DuskCommander.eventBus.type(AscendInOther).subscribe [
			getSecundary().ascend()
		]

		DuskCommander.eventBus.type(Refresh).subscribe [
			refresh().subscribe()
		]

		DuskCommander.eventBus.type(Copy).subscribe [
			getPrimaryFile().ifPresent [
				val destination = new File(getSecundary().pathProperty().get(), getName())
				new CopyDialog(it, destination).showAndWait().ifPresent [
					if(getKey().isFile() && getValue().isFile()) {
						FileUtils.copyFile(getKey(), getValue())
					} else if(getKey().isFile() && !getValue().isFile()) {
						FileUtils.copyFileToDirectory(getKey(), getValue())
					} else if(!getKey().isFile() && !getValue().isFile()) {
						FileUtils.copyDirectory(getKey(), getValue())
					}
					refresh().subscribe()
				]
			]
		]

		DuskCommander.eventBus.type(Move).subscribe [
			getPrimaryFile().ifPresent [
				val destination = new File(getSecundary().pathProperty().get(), getName())
				new MoveDialog(it, destination).showAndWait().ifPresent [
					if(getKey().isFile() && getValue().isFile()) {
						FileUtils.moveFile(getKey(), getValue())
					} else if(getKey().isFile() && !getValue().isFile()) {
						FileUtils.moveFileToDirectory(getKey(), getValue(), false)
					} else if(!getKey().isFile() && !getValue().isFile()) {
						FileUtils.moveDirectory(getKey(), getValue())
					}
					refresh().subscribe()
				]
			]
		]

		DuskCommander.eventBus.type(Delete).subscribe [
			getPrimaryFile().ifPresent [
				new DeleteDialog(it).showAndWait().ifPresent [
					if(isFile()) {
						delete()
					} else {
						FileUtils.deleteDirectory(it)
					}
					refresh().subscribe()
				]
			]
		]

		addEventFilter(KeyEvent.ANY) [
			if(getCode().isFunctionKey() || getCode() == KeyCode.DELETE) {
				consume()
			}
		]
		addEventFilter(KeyEvent.KEY_PRESSED) [
			if(getCode() == KeyCode.F1) {
				DuskCommander.eventBus.onNext(new Copy())
			} else if(getCode() == KeyCode.F2) {
				DuskCommander.eventBus.onNext(new Move())
			} else if(getCode() == KeyCode.F5) {
				DuskCommander.eventBus.onNext(new Refresh())
			} else if(getCode() == KeyCode.DELETE) {
				DuskCommander.eventBus.onNext(new Delete())
			}
		]
	}

	def ascend(FileBrowserView browser) {
		val current = browser.pathProperty().get()
		Optional.ofNullable(current.getParentFile()).ifPresent [
			browser.navigateTo(it).subscribe [ setup |
				browser.getFileBrowser() => [
					getSelectionModel().select(current)
					Platform.runLater [
						getTable().scrollTo(current)
					]
				]
			]
		]
	}

	def refresh() {
		Observable.concat(left.refresh(), right.refresh())
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
		} else if(fileBrowser.getFileBrowser().getTable().getItems().size() > 0) {
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

	@Data static class Refresh {
	}

	@Data static class Copy {
	}

	@Data static class Move {
	}

	@Data static class Delete {
	}

}
