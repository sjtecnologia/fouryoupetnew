// ignore_for_file: unused_field

import 'dart:async';
import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fouryoupet/common/login_card.dart';
import 'package:fouryoupet/models/Search/search_provider.dart';
import 'package:fouryoupet/models/accommodation/accommodation.dart';
import 'package:fouryoupet/models/accommodation/accommodation_manager.dart';
import 'package:fouryoupet/models/address/address.dart';
import 'package:fouryoupet/models/admin/admin_orders_manager.dart';
import 'package:fouryoupet/models/admin/admin_users_manager.dart';
import 'package:fouryoupet/models/banner/banner_manager.dart';
import 'package:fouryoupet/design_system/app_theme.dart';
import 'package:fouryoupet/models/cart/cart_manager.dart';
import 'package:fouryoupet/models/company/company.dart';
import 'package:fouryoupet/models/hotel/hotel.dart';
import 'package:fouryoupet/models/notificatificacao/notifications_manager.dart';
import 'package:fouryoupet/models/order/order.dart' as pedidos;
import 'package:fouryoupet/models/review/review_manager.dart';
import 'package:fouryoupet/models/recommendation/recommendation_manager.dart';
import 'package:fouryoupet/models/loyalty/loyalty_manager.dart';
import 'package:fouryoupet/models/page_manager.dart';
import 'package:fouryoupet/models/pet/pet.dart';
import 'package:fouryoupet/models/pet/vacinas/vacinasaplic.dart';
import 'package:fouryoupet/models/product/product.dart';
import 'package:fouryoupet/models/schedule/schedule_manager.dart';
import 'package:fouryoupet/models/service/service_manager.dart';
import 'package:fouryoupet/models/user/user_manager.dart';
import 'package:fouryoupet/screens/address/address_add.dart';
import 'package:fouryoupet/screens/address/address_screen.dart';
import 'package:fouryoupet/screens/address/addresss_screen.dart';
import 'package:fouryoupet/screens/base/base_screen.dart';
import 'package:fouryoupet/screens/cart/cart_screen.dart';
import 'package:fouryoupet/screens/categories/categories_screen.dart';
import 'package:fouryoupet/screens/company/company_screen.dart';
import 'package:fouryoupet/screens/company/company_user_screen.dart';
import 'package:fouryoupet/screens/confirmation/confirmation_screen.dart';
import 'package:fouryoupet/screens/edit_accommodation/edit_accommodation_screen.dart';
import 'package:fouryoupet/screens/edit_company/edit_company_screen.dart';
import 'package:fouryoupet/screens/edit_product/edit_product_screen.dart';
import 'package:fouryoupet/screens/edit_service/edit_service_screen.dart';
import 'package:fouryoupet/screens/events/add_ev.dart';
import 'package:fouryoupet/screens/events/data/services/event_provider.dart';
import 'package:fouryoupet/screens/events/event_details.dart';
import 'package:fouryoupet/screens/homenew/home_screen.dart';
import 'package:fouryoupet/screens/hotel/add_hotel.dart';
import 'package:fouryoupet/screens/hotel/add_ht.dart';
import 'package:fouryoupet/screens/hotel/data/services/hotel_provider.dart';
import 'package:fouryoupet/screens/hotel/hotel_details.dart';
import 'package:fouryoupet/screens/hotel/hotels_screen.dart';
import 'package:fouryoupet/screens/login/login_screen.dart';
import 'package:fouryoupet/screens/login/resetpassword_screen.dart';
import 'package:fouryoupet/screens/notificacoes/notifications_screen.dart';
import 'package:fouryoupet/screens/orders/orders_screen.dart';
import 'package:fouryoupet/screens/pet/prontuario/prontuario_add.dart';
import 'package:fouryoupet/screens/pet/prontuario/prontuarios_screen.dart';
import 'package:fouryoupet/screens/pet/vacinas/applications/applications_screen.dart';
import 'package:fouryoupet/screens/pet/vacinas/vacina_add.dart';
import 'package:fouryoupet/screens/pet/vacinas/vacinas_screen.dart';
import 'package:fouryoupet/screens/pets/pets_screen.dart';
import 'package:fouryoupet/screens/product/product_screen.dart';
import 'package:fouryoupet/screens/products/products_screen.dart';
import 'package:fouryoupet/screens/schedule/Available_Time_Form.dart';
import 'package:fouryoupet/screens/select_product/select_product_screen.dart';
import 'package:fouryoupet/screens/select_service/select_service_screen.dart';
import 'package:fouryoupet/screens/service/service_screen.dart';
import 'package:fouryoupet/screens/services/services_screen.dart';
import 'package:fouryoupet/screens/signup/signup_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fouryoupet/screens/userterm/userterm_screen.dart';
import 'package:fouryoupet/screens/userterm/userterm_screen_login.dart';

import 'package:provider/provider.dart';

import 'common/event/chat/chat_page_event.dart';
import 'common/order/chat/chat_page.dart';
import 'firebase_options.dart';
import 'helpers/mysearch_pagenew.dart';
import 'models/categories/categories_manager.dart';
import 'models/company/company_manager.dart';
import 'models/couponcodes/couponcode_manager.dart';
import 'models/event/event.dart';
import 'models/home_manager.dart';
import 'models/order/orders_manager.dart';
import 'models/pet/pet_manager.dart';
import 'models/product/product_manager.dart';
import 'models/service/service.dart';
import 'models/service/service_params.dart';
import 'models/version/version_manager.dart';
import 'screens/checkout/checkout_screen.dart';
import 'screens/company/new_company_screen.dart';
import 'screens/edit_pet/edit_pet_screen.dart';
import 'screens/events/add_event.dart';
import 'screens/events/events_screen.dart';
import 'screens/pet/pesos/peso_add.dart';
import 'screens/pet/pesos/pesos_screen.dart';
import 'screens/pet/screen_pet.dart';
import 'screens/users/users_screen.dart';

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
late final FirebaseApp app;
late final FirebaseAuth auth;

// Handler de mensagens em background (FCM) — necessário se você usa onBackgroundMessage
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Pode adicionar logs/eventos aqui se quiser
}

Future<void> main() async {
  debugPrintGestureArenaDiagnostics = false;

  runZonedGuarded<Future<void>>(() async {
    WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

    app = await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    auth = FirebaseAuth.instanceFor(app: app);

    // Splash
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

    // .env
    await dotenv.load(fileName: '.env');
    // Inicializa Google Maps
    //await MapsService.initializeGoogleMaps();

    // Inicialização mínima do Firebase Messaging no iOS (opcional aqui se já for feito no NotificationsManager)
    // Se você já pede permissão e define apresentação no NotificationsManager, pode remover este bloco.
    if (Platform.isIOS) {
      final messaging = FirebaseMessaging.instance;

      // Garante que background handler está registrado cedo
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);

      // Pede permissão de push (provisional pode ajudar a evitar o "Not Determined")
      await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: true,
      );

      // Garante que notificações em foreground apareçam (iOS)
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    // Analytics: a simples invocação não faz nada efetivo.
    // Use um evento ou adicione o observer abaixo no MaterialApp.
    // await FirebaseAnalytics.instance.logAppOpen();

    runApp(MyApp());

    FlutterNativeSplash.remove();
  }, (error, stackTrace) async {
    debugPrint('Erro não capturado: $error');
    debugPrint('StackTrace: $stackTrace');
  });
}

class MyApp extends StatefulWidget {
  MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  final FirebaseNavigatorObserver =
      FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Não precisamos mais fazer nada aqui pois o logout é feito ao iniciar
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiProvider(
          providers: [
            // Core
            ChangeNotifierProvider<PageManager>.value(
                value: PageManager.instance),

            // Managers simples
            ChangeNotifierProvider(create: (_) => VersionManager()),
            ChangeNotifierProvider(create: (_) => CouponCodeManager()),
            ChangeNotifierProvider(create: (_) => SearchProvider()),
            ChangeNotifierProvider(create: (_) => CategoriesManager()),
            ChangeNotifierProvider(create: (_) => HomeManager()),
            ChangeNotifierProvider(create: (_) => ScheduleManager()),
            ChangeNotifierProvider(create: (_) => ReviewManager()),
            ChangeNotifierProvider(create: (_) => RecommendationManager()),
            ChangeNotifierProvider(create: (_) => LoyaltyManager()),
            ChangeNotifierProvider(create: (_) => UserManager()),
            ChangeNotifierProvider(create: (_) => BannerManager()),
            ChangeNotifierProvider(create: (_) => HotelProvider()),

            // Dependentes de UserManager
            ChangeNotifierProxyProvider<UserManager, CartManager?>(
              create: (_) => CartManager(),
              update: (_, userManager, cartManager) =>
                  cartManager!..updateUser(userManager),
            ),
            ChangeNotifierProxyProvider<UserManager, OrdersManager?>(
              create: (_) => OrdersManager(),
              update: (_, userManager, ordersManager) =>
                  ordersManager!..updateUser(userManager.userapp),
            ),
            ChangeNotifierProxyProvider<UserManager, AdminUsersManager?>(
              create: (_) => AdminUsersManager(),
              update: (_, userManager, adminUsersManager) =>
                  adminUsersManager?..updateUser(userManager),
            ),
            ChangeNotifierProxyProvider<UserManager, AdminOrdersManager?>(
              create: (_) => AdminOrdersManager(),
              update: (_, userManager, adminOrdersManager) =>
                  adminOrdersManager!
                    ..updateAdmin(userManager.adminEnabled,
                        userManager.userapp?.companyID),
            ),
            ChangeNotifierProxyProvider<UserManager, PetManager?>(
              create: (_) => PetManager(),
              update: (_, userManager, petManager) =>
                  petManager!..updateUser(userManager.userapp),
            ),
            ChangeNotifierProxyProvider<UserManager, ProductManager?>(
              create: (_) => ProductManager(),
              update: (_, userManager, productManager) =>
                  productManager!..updateUser(userManager.userapp),
            ),
            ChangeNotifierProxyProvider<UserManager, ServiceManager?>(
              create: (_) => ServiceManager(),
              update: (_, userManager, serviceManager) =>
                  serviceManager!..updateUser(userManager.userapp),
            ),
            ChangeNotifierProxyProvider<UserManager, AccommodationManager?>(
              create: (_) => AccommodationManager(),
              update: (_, userManager, accommodationManager) =>
                  accommodationManager!..updateUser(userManager.userapp),
            ),
            ChangeNotifierProxyProvider<UserManager, EventProvider?>(
              create: (_) => EventProvider(),
              update: (_, userManager, eventProvider) =>
                  eventProvider!..upeUser(userManager.userapp),
            ),
            ChangeNotifierProxyProvider<UserManager, NotificationsManager?>(
              create: (_) => NotificationsManager(),
              update: (_, userManager, notificationsManager) =>
                  notificationsManager!..updateUser(userManager.userapp),
            ),
            ChangeNotifierProxyProvider<UserManager, CompanyManager?>(
              create: (_) => CompanyManager(),
              update: (_, userManager, companyManager) =>
                  companyManager!..updateUser(userManager.userapp),
            ),
          ],
          child: MaterialApp(
            navigatorKey: navigatorKey,
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            supportedLocales: const [Locale('pt', 'BR')],
            title: '4You Pet',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            navigatorObservers: [
              FirebaseNavigatorObserver, // Habilita tracking automático de navegação
            ],
            // Tela inicial
            home: BaseScreen(),
            onGenerateRoute: (settings) {
              switch (settings.name) {
                case '/':
                case '/base':
                  return MaterialPageRoute(builder: (_) => BaseScreen());
                case '/pet':
                  return MaterialPageRoute(builder: (_) => ScreenPet());
                case '/orders':
                  return MaterialPageRoute(builder: (_) => OrdersScreen());
                case '/home':
                  return MaterialPageRoute(builder: (_) => HomeScreen());
                case '/login':
                  return MaterialPageRoute(builder: (_) => LoginScreen());
                case '/signup':
                  return MaterialPageRoute(builder: (_) => SignUpScreen());
                case '/acount':
                  return MaterialPageRoute(builder: (_) => UserScreen());
                case '/logincar':
                  return MaterialPageRoute(builder: (_) => LoginCard());

                case '/productcp':
                  return MaterialPageRoute(
                    builder: (_) =>
                        ProductScreen(settings.arguments as Product?),
                  );

                case '/products':
                  // ATENÇÃO: você estava tentando usar o mesmo settings.arguments para dois tipos diferentes.
                  // Use um Map para passar multiplos parâmetros.
                  final args = settings.arguments as Map<String, dynamic>;
                  return MaterialPageRoute(
                    builder: (_) => ProductsScreen(
                      productManager: args['productManager'] as ProductManager,
                      categoring: args['categoring'] as bool?,
                    ),
                    settings: settings,
                  );

                case '/servicecp':
                  return MaterialPageRoute(
                    builder: (_) =>
                        ServiceScreen(settings.arguments as Service?),
                  );

                case '/pets':
                  return MaterialPageRoute(builder: (_) => PetsScreen());

                case '/services':
                  // Mesma abordagem: use Map para múltiplos parâmetros
                  final args = settings.arguments as Map<String, dynamic>?;
                  return MaterialPageRoute(
                    builder: (_) => ServicesScreen(
                      serviceParams: args?['serviceParams'] as ServiceParams?,
                      categoring: args?['categoring'] as bool?,
                    ),
                    settings: settings,
                  );

                case '/company':
                  return MaterialPageRoute(
                    builder: (_) =>
                        CompanyScreen(settings.arguments as Company?),
                  );

                case '/editcompany':
                  return MaterialPageRoute(
                    builder: (_) =>
                        EditCompanyScreen(settings.arguments as Company?),
                  );

                case '/category':
                  return MaterialPageRoute(builder: (_) => CategoriesScreen());

                case '/copanyuser': // mantém o nome caso já esteja usado
                  return MaterialPageRoute(
                    builder: (_) =>
                        CompanyUserScreen(settings.arguments as String),
                  );

                case '/cart':
                  return MaterialPageRoute(
                      builder: (_) => CartScreen(), settings: settings);

                case '/address':
                  return MaterialPageRoute(builder: (_) => AddressScreen());

                case '/checkout':
                  return MaterialPageRoute(builder: (_) => CheckoutScreen());

                case '/edit_pet':
                  return MaterialPageRoute(
                    builder: (_) => EditPetScreen(settings.arguments as Pet?),
                  );

                case '/edit_product':
                  return MaterialPageRoute(
                    builder: (_) =>
                        EditProductScreen(settings.arguments as Product?),
                  );

                case '/select_product':
                  return MaterialPageRoute(
                      builder: (_) => SelectProductScreen());

                case '/edit_service':
                  return MaterialPageRoute(
                    builder: (_) =>
                        EditServiceScreen(settings.arguments as Service?),
                  );

                case '/edit_acc':
                  return MaterialPageRoute(
                    builder: (_) => EditAccommodationScreen(
                        settings.arguments as Accommodation?),
                  );

                case '/select_service':
                  return MaterialPageRoute(
                      builder: (_) => SelectServiceScreen());

                case '/confirmation':
                  return MaterialPageRoute(
                    builder: (_) => ConfirmationScreen(
                        settings.arguments as pedidos.Order?),
                  );

                case 'add_event':
                  // Use Map para evitar conflitos de tipos em settings.arguments
                  final args = settings.arguments as Map<String, dynamic>?;
                  return MaterialPageRoute(
                    builder: (_) => AddEv(
                      selectedDate: args?['selectedDate'] as DateTime?,
                      company: args?['company'] as String?,
                    ),
                    settings: settings,
                  );

                case 'view_event':
                  return MaterialPageRoute(
                    builder: (_) =>
                        EventDetails(event: settings.arguments as AppEvent?),
                  );

                case 'edit_event':
                  return MaterialPageRoute(
                    builder: (_) =>
                        AddEventPage(event: settings.arguments as AppEvent?),
                  );

                case '/add_hotel':
                  final args = settings.arguments as Map<String, dynamic>?;
                  return MaterialPageRoute(
                    builder: (_) => AddHt(
                      selectedDate: args?['selectedDate'] as DateTime?,
                      company: args?['company'] as String?,
                    ),
                    settings: settings,
                  );

                case '/view_hotel':
                  return MaterialPageRoute(
                    builder: (_) =>
                        HotelDetails(hotel: settings.arguments as Hotel?),
                  );

                case '/edit_hotel':
                  return MaterialPageRoute(
                    builder: (_) =>
                        AddHotelPage(hotel: settings.arguments as Hotel?),
                  );

                case '/term':
                  return MaterialPageRoute(builder: (_) => UsertermScreen());

                case '/termlogin':
                  // Verifique se o widget está correto; o nome sugere duplicidade "LoginLogin"
                  return MaterialPageRoute(
                      builder: (_) => UsertermScreenLoginLogin());

                case '/resetpass':
                  return MaterialPageRoute(
                      builder: (_) => ResetPasswordScreen());

                case '/myevents':
                  return MaterialPageRoute(builder: (_) => EventsScreen());

                case '/schedule':
                  return MaterialPageRoute(
                    builder: (_) => AvailableTimeForm(
                        company: settings.arguments as String),
                  );

                case '/myhotels':
                  return MaterialPageRoute(builder: (_) => HotelsScreen());

                case '/chatorder':
                  // Corrigido: use Map para passar múltiplos argumentos e evitar casts inválidos
                  final args = settings.arguments as Map<String, dynamic>;
                  return MaterialPageRoute(
                    builder: (_) => ChatPage(
                      groupId: args['groupId'] as String,
                      userName: args['userName'] as String,
                      userToken: (args['userToken'] as List).cast<String>(),
                    ),
                  );

                case '/chatevent':
                  final args = settings.arguments as Map<String, dynamic>;
                  return MaterialPageRoute(
                    builder: (_) => ChatPageEvent(
                      groupId: args['groupId'] as String,
                      userName: args['userName'] as String?,
                      userToken: (args['userToken'] as List?)?.cast<String>(),
                    ),
                  );

                case '/listadress':
                  return MaterialPageRoute(
                    builder: (_) =>
                        AddresssScreen(type: settings.arguments as String?),
                  );

                case '/notifications':
                  return MaterialPageRoute(
                      builder: (_) => NotificationsScreen());

                case '/search':
                  return MaterialPageRoute(builder: (_) => MySearchPageNew());

                case '/addadress':
                  return MaterialPageRoute(
                    builder: (_) =>
                        AddressAdd(address: settings.arguments as Address?),
                  );

                case '/vacinaspet':
                  return MaterialPageRoute(
                    builder: (_) =>
                        VacinasScreen(pet: settings.arguments as Pet),
                  );

                case '/addvacina':
                  return MaterialPageRoute(
                      builder: (_) => VacinaAdd(), settings: settings);

                case '/prontuariospet':
                  return MaterialPageRoute(
                    builder: (_) =>
                        ProntuariosScreen(pet: settings.arguments as Pet),
                  );

                case '/addprontuario':
                  return MaterialPageRoute(
                      builder: (_) => ProntuarioAdd(), settings: settings);

                case '/pesospet':
                  return MaterialPageRoute(
                    builder: (_) => PesoScreen(pet: settings.arguments as Pet),
                  );

                case '/addpeso':
                  return MaterialPageRoute(
                      builder: (_) => PesoAdd(), settings: settings);

                case '/applications':
                  // Corrigido: as duas coisas não podem vir no mesmo settings.arguments sem Map
                  final args = settings.arguments as Map<String, dynamic>?;
                  return MaterialPageRoute(
                    builder: (_) => ApplicationsScreen(
                      vacinasaplic: args?['vacinasaplic'] as Vacinasaplic?,
                      pet: args?['pet'] as Pet?,
                    ),
                  );

                case '/newcompany':
                  return MaterialPageRoute(builder: (_) => NewCompanyScreen());

                default:
                  // Evita crash quando a rota não existe
                  debugPrint('Rota não encontrada: ${settings.name}');
                  return MaterialPageRoute(builder: (_) => BaseScreen());
              }
            },
          ),
        );
      },
    );
  }
}
