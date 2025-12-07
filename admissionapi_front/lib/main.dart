import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'providers/applicant_provider.dart';
import 'providers/application_provider.dart';
import 'providers/data_provider.dart';
import 'screens/dashboard_screen.dart';
import 'screens/applicants/applicant_list_screen.dart';
import 'screens/applicants/applicant_form_screen.dart';
import 'screens/applicants/applicant_detail_screen.dart';
import 'screens/applications/application_list_screen.dart';
import 'screens/applications/application_form_screen.dart';
import 'screens/exams/exam_list_screen.dart';

void main() {
  runApp(const MyApp());
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/applicants',
      name: 'applicants',
      builder: (context, state) => const ApplicantListScreen(),
      routes: [
        GoRoute(
          path: 'new',
          name: 'applicant_new',
          builder: (context, state) => const ApplicantFormScreen(),
        ),
        GoRoute(
          path: ':id',
          name: 'applicant_detail',
          builder: (context, state) {
            final id = int.parse(state.pathParameters['id']!);
            return ApplicantDetailScreen(applicantId: id);
          },
        ),
        GoRoute(
          path: ':id/edit',
          name: 'applicant_edit',
          builder: (context, state) {
            final id = int.parse(state.pathParameters['id']!);
            final applicant = Provider.of<ApplicantProvider>(
              context,
              listen: false,
            ).findApplicantById(id);
            return ApplicantFormScreen(applicant: applicant);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/applications',
      name: 'applications',
      builder: (context, state) => const ApplicationListScreen(),
      routes: [
        GoRoute(
          path: 'new',
          name: 'application_new',
          builder: (context, state) {
            final applicantId = state.extra as int?;
            return ApplicationFormScreen(applicantId: applicantId);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/exams',
      name: 'exams',
      builder: (context, state) => const ExamListScreen(),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('Ошибка')),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'Страница не найдена',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => context.go('/'),
            child: const Text('На главную'),
          ),
        ],
      ),
    ),
  ),
);

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ApplicantProvider()),
        ChangeNotifierProvider(create: (context) => ApplicationProvider()),
        ChangeNotifierProvider(create: (context) => DataProvider()),
      ],
      child: MaterialApp.router(
        title: 'Приемная комиссия',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 2,
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          cardTheme: CardTheme(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        darkTheme: ThemeData.dark().copyWith(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,
          ),
        ),
        routerConfig: _router,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('ru', 'RU'),
          Locale('en', 'US'),
        ],
        locale: const Locale('ru', 'RU'),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}