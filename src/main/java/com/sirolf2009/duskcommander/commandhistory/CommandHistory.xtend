package com.sirolf2009.duskcommander.commandhistory

import com.sirolf2009.duskcommander.DuskCommander
import com.sirolf2009.util.TimeUtil
import java.util.Date
import javafx.beans.property.SimpleStringProperty
import javafx.scene.control.TableColumn
import javafx.scene.control.TableRow
import javafx.scene.control.TableView
import javafx.scene.control.Tooltip

class CommandHistory extends TableView<Command> {

	new() {
		DuskCommander.eventBus.map[new Command(new Date(), it)].subscribe [
			getItems().add(it)
		]
		
		setRowFactory [
			return new TableRow<Command>() => [
				setOnMouseEntered = [evt|
					setTooltip = new Tooltip(getItem()?.toString())
				]
				setOnMouseClicked = [evt|
					if(evt.getClickCount() == 2 && !isEmpty()) {
						DuskCommander.eventBus.onNext(getItem()?.getCommand())
					}
				]
			]
		]
		
		getColumns().add(new TableColumn<Command, String>("Time") => [
			setCellValueFactory = [
				new SimpleStringProperty(TimeUtil.format(getValue()?.getTime()))
			]
		])
		
		getColumns().add(new TableColumn<Command, String>("Command") => [
			prefWidthProperty().set(200)
			setCellValueFactory = [
				new SimpleStringProperty(getValue()?.getCommand()?.toString())
			]
		])
	}
	
}