package com.sirolf2009.duskcommander.commandhistory

import java.util.Date
import org.eclipse.xtend.lib.annotations.Data

@Data class Command {
	
	val Date time
	val Object command
	
}