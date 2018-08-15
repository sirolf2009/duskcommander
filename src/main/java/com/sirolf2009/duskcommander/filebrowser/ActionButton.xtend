package com.sirolf2009.duskcommander.filebrowser

import com.kodedu.terminalfx.Terminal
import javafx.scene.control.Button

import static io.reactivex.rxjavafx.observables.JavaFxObservable.*

import static extension com.sirolf2009.duskcommander.util.RXExtensions.*

class ActionButton extends Button {

	val Terminal terminal
	val String command

	new(Terminal terminal, String text, String command) {
		this.terminal = terminal
		this.command = command
		setText(text)
		actionEventsOf(this).platform().subscribe [
			sendCommand()
		]
	}

	def void sendCommand() {
		terminal.command(command + "\n")
	}

}
