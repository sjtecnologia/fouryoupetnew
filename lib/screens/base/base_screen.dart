import 'package:cloud_firestore_platform_interface/src/timestamp.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fouryoupet/common/event/chat/chat_page_event.dart';

import 'package:fouryoupet/models/Search/search_provider.dart';
import 'package:fouryoupet/common/custom_drawer/custom_drawer.dart'; // Importa seu CustomDrawer

import 'package:fouryoupet/models/notificatificacao/notifi.dart';
import 'package:fouryoupet/models/notificatificacao/notifications_manager.dart';
import 'package:fouryoupet/models/page_manager.dart'; // Importa seu PageManager

import 'package:fouryoupet/models/order/orders_manager.dart';

import 'package:fouryoupet/models/product/product_manager.dart';

import 'package:fouryoupet/screens/events/data/services/event_provider.dart';

import 'package:fouryoupet/screens/events/events_screen.dart';

import 'package:fouryoupet/screens/pet/screen_pet.dart';

import 'package:fouryoupet/screens/users/users_screen.dart';

import 'package:provider/provider.dart';
import 'package:fouryoupet/models/user/user_manager.dart';

import 'package:fouryoupet/screens/homenew/home_screen.dart';
import 'package:fouryoupet/screens/orders/orders_screen.dart';

import '../../common/order/chat/chat_page.dart';

import '../../helpers/mysearch_pagenew.dart';
import '../../models/company/company_manager.dart';
import '../../models/event/event.dart';
import '../../models/order/order.dart';

import '../hotel/hotels_screen.dart';
import '../notificacoes/notifications_screen.dart';

class BaseScreen extends StatefulWidget {
  const BaseScreen({Key? key, this.forceRefresh = false}) : super(key: key);

  final bool forceRefresh;
  @override
  _BaseScreenState createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  final PageController pageController = PageController();
  int paginaAtual = 0;
  static const int numPaginasFixas =
      8; // Home, Orders, Events, Hotels, Pets, User, Notifications, Search
  late int qtdmsg = 0;
  late int qtdmsge = 0;

  _BaseScreenState();

  @override
  void initState() {
    super.initState();

    // Escuta mudanças no PageManager e sincroniza com o controller local
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pageManager = context.read<PageManager>();
      pageManager.addListener(_onPageManagerChanged);
    });

    if (widget.forceRefresh) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final companyManager = context.read<CompanyManager>();
        await companyManager.loadAllCompanys();
        final userManager = context.read<UserManager>();
        await userManager.finduser();
      });
    }

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<NotificationsManager>().stNotific();
      await context.read<NotificationsManager>().stNotificnolido();
      await context
          .read<OrdersManager>()
          .qtdMessage()
          ?.then((v) => qtdmsg = v ?? 0);
      if (context.mounted)
        await context
            .read<EventProvider>()
            .qtdMessage()
            ?.then((e) => qtdmsge = e ?? 0);
    });

    configFCM();
    setPaginaAtual(0);
  }

  @override
  void dispose() {
    // Remove o listener antes de dispose (se o context ainda estiver montado)
    if (mounted) {
      try {
        final pageManager = context.read<PageManager>();
        pageManager.removeListener(_onPageManagerChanged);
      } catch (e) {
        // Ignora erro se o context não estiver mais disponível
      }
    }
    pageController.dispose();
    super.dispose();
  }

  void _onPageManagerChanged() {
    final pageManager = context.read<PageManager>();
    final targetPage = pageManager.page;
    if (pageController.hasClients && targetPage != paginaAtual) {
      pageController.jumpToPage(targetPage);
      setPaginaAtual(targetPage);
    } else if (!pageController.hasClients) {
      // Se o controller não tem clientes ainda, agenda para depois
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (pageController.hasClients && mounted) {
          pageController.jumpToPage(targetPage);
          setPaginaAtual(targetPage);
        }
      });
    }
  }

  late AndroidNotificationDetails androidDetails;
  late DarwinNotificationDetails iosDetails;

  late String image;

  FlutterLocalNotificationsPlugin localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> configFCM() async {
    var android = AndroidInitializationSettings('@mipmap/ic_launcher');
    var ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      defaultPresentBadge: false,
    );

    FirebaseMessaging fcm = FirebaseMessaging.instance;

    var initializationSettings = InitializationSettings(
        android: android, iOS: ios, macOS: null, linux: null);
    localNotificationsPlugin.initialize(
      initializationSettings,
    );

    try {
      NotificationSettings settings = await fcm.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      if (kDebugMode) {
        print('User granted permission: ${settings.authorizationStatus}');
      }
    } catch (e, s) {
      print(e);
      print(s);
    }

    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) async {
        showNotification(message.ttl, message.notification!.title,
            message.notification?.body);
        await saveNotifications(message, false);
      },
    );

    FirebaseMessaging.instance.getInitialMessage().then((message) async {
      if (message != null) {
        List<String>? tk = [];

        if (message.data['type'] == 'order') {
          String groupId = message.data["click_action"];
          String userName = context.read<UserManager>().userapp?.name ?? '';
          List<Order> od = [];
          od.addAll(await context
              .read<OrdersManager>()
              .orders
              .where((od) => od.orderId == groupId)
              .toList());
          if (od.isNotEmpty) if (context.read<UserManager>().adminEnabled) {
            if (context.read<UserManager>().userapp!.companyID ==
                od.first.companyID) {
              tk = await context
                  .read<UserManager>()
                  .getToken(od.first.userId.toString());
            } else {
              tk = await context.read<UserManager>().getToken(context
                      .read<UserManager>()
                      .findUserByCompanyID(od.first.companyID) ??
                  '');
            }
          } else {
            tk = await context.read<UserManager>().getToken(context
                    .read<UserManager>()
                    .findUserByCompanyID(od.first.companyID) ??
                '');
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(
                groupId: groupId,
                userName: userName,
                userToken: tk,
              ),
            ),
          );
        } else if (message.data['type'] == 'event') {
          String groupId = message.data["click_action"];
          String userName = context.read<UserManager>().userapp?.name ?? '';
          List<AppEvent> od = [];
          od.addAll(await context
              .read<EventProvider>()
              .events
              .where((od) => od.id == groupId)
              .toList());
          if (od.isNotEmpty) if (context.read<UserManager>().adminEnabled) {
            if (context.read<UserManager>().userapp!.companyID ==
                od.first.companyID) {
              tk = await context
                  .read<UserManager>()
                  .getToken(od.first.userID.toString());
            } else {
              tk = await context.read<UserManager>().getToken(context
                      .read<UserManager>()
                      .findUserByCompanyID(od.first.companyID) ??
                  '');
            }
          } else {
            tk = await context.read<UserManager>().getToken(context
                    .read<UserManager>()
                    .findUserByCompanyID(od.first.companyID) ??
                '');
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPageEvent(
                groupId: groupId,
                userName: userName,
                userToken: tk,
              ),
            ),
          );
        } else {
          await saveNotifications(message, true);
        }
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      List<String>? tk = [];

      if (message.data['type'] == 'order') {
        String groupId = message.data["click_action"];
        String userName = context.read<UserManager>().userapp?.name ?? '';
        List<Order> od = [];
        od.addAll(await context
            .read<OrdersManager>()
            .orders
            .where((od) => od.orderId == groupId)
            .toList());
        if (od.isNotEmpty) if (context.read<UserManager>().adminEnabled) {
          if (context.read<UserManager>().userapp!.companyID ==
              od.first.companyID) {
            tk = await context
                .read<UserManager>()
                .getToken(od.first.userId.toString());
          } else {
            tk = await context.read<UserManager>().getToken(context
                    .read<UserManager>()
                    .findUserByCompanyID(od.first.companyID) ??
                '');
          }
        } else {
          tk = await context.read<UserManager>().getToken(context
                  .read<UserManager>()
                  .findUserByCompanyID(od.first.companyID) ??
              '');
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(
              groupId: groupId,
              userName: userName,
              userToken: tk,
            ),
          ),
        );
      } else if (message.data['type'] == 'event') {
        Navigator.pushNamed(context, '/chatevent',
            arguments: message.data['click']);
      } else {
        await saveNotifications(message, true);
      }
    });
  }

  Future<void> saveNotifications(
      RemoteMessage message, bool sendtonotification) async {
    Notifi notifi = Notifi();
    if (message.data['type'] != 'order' && message.data['type'] != 'event') {
      notifi.image = message.data['image'] ?? null;
      notifi.lido = false;
      notifi.notificationBody = message.notification?.body;
      notifi.notificationDate = Timestamp.now();
      notifi.notificationTitle = message.notification?.title;
      notifi.type = 'ntf';
      if (mounted) await context.read<NotificationsManager>().setNotifi(notifi);
      if (mounted) await context.read<NotificationsManager>().stNotific();

      if (sendtonotification) {
        await context.read<NotificationsManager>().stNotific();
        Navigator.pushNamed(
          context,
          '/notifications',
        );
      }
    }
  }

  void showNotification(
    int? id,
    String? title,
    String? message,
  ) {
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'assets/sound/notification1.aiif',
    );

    const androidDetails = AndroidNotificationDetails(
      'Notifications_4youpet',
      'Notifications',
      channelDescription: 'Canal de notificacoes',
      importance: Importance.max,
      priority: Priority.high,
      enableVibration: true,
      sound: RawResourceAndroidNotificationSound('notification1'),
    );

    localNotificationsPlugin.show(id ?? 0, title, message,
        NotificationDetails(android: androidDetails, iOS: iosDetails));
  }

  Widget? btnav;
  int qtdnfn = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        drawer: CustomDrawer(),
        extendBody: true,
        bottomNavigationBar: btnav,
        body: Consumer5<UserManager, ProductManager, NotificationsManager,
            SearchProvider, PageManager>(
          builder: (_, userManager, productManager, notoficationManager,
              seacherProvider, pageManager, __) {
            // ✅ MUDANÇA AQUI: Adiciona uma Key para forçar a reconstrução do PageView
            // quando as condições de exibição das páginas mudam.
            final Key pageViewKey = ValueKey(
                'pageView_${userManager.adminEnabled}_${userManager.userapp?.companyID ?? 'no_company'}');

            // Lista fixa de páginas para o menu inferior
            final List<Widget> paginasFixas = [
              HomeScreen(), // 0
              OrdersScreen(), // 1
              EventsScreen(), // 2
              HotelsScreen(), // 3
              ScreenPet(), // 4
              UserScreen(), // 5
              NotificationsScreen(), // 6
              MySearchPageNew(), // 7
            ];
            return PageView(
              key: pageViewKey,
              controller: pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: paginasFixas,
              onPageChanged: (pageIndex) {
                setPaginaAtual(pageIndex);
              },
            );
          },
        ),
      ),
    );
  }

  setPaginaAtual(pagina) async {
    setState(() {
      // Protege para não passar índice inválido
      if (pagina < 0 || pagina >= numPaginasFixas) {
        paginaAtual = 0;
      } else {
        paginaAtual = pagina;
      }
      btnav = CurvedNavigationBar(
        buttonBackgroundColor: Colors.white,
        index: paginaAtual,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 300),
        backgroundColor: Color.fromARGB(255, 255, 161, 0),
        items: const [
          Icon(Icons.home),
          Icon(Icons.shopify),
          Icon(Icons.calendar_today),
          Icon(Icons.hotel),
          Icon(Icons.pets_sharp),
          Icon(Icons.person),
          Icon(Icons.notification_important),
          Icon(Icons.search),
        ],
        onTap: (pageIndex) {
          if (pageIndex >= 0 && pageIndex < numPaginasFixas) {
            context.read<PageManager>().setPage(pageIndex);
            context.read<NotificationsManager>().stNotificnolido();
          }
        },
      );
    });
  }
}
