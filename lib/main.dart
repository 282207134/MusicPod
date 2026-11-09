import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';
import 'core/controller.dart';
import 'core/live_controller.dart';
import 'services/config.dart';
import 'services/catalog_service.dart';
import 'services/library_cloud.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xff0e0e0e),
    ),
  );
  const config = ServiceConfig.environment;
  LibraryCloud? cloud;
  String? startupError;
  if (!ServiceConfig.demo && config.hasSupabase) {
    try {
      await Supabase.initialize(
        url: config.supabaseUrl,
        publishableKey: config.supabaseKey,
        debug: false,
      );
      cloud = SupabaseLibraryCloud(Supabase.instance.client, config);
    } catch (_) {
      startupError =
          'Account service could not start. Check your connection and Supabase configuration, then restart.';
    }
  }
  final AppController controller = ServiceConfig.demo
      ? AppController()
      : (LiveController(catalog: CatalogService(config), cloud: cloud)
          ..startupError = startupError);
  await controller.restore();
  await controller.restoreInterfaceLanguage();
  await controller.restoreContentLanguages();
  runApp(MusicPodApp(controller: controller));
  if (controller is LiveController) controller.start();
}
