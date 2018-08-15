package com.sirolf2009.duskcommander.util;

import com.google.common.base.Objects;
import io.reactivex.Observable;
import io.reactivex.Single;
import io.reactivex.functions.Predicate;
import io.reactivex.rxjavafx.schedulers.JavaFxScheduler;
import io.reactivex.schedulers.Schedulers;

@SuppressWarnings("all")
public class RXExtensions {
  public static <T extends Object> Observable<T> type(final Observable<?> observable, final Class<T> type) {
    final Predicate<Object> _function = (Object it) -> {
      Class<?> _class = it.getClass();
      return Objects.equal(_class, type);
    };
    return observable.filter(_function).<T>cast(type);
  }
  
  public static <T extends Object> Observable<T> io(final Observable<T> obs) {
    return obs.observeOn(Schedulers.io());
  }
  
  public static <T extends Object> Observable<T> computation(final Observable<T> obs) {
    return obs.observeOn(Schedulers.computation());
  }
  
  public static <T extends Object> Observable<T> platform(final Observable<T> obs) {
    return obs.observeOn(JavaFxScheduler.platform());
  }
  
  public static <T extends Object> Single<T> io(final Single<T> obs) {
    return obs.observeOn(Schedulers.io());
  }
  
  public static <T extends Object> Single<T> computation(final Single<T> obs) {
    return obs.observeOn(Schedulers.computation());
  }
  
  public static <T extends Object> Single<T> platform(final Single<T> obs) {
    return obs.observeOn(JavaFxScheduler.platform());
  }
}
