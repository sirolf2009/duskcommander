package com.sirolf2009.duskcommander.plugin

import com.pastdev.jsch.DefaultSessionFactory
import com.sirolf2009.duskcommander.DuskCommander
import com.sirolf2009.duskcommander.extensionpoint.FileSystemExtensionPoint
import com.sirolf2009.duskcommander.filebrowser.FileBrowserSplit.NavigateTo
import com.sirolf2009.duskcommander.jsch.filesystem.dialog.ConnectionDialog
import java.net.URI
import java.nio.file.FileSystem
import java.nio.file.FileSystems
import java.util.HashMap
import javafx.collections.FXCollections
import javafx.collections.ObservableMap
import javafx.scene.control.MenuItem
import org.pf4j.Extension

import static extension com.sirolf2009.duskcommander.util.RXExtensions.*

@Extension
class SSHFileSystemPlugin implements FileSystemExtensionPoint {
	
	public static val ObservableMap<URI, FileSystem> fileSystemMap = FXCollections.observableHashMap()
	
	override getMenuItem() {
		return new MenuItem("SSH") => [
				onAction = [
					new ConnectionDialog().showAndWait().fromOptional().io().map [
						val uri = new URI('''ssh.unix://«user»@«host»:22/''');
						if(fileSystemMap.containsKey(uri)) {
							fileSystemMap.get(uri)
						} else {
							val factory = new DefaultSessionFactory(getUser(), getHost(), getPort())
							factory.setKnownHosts(getKnownHosts())
							factory.setIdentityFromPrivateKey(getPrivateKey())

							val environment = new HashMap<String, Object>()
							environment.put("defaultSessionFactory", factory)
							fileSystemMap.put(uri, FileSystems.newFileSystem(uri, environment))
							fileSystemMap.get(uri)
						}
					].subscribe [
						DuskCommander.eventBus.onNext(new NavigateTo(rootDirectories.get(0)))
					]
				]
			]
	}
	
}