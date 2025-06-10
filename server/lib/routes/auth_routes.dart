import 'package:shelf_router/shelf_router.dart';
import '../controllers/auth_controller.dart';

Router get authRoutes {
  final router = Router();
  router.post('/register', registerHandler);
  router.post('/login', loginHandler);
  router.post('/logout', logoutHandler);
  router.post('/send_verification', sendVerificationHandler);
  router.post('/verify_code', verifyCodeHandler);
  router.post('/google-login', googleLoginHandler);
  router.get('/user/me', getMeHandler);
  return router;
}
