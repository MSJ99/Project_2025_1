import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'view/sign/sign_in_screen.dart';
import 'view/property/Property_view.dart';
import 'view/map/map_view.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:provider/provider.dart';
import 'viewmodel/property_viewmodel.dart';
import 'data/repositories/property_repository.dart';
import 'data/datasources/property_api.dart';
import 'view/demand/demand_view.dart';
import 'viewmodel/demand_viewmodel.dart';
import 'data/repositories/demand_repository.dart';
import 'data/datasources/demand_api.dart';
import 'data/repositories/match_repository.dart';
import 'data/datasources/match_api.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  final naverMap = FlutterNaverMap();
  await naverMap.init(clientId: dotenv.env['NMF_CLIENT_ID']!);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            final matchRepo = MatchRepository(MatchApi());
            return PropertyViewModel(
              PropertyRepository(PropertyApi()),
              matchRepo,
            );
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            final matchRepo = MatchRepository(MatchApi());
            return DemandViewModel(DemandRepository(DemandApi()), matchRepo);
          },
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Palbang',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/home': (context) => PropertyView(),
        '/map': (context) => MapView(),
        '/demand': (context) => DemandView(),
        '/main': (context) => MainScaffold(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    await Future.delayed(const Duration(milliseconds: 500)); // 스플래시 효과용
    if (token != null && token.isNotEmpty) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => MainScaffold()));
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => SignInScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

class MainScaffold extends StatefulWidget {
  const MainScaffold({Key? key}) : super(key: key);

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Widget _getScreen(int index) {
    switch (index) {
      case 0:
        return PropertyView();
      case 1:
        return MapView();
      case 2:
        return DemandView();
      default:
        return PropertyView();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getScreen(_currentIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Property'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Demand'),
        ],
      ),
    );
  }
}
