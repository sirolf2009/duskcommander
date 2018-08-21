package com.sirolf2009.duskcommander.filebrowser

import com.sirolf2009.duskcommander.DuskCommander
import io.reactivex.Observable
import io.reactivex.rxjavafx.schedulers.JavaFxScheduler
import java.io.File
import java.nio.file.Files
import java.nio.file.attribute.PosixFilePermissions
import java.util.Date
import java.util.Optional
import javafx.beans.property.SimpleObjectProperty
import javafx.beans.property.SimpleStringProperty
import javafx.collections.FXCollections
import javafx.collections.transformation.FilteredList
import javafx.scene.Node
import javafx.scene.control.TableCell
import javafx.scene.control.TableColumn
import javafx.scene.control.TableView
import javafx.scene.control.TextField
import javafx.scene.image.Image
import javafx.scene.image.ImageView
import javafx.scene.input.KeyCode
import javafx.scene.input.KeyEvent
import javafx.scene.layout.AnchorPane
import org.eclipse.xtend.lib.annotations.Accessors

import static extension com.sirolf2009.duskcommander.util.RXExtensions.*
import static extension com.sirolf2009.util.LongExtensions.*
import static extension com.sirolf2009.util.TimeUtil.*;

@Accessors class FileBrowser extends AnchorPane {

	val pathProperty = new SimpleObjectProperty<File>()
	val filterText = new SimpleStringProperty("")
	val TableView<File> table

	new() {
		getStyleClass().add("background")
		table = new TableView<File>()
		table.setItems(FXCollections.emptyObservableList())
		getChildren().add(table)
		table.maximize()
		table.getColumns().add(new TableColumn<File, File>("Type") => [
			prefWidthProperty().bind(table.widthProperty().multiply(0.08))
			setCellValueFactory = [
				new SimpleObjectProperty(getValue())
			]
			setCellFactory = [
				return new TableCell<File, File>() {
					override protected updateItem(File item, boolean empty) {
						super.updateItem(item, empty)
						if(item === null || empty) {
							setGraphic(null)
						} else {
							val image = if(item.isFile()) {
									new Image(FileBrowser.getResourceAsStream("/file.png"))
								} else {
									new Image(FileBrowser.getResourceAsStream("/folder.png"))
								}
							setGraphic(new ImageView(image) => [
								setFitWidth(24)
								setFitHeight(24)
							])
						}
					}
				}
			]
		])
		table.getColumns().add(new TableColumn<File, String>("Name") => [
			prefWidthProperty().bind(table.widthProperty().multiply(0.6))
			setCellValueFactory = [
				new SimpleStringProperty(getValue()?.getName())
			]
		])
		table.getColumns().add(new TableColumn<File, String>("Size") => [
			prefWidthProperty().bind(table.widthProperty().multiply(0.1))
			setCellValueFactory = [
				new SimpleStringProperty(Optional.ofNullable(getValue()).map [
					if(isFile()) {
						return length().humanReadableByteCount()
					}
				].orElse(null))
			]
		])
		table.getColumns().add(new TableColumn<File, String>("Time") => [
			prefWidthProperty().bind(table.widthProperty().multiply(0.1))
			setCellValueFactory = [
				new SimpleStringProperty(Optional.ofNullable(getValue()).map [
					return new Date(lastModified()).format()
				].orElse(null))
			]
		])
		table.getColumns().add(new TableColumn<File, String>("Permissions") => [
			prefWidthProperty().bind(table.widthProperty().multiply(0.12))
			setCellValueFactory = [
				new SimpleStringProperty(Optional.ofNullable(getValue()).map [
					try {
						Files.getPosixFilePermissions(toPath())
					} catch(Exception e) {
						return null
					}
				].filter[it !== null].map[PosixFilePermissions.toString(it)].orElse(null))
			]
		])

		addEventFilter(KeyEvent.ANY) [
			if(#[KeyCode.RIGHT, KeyCode.LEFT].contains(getCode())) {
				consume()
			}
		]
		addEventFilter(KeyEvent.KEY_RELEASED) [
			switch (getCode()) {
				case KeyCode.ENTER,
				case KeyCode.RIGHT: {
					table.requestFocus()
					val selected = Optional.ofNullable(table.getSelectionModel().getSelectedItem()).orElse(table.getItems().get(0))
					if(!selected.isFile()) {
						DuskCommander.eventBus.onNext(new FileBrowserSplit.Open())
					}
				}
				case KeyCode.LEFT: {
					table.requestFocus()
					DuskCommander.eventBus.onNext(new FileBrowserSplit.Ascend())
				}
				case KeyCode.DOWN: {
					if(!table.focused) {
						table.getSelectionModel().select(0)
					}
					table.requestFocus()
				}
				default: {
					if(getCode().isLetterKey()) {
						if(filterText.get().isEmpty()) {
							val textField = new TextField(getText())
							filterText.bind(textField.textProperty())
							filterText.addListener [ obs, oldVal, newVal |
								if(newVal.isNullOrEmpty()) {
									getChildren().remove(textField)
									filterText.unbind()
									(table.getItems() as FilteredList<File>).setPredicate [
										true
									]
									table.requestFocus()
								} else {
									(table.getItems() as FilteredList<File>).setPredicate [
										getName().toLowerCase().startsWith(filterText.get().toLowerCase())
									]
								}
							]
							(table.getItems() as FilteredList<File>).setPredicate [
								getName().toLowerCase().startsWith(filterText.get().toLowerCase())
							]
							AnchorPane.setTopAnchor(textField, 0d)
							AnchorPane.setRightAnchor(textField, 0d)
							getChildren().add(textField)
							textField.requestFocus()
							textField.positionCaret(1)
						}
					}
				}
			}
		]
	}

	def navigateTo(File file) {
		Observable.just(file).io().map [
			listFiles().filter[!isHidden()]
		].map [
			sortBy[getName()]
		].observeOn(JavaFxScheduler.platform()).doOnNext [
			filterText.unbind()
			filterText.set("")
			table.setItems(new FilteredList(FXCollections.observableArrayList(it)))
			table.getSelectionModel().select(0)
			table.scrollTo(0)
			pathProperty.set(file)
		]
	}

	def hasFocusProperty() {
		return focusedProperty().or(table.focusedProperty())
	}

	def getSelectionModel() {
		return table.getSelectionModel()
	}

	def maximize(Node node) {
		AnchorPane.setTopAnchor(node, 0d)
		AnchorPane.setRightAnchor(node, 0d)
		AnchorPane.setBottomAnchor(node, 0d)
		AnchorPane.setLeftAnchor(node, 0d)
	}

}
