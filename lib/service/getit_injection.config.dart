// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../provider/todo_provider.dart' as _i291;
import '../repo/todo_repo.dart' as _i84;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.lazySingleton<_i84.ItodoRepo>(() => _i84.TodoRepo());
    gh.lazySingleton<_i291.TodoProvider>(
      () => _i291.TodoProvider(gh<_i84.ItodoRepo>()),
    );
    return this;
  }
}
