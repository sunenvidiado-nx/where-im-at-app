import 'package:envied/envied.dart';
import 'package:injectable/injectable.dart';
import 'package:where_im_at/config/environment/env.dart';

part 'env_prod.g.dart';

@Singleton(as: Env)
@Envied(path: '.env', useConstantCase: true, obfuscate: true)
class EnvProd implements Env {
  @override
  @EnviedField()
  final String stadiaMapsApiKey = _EnvProd.stadiaMapsApiKey;

  @override
  @EnviedField()
  final String geocodingApiKey = _EnvProd.geocodingApiKey;
}
