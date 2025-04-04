import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'firebase_options.dart';
import 'providers/product_provider.dart';
import 'providers/order_provider.dart';
import 'screens/home_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/categories_screen.dart';
import 'screens/add_product_screen.dart';
import 'screens/order_screen.dart';
import 'screens/splash_screen.dart';
import 'services/firestore_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Enable Crashlytics in non-web platforms
  if (!kIsWeb) {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  }

  // Enable Firestore debug mode
  if (kDebugMode) {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _initializeFirebase();
    _checkLoginStatus();
    _backupData();
  }

  Future<void> _initializeFirebase() async {
    // Implementation of _initializeFirebase method
  }

  Future<void> _checkLoginStatus() async {
    // Implementation of _checkLoginStatus method
  }

  Future<void> _backupData() async {
    final firestoreService = FirestoreService();
    await firestoreService.backupData();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            final provider = ProductProvider();
            provider.loadProducts();
            return provider;
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            final provider = OrderProvider();
            provider.loadData();
            return provider;
          },
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'മൊബൈൽ ഷോപ്പ്',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const SplashScreen(),
        routes: {
          '/home': (context) => const HomeScreen(),
          '/product-detail': (context) => ProductDetailScreen(
                productId: ModalRoute.of(context)!.settings.arguments as String,
              ),
          '/categories': (context) => const CategoriesScreen(),
          '/add-product': (context) => const AddProductScreen(),
          '/order': (context) => const OrderScreen(),
        },
      ),
    );
  }
}
