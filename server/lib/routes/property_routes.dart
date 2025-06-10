// 매물 관련 라우트 정의
import 'package:shelf_router/shelf_router.dart';
import '../controllers/property_controller.dart';

Router get propertyRoutes {
  final router = Router();
  router.post('/', (req) {
    print('[propertyRoutes] POST /');
    return addPropertyHandler(req);
  });
  router.get('/', (req) {
    print('[propertyRoutes] GET /');
    return listPropertiesHandler(req);
  });
  router.get('/<id>', (req, id) {
    print('[propertyRoutes] GET /<id>/');
    return getPropertyHandler(req, id);
  });
  router.put('/<id>', (req, id) {
    print('[propertyRoutes] PUT /<id>/');
    return editPropertyHandler(req, id);
  });
  router.patch('/<id>', (req, id) {
    print('[propertyRoutes] PATCH /<id>/');
    return editPropertyHandler(req, id);
  });
  router.delete('/<id>', (req, id) {
    print('[propertyRoutes] DELETE /<id>/');
    return deletePropertyHandler(req, id);
  });
  router.get('/match/demand/<demandId>', (req, demandId) {
    print('[propertyRoutes] GET /match/demand/<demandId>/');
    return matchPropertiesForDemandHandler(req, demandId);
  });
  router.get('/match/property/<propertyId>', (req, propertyId) {
    print('[propertyRoutes] GET /match/property/<propertyId>/');
    return fetchMatchedDemandsForPropertyHandler(req, propertyId);
  });
  return router;
}
