import 'package:shelf_router/shelf_router.dart';
import '../controllers/match_controller.dart';

Router get matchRoutes {
  final router = Router();
  router.get('/demand/<id>', getMatchedPropertiesForDemandHandler);
  router.get('/property/<id>', getMatchedDemandsForPropertyHandler);
  return router;
}
