package com.sirolf2009.duskcommander.filebrowser

import com.sirolf2009.duskcommander.Command
import com.sirolf2009.duskcommander.DuskCommander
import com.sirolf2009.duskcommander.filebrowser.dialog.CopyDialog
import com.sirolf2009.duskcommander.filebrowser.dialog.DeleteDialog
import com.sirolf2009.duskcommander.filebrowser.dialog.MoveDialog
import io.reactivex.Observable
import java.nio.file.Files
import java.nio.file.Path
import java.nio.file.Paths
import java.util.Optional
import javafx.application.Platform
import javafx.scene.control.SplitPane
import javafx.scene.input.KeyCode
import javafx.scene.input.KeyEvent
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor

import static extension com.sirolf2009.duskcommander.util.PathExtensions.*
import static extension com.sirolf2009.duskcommander.util.RXExtensions.*
import org.eclipse.xtend.lib.annotations.Data

class FileBrowserSplit extends SplitPane {

	val FileBrowserView left
	val FileBrowserView right

	new() {
		left = new FileBrowserView(Paths.get(System.getProperty("user.home")))
		right = new FileBrowserView(Paths.get(System.getProperty("user.home")))
		getItems().addAll(left, right)

		DuskCommander.eventBus.type(ToggleSecundary).subscribe [
			if(getItems().contains(getSecundary())) {
				getItems().remove(getSecundary())
			} else {
				getItems().add(getSecundary())
			}
		]
		DuskCommander.eventBus.type(NavigateTo).subscribe[getPrimary().navigateTo(getPath()).subscribe()]
		DuskCommander.eventBus.type(NavigateToInOther).subscribe[getSecundary().navigateTo(getPath()).subscribe()]
		DuskCommander.eventBus.type(SetSame).subscribe [
			getSecundary().navigateTo(getPrimary().pathProperty().get()).subscribe()
		]
		DuskCommander.eventBus.type(Swap).subscribe [
			val secundary = getSecundary().pathProperty().get()
			getSecundary().navigateTo(getPrimary().pathProperty().get()).subscribe()
			getPrimary().navigateTo(secundary).subscribe()
		]
		DuskCommander.eventBus.type(Open).subscribe [
			getPrimaryFile().ifPresent [
				if(isFile()) {
					getPrimary().getTerminal().command('''xdg-open «toAbsolutePath()»''' + "\n")
				} else {
					getPrimary().navigateTo(it).subscribe()
				}
			]
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

		DuskCommander.eventBus.type(Copy).getPrimaryFile().subscribe [
			val destination = getSecundary().pathProperty().get().resolve(getName())
			val dialogResult = new CopyDialog(it, destination).showAndWait()
			dialogResult.fromOptional().doOnNext [
				Files.copy(getKey(), getValue()) // TODO CopyOption in dialog
			].subscribe [
				refresh().subscribe()
			]
		]

		DuskCommander.eventBus.type(Move).getPrimaryFile().subscribe [
			val destination = getSecundary().pathProperty().get().resolve(getName())
			val dialogResult = new MoveDialog(it, destination).showAndWait()
			dialogResult.fromOptional().doOnNext [
				Files.move(getKey(), getValue()) // TODO CopyOption in dialog
			].subscribe [
				refresh().subscribe()
			]
		]

		DuskCommander.eventBus.type(Delete).getPrimaryFile().subscribe [
			val dialogResult = new DeleteDialog(it).showAndWait()
			dialogResult.fromOptional().doOnNext [
				delete()
			].subscribe [
				refresh().subscribe()
			]
		]

		DuskCommander.eventBus.type(ExecutePrimary).subscribe [
			getPrimary().getTerminal().command(command)
		]

		DuskCommander.eventBus.type(ExecuteSecundary).subscribe [
			getSecundary().getTerminal().command(command)
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
		Optional.ofNullable(current.getParent()).ifPresent [
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

	def getPrimaryFile(Observable<?> obs) {
		return obs.map[getPrimaryFile()].filter[isPresent()].map[get()]
	}

	def getPrimaryFile() {
		return getPrimary().getFile()
	}

	def getSecundaryFile(Observable<?> obs) {
		return obs.map[getSecundaryFile()].filter[isPresent()].map[get()]
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

	static class ToggleSecundary extends Command {
	}

	@FinalFieldsConstructor @Accessors static class NavigateTo extends Command {
		val Path path
	}

	@FinalFieldsConstructor @Accessors static class NavigateToInOther extends Command {
		val Path path
	}

	static class SetSame extends Command {
	}

	static class Swap extends Command {
	}

	static class Open extends Command {
	}

	static class OpenInOther extends Command {
	}

	static class OpenInBoth extends Command {
	}

	static class Ascend extends Command {
	}

	static class AscendInOther extends Command {
	}

	static class Refresh extends Command {
	}

	static class Copy extends Command {
	}

	static class Move extends Command {
	}

	static class Delete extends Command {
	}

	@Data static class ExecutePrimary extends Command {
		val String command
	}

	@Data static class ExecuteSecundary extends Command {
		val String command
	}

}
