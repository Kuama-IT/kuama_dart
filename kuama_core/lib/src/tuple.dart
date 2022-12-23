import 'dart:async';

import 'package:tuple/tuple.dart';

extension Tuple2FutureKuamaExtension<I1, I2> on Tuple2<FutureOr<I1>, FutureOr<I2>> {
  Future<Tuple2<I1, I2>> get done async => Tuple2(await $0, await $1);
}

extension Tuple3FutureKuamaExtension<I1, I2, I3>
    on Tuple3<FutureOr<I1>, FutureOr<I2>, FutureOr<I3>> {
  Future<Tuple3<I1, I2, I3>> get done async => Tuple3(await $0, await $1, await $2);
}

extension Tuple4FutureKuamaExtension<I1, I2, I3, I4>
    on Tuple4<FutureOr<I1>, FutureOr<I2>, FutureOr<I3>, FutureOr<I4>> {
  Future<Tuple4<I1, I2, I3, I4>> get done async => Tuple4(await $0, await $1, await $2, await $3);
}

extension Tuple5FutureKuamaExtension<I1, I2, I3, I4, I5>
    on Tuple5<FutureOr<I1>, FutureOr<I2>, FutureOr<I3>, FutureOr<I4>, FutureOr<I5>> {
  Future<Tuple5<I1, I2, I3, I4, I5>> get done async =>
      Tuple5(await $0, await $1, await $2, await $3, await $4);
}

/// Extensions methods for future support to records feature
/// https://github.com/dart-lang/language/blob/master/accepted/future-releases/records/records-feature-specification.md

extension Tuple2KuamaExtension<I1, I2> on Tuple2<I1, I2> {
  I1 get $0 => item1;
  I2 get $1 => item2;
}

extension Tuple3KuamaExtension<I1, I2, I3> on Tuple3<I1, I2, I3> {
  I1 get $0 => item1;
  I2 get $1 => item2;
  I3 get $2 => item3;
}

extension Tuple4KuamaExtension<I1, I2, I3, I4> on Tuple4<I1, I2, I3, I4> {
  I1 get $0 => item1;
  I2 get $1 => item2;
  I3 get $2 => item3;
  I4 get $3 => item4;
}

extension Tuple5KuamaExtension<I1, I2, I3, I4, I5> on Tuple5<I1, I2, I3, I4, I5> {
  I1 get $0 => item1;
  I2 get $1 => item2;
  I3 get $2 => item3;
  I4 get $3 => item4;
  I5 get $4 => item5;
}
