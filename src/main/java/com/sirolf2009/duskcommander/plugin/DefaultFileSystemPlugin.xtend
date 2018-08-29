package com.sirolf2009.duskcommander.plugin

import com.sirolf2009.duskcommander.DuskCommander
import com.sirolf2009.duskcommander.extensionpoint.FileSystemExtensionPoint
import com.sirolf2009.duskcommander.filebrowser.FileBrowserSplit.NavigateTo
import java.nio.file.Paths
import javafx.scene.control.MenuItem

class DefaultFileSystemPlugin implements FileSystemExtensionPoint {

	override getMenuItem() {
		return new MenuItem("Local") => [
			onAction = [
				DuskCommander.eventBus.onNext(new NavigateTo(Paths.get(System.getProperty("user.home"))))
			]
		]
	}

}
