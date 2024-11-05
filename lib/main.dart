import 'package:acesstrans/configs/hive_config.dart';
import 'package:acesstrans/core/theme/app_themes.dart';
import 'package:acesstrans/screens/LoginPage.dart';
import 'package:acesstrans/screens/homePage.dart';
import 'package:acesstrans/service/auth_service.dart';
import 'package:acesstrans/widgets/auth_check.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveConfig.start(); 
  await Firebase.initializeApp(); 

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) => AuthService()), 
      ],
      child: const MeuAplicativo(), 
    ),
  );
}

class MeuAplicativo extends StatelessWidget {
  const MeuAplicativo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cripto Moedas',
      debugShowCheckedModeBanner: false,
      theme: AppThemes.lightTheme,
      initialRoute: '/', // Defina a rota inicial
      routes: {
        '/': (context) => AuthCheck(), // Checa a autenticação do usuário
        '/home': (context) => HomePage(), // Tela principal após login
        '/login': (context) => LoginPage(), // Tela de login
      },
    );
  }
}
