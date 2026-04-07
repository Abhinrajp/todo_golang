import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'getit_injection.config.dart';

final getit = GetIt.instance;

@InjectableInit(
  initializerName: 'init', // default
  preferRelativeImports: true, // default
  asExtension: true, // default
)
void configureDependencies() => getit.init();
