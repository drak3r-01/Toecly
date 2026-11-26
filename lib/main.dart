import 'package:material_ui/material_ui.dart';

import 'app/app_services.dart';
import 'app/toecly_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final services = await AppServices.create();
  runApp(ToeclyApp(services: services));
}
