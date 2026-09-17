import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'providers/customer_provider.dart';
import 'providers/transaction_provider.dart';
import 'providers/localization_provider.dart';
import 'providers/auth_provider.dart';
import 'presentation/widgets/auth_wrapper.dart';
import 'data/database/database_helper.dart';
import 'data/database/sqlite_database.dart';
import 'data/dao/customer_dao.dart';
import 'data/dao/transaction_dao.dart';
import 'data/repositories/customer_repository.dart';
import 'data/repositories/transaction_repository.dart';
import 'generated/app_localizations.dart';
import 'services/unified_pdf_service.dart';
import 'services/error_logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SQLite FFI for desktop platforms (Windows, macOS, Linux)
  SqliteDatabase.initializeFfi();

  // Set up global error handlers
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    ErrorLogger.logError(
      details.exception,
      details.stack,
      context: 'Flutter Error',
      additionalData: {
        'library': details.library ?? 'unknown',
        'context': details.context?.toString() ?? 'unknown',
      },
    );
  };

  try {
    // Initialize PDF service fonts (for all platforms)
    print('🚀 [Main] Initializing PDF service...');
    await UnifiedPdfService.initialize();
    print('✅ [Main] PDF service initialized');

    // Initialize database
    print('🚀 [Main] Initializing database...');
    final dbHelper = DatabaseHelper();
    await dbHelper.initDatabase();
    print('✅ [Main] Database initialized: ${dbHelper.database.databaseType}');

    // Initialize localization provider
    print('🚀 [Main] Initializing localization...');
    final localizationProvider = LocalizationProvider();
    await localizationProvider.init();
    print('✅ [Main] Localization initialized');

    // Initialize auth provider
    print('🚀 [Main] Initializing auth provider...');
    final authProvider = AuthProvider();
    await authProvider.initialize();
    print('✅ [Main] Auth provider initialized');

    // Initialize repositories and DAOs
    print('🚀 [Main] Initializing repositories...');
    final customerDAO = CustomerDAO(dbHelper.database);
    final transactionDAO = TransactionDAO(dbHelper.database);
    final customerRepository = CustomerRepository(customerDAO);
    final transactionRepository = TransactionRepository(transactionDAO);
    print('✅ [Main] Repositories initialized');

    print('🎉 [Main] All initialization complete!');
    print('📊 [Main] Database type: ${dbHelper.database.databaseType}');

    runApp(
      MyApp(
        localizationProvider: localizationProvider,
        authProvider: authProvider,
        customerRepository: customerRepository,
        transactionRepository: transactionRepository,
      ),
    );
  } catch (e, stackTrace) {
    print('❌ [Main] CRITICAL ERROR during initialization:');
    print('Error: $e');
    print('Stack trace: $stackTrace');
    
    // Show error dialog
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 20),
                  const Text(
                    'Initialization Error',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Error: $e',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Please try:\n'
                    '1. Restart the app\n'
                    '2. Clear app data\n'
                    '3. Reinstall the app',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  final LocalizationProvider localizationProvider;
  final AuthProvider authProvider;
  final CustomerRepository customerRepository;
  final TransactionRepository transactionRepository;

  const MyApp({
    Key? key,
    required this.localizationProvider,
    required this.authProvider,
    required this.customerRepository,
    required this.transactionRepository,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: localizationProvider),
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(
          create: (_) => CustomerProvider(
            customerRepository,
            transactionRepository,
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => TransactionProvider(
            transactionRepository,
            context.read<CustomerProvider>(),
          ),
        ),
      ],
      child: Consumer<LocalizationProvider>(
        builder: (context, localization, _) {
          return MaterialApp(
            key: ValueKey(localization.languageCode), // Force rebuild on language change
            title: 'Credit Manager',
            debugShowCheckedModeBanner: false,
            locale: localization.currentLocale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: localization.supportedLocales,
            localeResolutionCallback: (locale, supportedLocales) {
              // For Tunisian, use Arabic as fallback for Material/Cupertino localizations
              if (locale?.languageCode == 'tn') {
                return const Locale('ar'); // Use Arabic for Material widgets
              }
              // Default resolution
              for (var supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == locale?.languageCode) {
                  return supportedLocale;
                }
              }
              return supportedLocales.first;
            },
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
              useMaterial3: true,
              primaryColor: Colors.blue.shade600,
              appBarTheme: AppBarTheme(
                elevation: 0,
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
              cardTheme: CardThemeData(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
              chipTheme: ChipThemeData(
                backgroundColor: Colors.grey.shade200,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                labelStyle: TextStyle(color: Colors.black87),
              ),
              floatingActionButtonTheme: const FloatingActionButtonThemeData(
                elevation: 4,
              ),
              fontFamily: 'Roboto',
            ),
            builder: (context, child) {
              return Directionality(
                textDirection: (localization.languageCode == 'ar' || localization.languageCode == 'tn')
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                child: child!,
              );
            },
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }
}
