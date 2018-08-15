package com.sirolf2009.duskcommander.util

import io.reactivex.Observable
import io.reactivex.schedulers.Schedulers
import io.reactivex.rxjavafx.schedulers.JavaFxScheduler
import io.reactivex.Single

class RXExtensions {
	
	def static <T> type(Observable<?> observable, Class<T> type) {
//		return observable.filter[type.isAssignableFrom(getClass())].cast(type)
		return observable.filter[getClass() == type].cast(type)
	}
	
	def static <T> io(Observable<T> obs) {
		return obs.observeOn(Schedulers.io)
	}
	
	def static <T> computation(Observable<T> obs) {
		return obs.observeOn(Schedulers.computation)
	}
	
	def static <T> platform(Observable<T> obs) {
		return obs.observeOn(JavaFxScheduler.platform())
	}
	
	def static <T> io(Single<T> obs) {
		return obs.observeOn(Schedulers.io)
	}
	
	def static <T> computation(Single<T> obs) {
		return obs.observeOn(Schedulers.computation)
	}
	
	def static <T> platform(Single<T> obs) {
		return obs.observeOn(JavaFxScheduler.platform())
	}
	
}