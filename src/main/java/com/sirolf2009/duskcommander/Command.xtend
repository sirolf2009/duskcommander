package com.sirolf2009.duskcommander

import java.lang.reflect.Field

class Command {
	
	override toString() {
		val clazz = this.getClass().asSubclass(this.getClass())
		val parameters = clazz.getDeclaredFields().map[it.getName()+"="+getValue()]
		return '''«clazz.getSimpleName()»(«parameters.join(", ")»)'''
	}
	
	def private getValue(Field field) {
		if(field.isAccessible()) {
			return field.get(this)
		} else {
			try {
				String.valueOf(field.getDeclaringClass().getMethod("get"+field.getName().toFirstUpper()).invoke(this))
			} catch(Exception e) {
				try {
					String.valueOf(field.getDeclaringClass().getMethod("is"+field.getName().toFirstUpper()))
				} catch(Exception e2) {
					return "?"
				}
			}
		}
	}
	
}