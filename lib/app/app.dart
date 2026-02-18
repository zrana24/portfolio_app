import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'routes.dart';
import '../bloc/home/home_bloc.dart';
import '../bloc/addPortfolio/addPortfolio_bloc.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<HomeBloc>(
          create: (context) => HomeBloc(),
        ),
        BlocProvider<AddPortfolioBloc>(
          create: (context) => AddPortfolioBloc(),
        ),
      ],
      child: MaterialApp(
        title: 'Cebeci',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.white,
        ),
        debugShowCheckedModeBanner: false,
        initialRoute: AppRoutes.home,
        routes: AppRoutes.getRoutes(),
      ),
    );
  }
}