package com.sirolf2009.duskcommander.file

import java.io.File
import org.eclipse.xtend.lib.annotations.Data
import java.io.IOException
import java.nio.file.Files

@Data class NativeFile implements IFile {
	
	val File file
	
	override getName() {
		return file.getName()
	}
	
	override canWrite() {
		return file.canWrite()
	}
	
	override canRead() {
		return file.canRead()
	}
	
	override getAbsolutePath() {
		return file.getAbsolutePath()
	}
	
	override isDirectory() {
		return file.isDirectory()
	}
	
	override isFile() {
		return file.isFile()
	}
	
	override delete() throws IOException {
		Files.delete(file.toPath())
	}
	
}