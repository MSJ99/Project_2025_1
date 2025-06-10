import 'package:shelf_router/shelf_router.dart';
import '../controllers/demand_controller.dart';
import 'dart:developer';

Router get demandRoutes {
  final router = Router();
  router.post('/', (req) {
    print('[demandRoutes] POST /');
    return addDemandHandler(req);
  });
  router.get('/', (req) {
    print('[demandRoutes] GET /');
    return listDemandsHandler(req);
  });
  router.get('/<id>', (req, id) {
    print('[demandRoutes] GET /<id>/');
    return getDemandHandler(req, id);
  });
  router.put('/<id>', (req, id) {
    print('[demandRoutes] PUT /<id>/');
    return editDemandHandler(req, id);
  });
  router.patch('/<id>', (req, id) {
    print('[demandRoutes] PATCH /<id>/');
    return editDemandHandler(req, id);
  });
  router.delete('/<id>', (req, id) {
    print('[demandRoutes] DELETE /<id>/');
    return deleteDemandHandler(req, id);
  });
  return router;
}
