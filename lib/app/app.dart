import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portfoy_app/bloc/profile/profile_bloc.dart';
import '../app/routes.dart';
import '../bloc/home/home_bloc.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/addPortfolio/addPortfolio_bloc.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
final FirebaseAnalyticsObserver observer =
FirebaseAnalyticsObserver(analytics: analytics);

final GlobalKey<ScaffoldMessengerState> globalMessengerKey = GlobalKey<ScaffoldMessengerState>();

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MultiBlocProvider(
      providers: [
        BlocProvider<HomeBloc>(
          create: (context) => HomeBloc(),
        ),
        BlocProvider<AddPortfolioBloc>(
          create: (context) => AddPortfolioBloc(),
        ),
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(),
        ),
        BlocProvider<ProfileBloc>(
          create: (context) => ProfileBloc(),
        ),
      ],
      child: MaterialApp(
        title: 'Cebeci',
        scaffoldMessengerKey: globalMessengerKey,
        navigatorObservers: [observer],
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.black),
          ),
        ),
        debugShowCheckedModeBanner: false,
        initialRoute: initialRoute,
        routes: AppRoutes.getRoutes(),
      ),
    );
  }
}