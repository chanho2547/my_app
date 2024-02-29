// router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:my_app/views/ble_page.dart';
import 'package:my_app/views/display_check.dart';
import 'package:my_app/views/my_home_page.dart';
import 'package:my_app/views/network_page.dart';
import 'package:my_app/views/sound_page.dart';
import 'package:my_app/views/usb_check.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: "/",
    routes: [
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) =>
            const MyHomePage(),
      ),
      GoRoute(
        path: '/ble',
        builder: (BuildContext context, GoRouterState state) => const BLEPage(),
      ),
      GoRoute(
        path: '/network',
        builder: (BuildContext context, GoRouterState state) =>
            const NetworkPage(),
      ),
      GoRoute(
        path: '/sound',
        builder: (BuildContext context, GoRouterState state) =>
            const SoundPage(),
      ),
      GoRoute(
        path: '/display',
        builder: (BuildContext context, GoRouterState state) =>
            const DisplayCheck(),
      ),
      GoRoute(
        path: '/usb',
        builder: (BuildContext context, GoRouterState state) =>
            const USBCheck(),
      ),
    ],
  );
}
