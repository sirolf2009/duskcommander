package com.sirolf2009.duskcommander.file

import java.io.IOException

interface IFile {
	
	def String getName()
	def boolean canWrite()
	def boolean canRead()
	def String getAbsolutePath()
	def boolean isDirectory()
	def boolean isFile()
	def void delete() throws IOException
	
}