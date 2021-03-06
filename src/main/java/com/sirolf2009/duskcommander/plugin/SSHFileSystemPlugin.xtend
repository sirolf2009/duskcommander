package com.sirolf2009.duskcommander.plugin

import com.sirolf2009.duskcommander.DuskCommander
import com.sirolf2009.duskcommander.DuskDialog
import com.sirolf2009.duskcommander.extensionpoint.FileSystemExtensionPoint
import com.sirolf2009.duskcommander.filebrowser.FileBrowserSplit.ExecutePrimary
import com.sirolf2009.duskcommander.filebrowser.FileBrowserSplit.NavigateTo
import com.sirolf2009.sshfs.SSHFileSystem
import java.net.URI
import java.nio.file.FileSystem
import java.nio.file.FileSystems
import javafx.collections.FXCollections
import javafx.collections.ObservableMap
import javafx.scene.control.ButtonBar.ButtonData
import javafx.scene.control.ButtonType
import javafx.scene.control.Label
import javafx.scene.control.MenuItem
import javafx.scene.control.TextField
import org.eclipse.xtend.lib.annotations.Data
import org.pf4j.Extension

import static extension com.sirolf2009.duskcommander.util.RXExtensions.*

@Extension
class SSHFileSystemPlugin implements FileSystemExtensionPoint {

	public static val ObservableMap<URI, FileSystem> fileSystemMap = FXCollections.observableHashMap()

	override getMenuItem() {
		return new MenuItem("SSH") => [
			onAction = [
				new ConnectionDialog().showAndWait().fromOptional().io().doOnNext[
					DuskCommander.eventBus.onNext(new ExecutePrimary('''ssh «user»@«host»'''+"\n"))
				].map [
					val uri = new URI('''ssh://«user»@«host»:22''');
					if(fileSystemMap.containsKey(uri)) {
						fileSystemMap.get(uri)
					} else {
						val env = #{
							SSHFileSystem.CONFIG_KNOWN_HOSTS -> getKnownHosts(),
							SSHFileSystem.CONFIG_IDENTITY -> getPrivateKey()
						}
						fileSystemMap.put(uri, FileSystems.newFileSystem(uri, env))
						fileSystemMap.get(uri)
					}
				].subscribe [
					DuskCommander.eventBus.onNext(new NavigateTo(rootDirectories.get(0)))
				]
			]
		]
	}

	static class ConnectionDialog extends DuskDialog<JschConnectionDetails> {

		val TextField txtUser
		val TextField txtHost
		val TextField txtPort
		val TextField txtKnownHosts
		val TextField txtPrivateKey

		new() {
			setTitle("Connection Dialog")
			getDialogPane().getButtonTypes().addAll(ButtonType.OK, ButtonType.CANCEL)
			txtUser = new TextField(System.getProperty("user.name"))
			txtHost = new TextField()
			txtPort = numberField("22")
			txtKnownHosts = new TextField(System.getProperty("user.home") + "/.ssh/known_hosts")
			txtPrivateKey = new TextField(System.getProperty("user.home") + "/.ssh/id_rsa")
			getDialogPane().setContent(formMigLayout() => [
				add(new Label("Username"))
				add(txtUser, "wrap")
				add(new Label("Host"))
				add(txtHost, "wrap")
				add(new Label("Port"))
				add(txtPort, "wrap")
				add(new Label("Known Hosts"))
				add(txtKnownHosts, "wrap")
				add(new Label("Private Key"))
				add(txtPrivateKey)
			])

			txtHost.requestFocus()

			setResultConverter = [
				if(getButtonData() == ButtonData.OK_DONE) {
					return new JschConnectionDetails(txtUser.getText(), txtHost.getText(), Integer.parseInt(txtPort.getText()), txtKnownHosts.getText(), txtPrivateKey.getText())
				}
			]
		}

	}

	@Data static class JschConnectionDetails {
		val String user
		val String host
		val int port
		val String knownHosts
		val String privateKey
	}

}
