package com.sirolf2009.duskcommander.extensionpoint

import org.pf4j.ExtensionPoint
import javafx.scene.control.MenuItem

interface FileExtensionPoint extends ExtensionPoint {
	
	def MenuItem getMenuItem()
	
}