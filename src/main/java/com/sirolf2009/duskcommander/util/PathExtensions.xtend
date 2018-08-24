package com.sirolf2009.duskcommander.util

import io.reactivex.Observable
import java.nio.file.Files
import java.nio.file.Path
import java.util.Comparator

class PathExtensions {
	
	def static list(Path path) {
		val stream = Files.newDirectoryStream(path)
		return Observable.fromIterable(stream).doOnComplete[
			stream.close()
		]
	}
	
	def static void delete(Path path) {
		if(path.isFile()) {
			Files.deleteIfExists(path)
		} else {
			Files.walk(path).sorted(Comparator.reverseOrder()).forEach[Files.deleteIfExists(path)]
		}
	}
	
	def static isFile(Path path) {
		return Files.isRegularFile(path)
	}
	
	def static getPosixFilePermissions(Path path) {
		return Files.getPosixFilePermissions(path)
	}
	
	def static getLastModifiedTime(Path path) {
		return Files.getLastModifiedTime(path).toMillis()
	}
	
	def static getName(Path path) {
		return path.getName(path.getNameCount() -1).toString()
	}
	
}