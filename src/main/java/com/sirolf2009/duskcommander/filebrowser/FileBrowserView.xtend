package com.sirolf2009.duskcommander.filebrowser

import com.pastdev.jsch.nio.file.UnixSshFileSystem
import com.sirolf2009.duskcommander.DuskCommander
import com.sirolf2009.javafxterminal.Terminal
import io.reactivex.Observable
import java.nio.file.Files
import java.nio.file.Path
import java.util.List
import java.util.stream.Collectors
import javafx.geometry.Orientation
import javafx.scene.control.Label
import javafx.scene.control.SplitPane
import javafx.scene.input.KeyCode
import javafx.scene.input.KeyEvent
import javafx.scene.layout.HBox
import javafx.scene.layout.Priority
import javafx.scene.layout.VBox
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.Data
import org.tbee.javafx.scene.layout.MigPane

import static extension com.sirolf2009.duskcommander.util.PathExtensions.*
import static extension com.sirolf2009.duskcommander.util.RXExtensions.*
import com.sirolf2009.javafxterminal.theme.ThemeSolarizedDark
import javafx.scene.layout.StackPane

@Accessors class FileBrowserView extends SplitPane {

	val HBox pathElements
	val FileBrowser fileBrowser
	val HBox commandElements
	val Terminal terminal

	new(Path root) {
		setOrientation(Orientation.VERTICAL)
		fileBrowser = new FileBrowser()
		VBox.setVgrow(fileBrowser, Priority.ALWAYS)

		terminal = new Terminal(#["/usr/bin/fish"], new ThemeSolarizedDark())
		terminal.command("cd " + root + "\n")
		val terminalParent = new StackPane(terminal)
		terminal.widthProperty().bind(terminalParent.widthProperty())
		terminal.heightProperty().bind(terminalParent.heightProperty())
		VBox.setVgrow(terminalParent, Priority.ALWAYS)

		pathElements = new HBox() => [
			getStyleClass().addAll("background", "path-buttons")
		]
		commandElements = new HBox() => [
			getStyleClass().add("background")
		]

		addEventFilter(KeyEvent.KEY_PRESSED) [
			if(getCode().isDigitKey() && isControlDown()) {
				val index = #[KeyCode.DIGIT1, KeyCode.DIGIT2, KeyCode.DIGIT3, KeyCode.DIGIT4, KeyCode.DIGIT5, KeyCode.DIGIT6, KeyCode.DIGIT7, KeyCode.DIGIT8, KeyCode.DIGIT9, KeyCode.DIGIT0].indexOf(getCode())
				if(getCommands().size() > index) {
					(getCommands().get(index) as ActionButton).sendCommand()
				}
			}
		]

		val debugPanel = new MigPane("fillx", "[right]rel[grow,fill]", "[]10[]") => [
			getStyleClass().add("debug-panel")
			managedProperty().bind(DuskCommander.debugProperty)
			add(new Label("Path"))
			add(new Label() => [
				textProperty().bind(fileBrowser.getPathProperty().asString())
			], "wrap")
			add(new Label("Focused"))
			add(new Label() => [
				textProperty().bind(fileBrowser.hasFocusProperty().asString())
			])
		]

		getItems().addAll(new VBox(debugPanel, pathElements, fileBrowser), new VBox(commandElements, terminalParent))
		setDividerPositions(0.8)

		navigateTo(root).subscribe()
	}

	def hasFocusProperty() {
		return focusedProperty().or(fileBrowser.hasFocusProperty())
	}

	def refresh() {
		Observable.zip(fileBrowser.refresh, commands(fileBrowser.getPathProperty().get())) [ p, c |
			return new Refresh(p, c)
		]
	}

	def navigateTo(Path file) {
		Observable.zip(fileBrowser.navigateTo(file), commands(file), pathButtons(file)) [ p, c, b |
			return new Setup(p, c, b)
		]
	}

	def private pathButtons(Path file) {
		Observable.just(file).platform().doOnNext [
			getButtons().clear()
			if(getFileSystem() instanceof UnixSshFileSystem) {
				val uri = (getFileSystem() as UnixSshFileSystem).getUri()
				val user = uri.getUserInfo()
				val host = uri.getHost()
				terminal.command('''ssh «user»@«host»''' + "\n")
			} else {
				terminal.command("cd " + it + "\n")
			}
		].computation().map [ path |
			#[fileBrowserButton("/", path.resolve("/"))] + (0 ..< path.size()).map [
				path.get(it).toString() -> "/" + (0 .. it).map [
					path.get(it).toString() + "/"
				].reduce[a, b|a + b]
			].map[fileBrowserButton(key + "/", path.resolve(value))]
		].map[toList()].platform().doOnNext [
			getButtons().addAll(it)
		]
	}

	def private commands(Path file) {
		Observable.just(file).platform().doOnNext [
			getCommands().clear()
			clearFilter()
		].computation().flatMap [
			list()
		].filter [
			isFile() && getName().equals(".duskcommander")
		].map [
			Files.lines(it).filter[!startsWith("#")].map[split(":")].map [
				new ActionButton(terminal, get(0), (1 ..< size()).map[index|get(index)].reduce[a, b|a + ":" + b])
			].collect(Collectors.toList())
		].platform().doOnNext [
			getCommands().addAll(it)
		].single(#[]).toObservable()
	}

	def pathProperty() {
		return fileBrowser.getPathProperty()
	}

	def clearFilter() {
		filterText() => [
			unbind()
			set("")
		]
	}

	def filterText() {
		return fileBrowser.getFilterText()
	}

	def getCommands() {
		commandElements.getChildren()
	}

	def getButtons() {
		pathElements.getChildren()
	}

	def fileBrowserButton(String name, Path path) {
		new PathButton(this, name, path)
	}

	@Data static class Setup {
		List<Path> files
		List<ActionButton> commands
		List<PathButton> path
	}

	@Data static class Refresh {
		List<Path> files
		List<ActionButton> commands
	}
}
