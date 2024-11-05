import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
}

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  User? usuario;
  bool isLoading = true;

  AuthService() {
    _authCheck();
  }

  // Verifica mudanças no estado de autenticação
  void _authCheck() {
    _auth.authStateChanges().listen((User? user) {
      usuario = user;
      isLoading = false;
      notifyListeners();
    });
  }

  // Atualiza o usuário atual
  void _getUser() {
    usuario = _auth.currentUser;
    notifyListeners();
  }

  // Função para registrar usuário com email e senha
  Future<void> registrar(String email, String senha) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: senha);
      _getUser();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw AuthException('A senha é muito fraca!');
      } else if (e.code == 'email-already-in-use') {
        throw AuthException('Este email já está cadastrado');
      } else {
        throw AuthException('Erro ao registrar. Tente novamente.');
      }
    }
  }

  // Função para login com email e senha
  Future<void> login(String email, String senha) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: senha);
      _getUser();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw AuthException('Email não encontrado. Cadastre-se.');
      } else if (e.code == 'wrong-password') {
        throw AuthException('Senha incorreta. Tente novamente.');
      } else {
        throw AuthException('Erro ao fazer login. Tente novamente.');
      }
    }
  }

  // Função para login com Google
  Future<void> loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw AuthException('Login com Google cancelado pelo usuário.');
      }
      
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      await _auth.signInWithCredential(credential);
      _getUser();
    } on FirebaseAuthException catch (e) {
      throw AuthException('Erro na autenticação com o Google: ${e.message}');
    } catch (e) {
      throw AuthException('Falha ao realizar login com o Google: $e');
    }
  }

  // Função para logout
  Future<void> logout() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut(); // Certifica que o Google Sign Out também é feito
      _getUser();
    } catch (e) {
      throw AuthException('Erro ao sair da conta. Tente novamente.');
    }
  }
}
