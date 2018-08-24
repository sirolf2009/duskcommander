package com.sirolf2009.duskcommander.jsch.filesystem.dialog

import com.sirolf2009.duskcommander.DuskDialog
import org.eclipse.xtend.lib.annotations.Data
import com.sirolf2009.duskcommander.jsch.filesystem.dialog.ConnectionDialog.JschConnectionDetails
import javafx.scene.control.ButtonType
import javafx.scene.control.TextField
import javafx.scene.control.Label
import javafx.scene.control.ButtonBar.ButtonData

class ConnectionDialog extends DuskDialog<JschConnectionDetails> {
	
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
		txtKnownHosts = new TextField(System.getProperty("user.home")+"/.ssh/known_hosts")
		txtPrivateKey = new TextField(System.getProperty("user.home")+"/.ssh/id_rsa")
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
	
	@Data static class JschConnectionDetails {
		val String user
		val String host
		val int port
		val String knownHosts
		val String privateKey
	}
	
}