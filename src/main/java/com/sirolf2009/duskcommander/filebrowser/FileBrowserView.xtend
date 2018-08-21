package com.sirolf2009.duskcommander.filebrowser

import com.kodedu.terminalfx.Terminal
import com.kodedu.terminalfx.config.TerminalConfig
import com.sirolf2009.duskcommander.DuskCommander
import io.reactivex.Observable
import java.io.File
import java.nio.file.Files
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
import javafx.scene.paint.Color
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.Data
import org.tbee.javafx.scene.layout.MigPane

import static extension com.sirolf2009.duskcommander.util.RXExtensions.*

@Accessors class FileBrowserView extends SplitPane {

	val HBox commandElements
	val HBox pathElements
	val FileBrowser fileBrowser
	val Terminal terminal

	new() {
		this(new File("."))
	}

	new(File root) {
		setOrientation(Orientation.VERTICAL)
		fileBrowser = new FileBrowser()
		VBox.setVgrow(fileBrowser, Priority.ALWAYS)

		terminal = new Terminal()
		terminal.updatePrefs(new TerminalConfig() => [
			setUnixTerminalStarter("/usr/bin/fish")
			setBackgroundColor(Color.web("#002b36"))
			setForegroundColor(Color.web("#839496"))
			setCursorColor(Color.web("#93a1a1", 0.5d))
		])
		terminal.onTerminalFxReady[terminal.command("cd " + root + "\n")]

		pathElements = new HBox() => [
			getStyleClass().add("background")
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

		getItems().addAll(new VBox(debugPanel, commandElements, pathElements, fileBrowser), terminal)
		setDividerPositions(0.8)
		
		navigateTo(root).subscribe()
	}
	
	def hasFocusProperty() {
		return focusedProperty().or(fileBrowser.hasFocusProperty())
	}

	def navigateTo(File file) {
		val commands = Observable.just(file).platform().doOnNext [
			getCommands().clear()
			clearFilter()
		].computation().flatMap [
			Observable.fromArray(listFiles())
		].filter[isFile() && getName().equals(".duskcommander")].map [
			Files.lines(toPath()).filter[!startsWith("#")].map[split(":")].map [
				new ActionButton(terminal, get(0), (1 ..< size()).map[index|get(index)].reduce[a, b|a + b])
			].collect(Collectors.toList())
		].platform().doOnNext [
			getCommands().addAll(it)
		].single(#[]).toObservable()
		val buttons = Observable.just(file).platform().doOnNext [
			getButtons().clear()
			terminal.getOutputWriter()?.append("cd " + it + "\n")?.flush()
		].computation().map [
			val path = toPath()
			#[fileBrowserButton("/", "/")] + (0 ..< path.size()).map[
				path.get(it).toString() -> "/"+(0 .. it).map[
					path.get(it).toString()+"/"
				].reduce[a,b|a+b]
			].map[fileBrowserButton(key, value)]
		].map[toList()].platform().doOnNext [
			getButtons().addAll(it)
		]
		Observable.zip(fileBrowser.navigateTo(file), commands, buttons) [f, c, b|
			return new Setup(f, c, b)
		]
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

	def fileBrowserButton(String name, String path) {
		new PathButton(this, name, path)
	}

	@Data static class Setup {
		List<File> files
		List<ActionButton> commands
		List<PathButton> path
	}
}
