// lib/src/templates/auth_templates.dart
import '../shared/auth_provider.dart' as auth_provider;

class AuthTemplates {
  final auth_provider.AuthProvider provider;
  
  AuthTemplates(this.provider);

  /// Auth Event code template
  String getAuthEventCode() {
    final isApi = provider == auth_provider.AuthProvider.api;
    return '''
import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

class AuthRegisterRequested extends AuthEvent {
  final String email;
  final String password;
  ${isApi ? 'final String name;' : ''}

  const AuthRegisterRequested({
    required this.email,
    required this.password,
    ${isApi ? 'required this.name,' : ''}
  });

  @override
  List<Object> get props => [email, password${isApi ? ', name' : ''}];
}

class AuthLogoutRequested extends AuthEvent {}

class AuthStatusChanged extends AuthEvent {
  final bool isAuthenticated;

  const AuthStatusChanged({required this.isAuthenticated});

  @override
  List<Object> get props => [isAuthenticated];
}

${isApi ? '''
class AuthTokenRefreshRequested extends AuthEvent {}
''' : ''}
''';
  }

  /// Auth State code template
  String getAuthStateCode() {
    final isApi = provider == auth_provider.AuthProvider.api;
    return '''
import 'package:equatable/equatable.dart';
${isApi ? "import '../models/user_model.dart';" : ''}

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  ${isApi ? '''
  final UserModel user;
  final String token;

  const AuthAuthenticated({
    required this.user,
    required this.token,
  });

  @override
  List<Object> get props => [user, token];
  ''' : ''}
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object> get props => [message];
}
''';
  }

  /// Auth BLoC code template
  String getAuthBlocCode() {
    final isFirebase = provider == auth_provider.AuthProvider.firebase;
    return isFirebase ? _getFirebaseBlocCode() : _getApiBlocCode();
  }

  /// Firebase BLoC implementation
  String _getFirebaseBlocCode() {
    return '''
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _firebaseAuth;

  AuthBloc({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        super(AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthStatusChanged>(_onAuthStatusChanged);
    
    // Listen to auth state changes
    _firebaseAuth.authStateChanges().listen((user) {
      add(AuthStatusChanged(isAuthenticated: user != null));
    });
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      emit(AuthAuthenticated());
    } on FirebaseAuthException catch (e) {
      emit(AuthError(message: _getFirebaseErrorMessage(e)));
    } catch (e) {
      emit(AuthError(message: 'An unexpected error occurred'));
    }
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      emit(AuthAuthenticated());
    } on FirebaseAuthException catch (e) {
      emit(AuthError(message: _getFirebaseErrorMessage(e)));
    } catch (e) {
      emit(AuthError(message: 'An unexpected error occurred'));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _firebaseAuth.signOut();
    emit(AuthUnauthenticated());
  }

  void _onAuthStatusChanged(
    AuthStatusChanged event,
    Emitter<AuthState> emit,
  ) {
    if (event.isAuthenticated) {
      emit(AuthAuthenticated());
    } else {
      emit(AuthUnauthenticated());
    }
  }

  String _getFirebaseErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      default:
        return e.message ?? 'Authentication failed';
    }
  }
}
''';
  }

  /// API BLoC implementation
  String _getApiBlocCode() {
    return '''
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;
  final SharedPreferences _prefs;

  AuthBloc({
    AuthService? authService,
    SharedPreferences? prefs,
  })  : _authService = authService ?? AuthService(),
        _prefs = prefs ?? SharedPreferences.getInstance() as SharedPreferences,
        super(AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthTokenRefreshRequested>(_onTokenRefreshRequested);
    on<AuthStatusChanged>(_onAuthStatusChanged);
    
    _initializeAuth();
  }

  void _initializeAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    if (token != null) {
      try {
        final user = await _authService.getCurrentUser();
        emit(AuthAuthenticated(user: user, token: token));
      } catch (e) {
        await prefs.remove('auth_token');
        emit(AuthUnauthenticated());
      }
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final response = await _authService.login(event.email, event.password);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', response['token']);
      
      final user = UserModel.fromJson(response['user']);
      emit(AuthAuthenticated(user: user, token: response['token']));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final response = await _authService.register(
        event.name,
        event.email,
        event.password,
      );
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', response['token']);
      
      final user = UserModel.fromJson(response['user']);
      emit(AuthAuthenticated(user: user, token: response['token']));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _authService.logout();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onTokenRefreshRequested(
    AuthTokenRefreshRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final newToken = await _authService.refreshToken();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', newToken);
      
      if (state is AuthAuthenticated) {
        final currentState = state as AuthAuthenticated;
        emit(AuthAuthenticated(user: currentState.user, token: newToken));
      }
    } catch (e) {
      emit(AuthError(message: 'Token refresh failed'));
    }
  }

  void _onAuthStatusChanged(
    AuthStatusChanged event,
    Emitter<AuthState> emit,
  ) {
    if (!event.isAuthenticated) {
      emit(AuthUnauthenticated());
    }
  }
}
''';
  }

  /// Login Page code template
  String getLoginPageCode() {
    return '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';
import 'register.dart';

class QuicklitLoginPage extends StatefulWidget {
  const QuicklitLoginPage({super.key});

  @override
  State<QuicklitLoginPage> createState() => _QuicklitLoginPageState();
}

class _QuicklitLoginPageState extends State<QuicklitLoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is AuthAuthenticated) {
            Navigator.of(context).pushReplacementNamed('/home');
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.lock_outline,
                    size: 80,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\\.[^@]+').hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: state is AuthLoading ? null : _login,
                      child: state is AuthLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Login'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const QuicklitRegisterPage(),
                        ),
                      );
                    },
                    child: const Text("Don't have an account? Register here"),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        AuthLoginRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
    }
  }
}
''';
  }

  /// Register Page code template
  String getRegisterPageCode() {
    final isApi = provider == auth_provider.AuthProvider.api;
    return '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';

class QuicklitRegisterPage extends StatefulWidget {
  const QuicklitRegisterPage({super.key});

  @override
  State<QuicklitRegisterPage> createState() => _QuicklitRegisterPageState();
}

class _QuicklitRegisterPageState extends State<QuicklitRegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  ${isApi ? 'final _nameController = TextEditingController();' : ''}
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    ${isApi ? '_nameController.dispose();' : ''}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        centerTitle: true,
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is AuthAuthenticated) {
            Navigator.of(context).pushReplacementNamed('/home');
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.person_add_outlined,
                    size: 80,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 32),
                  ${isApi ? '''
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  ''' : ''}
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\\.[^@]+').hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: state is AuthLoading ? null : _register,
                      child: state is AuthLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Register'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("Already have an account? Login here"),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _register() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        AuthRegisterRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          ${isApi ? 'name: _nameController.text.trim(),' : ''}
        ),
      );
    }
  }
}
''';
  }

  /// Auth Service code template (for API provider)
  String getAuthServiceCode() {
    return '''
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  static const String BASE_URL = 'https://your-api-base-url.com/api';
  
  late final Dio _dio;
  late final SharedPreferences _prefs;

  AuthService() {
    _dio = Dio(BaseOptions(
      baseUrl: BASE_URL,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
      compact: true,
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token');
        
        if (token != null) {
          options.headers['Authorization'] = 'Bearer \$token';
        }
        
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          final refreshed = await _tryRefreshToken();
          if (refreshed) {
            final response = await _dio.fetch(error.requestOptions);
            handler.resolve(response);
            return;
          }
        }
        handler.next(error);
      },
    ));
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Login failed: \${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
      });

      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Registration failed: \${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<UserModel> getCurrentUser() async {
    try {
      final response = await _dio.get('/auth/me');

      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data['user']);
      } else {
        throw Exception('Failed to get user: \${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } on DioException catch (e) {
      print('Logout API call failed: \${e.message}');
    }
  }

  Future<String> refreshToken() async {
    try {
      final response = await _dio.post('/auth/refresh');

      if (response.statusCode == 200) {
        return response.data['token'];
      } else {
        throw Exception('Token refresh failed: \${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<bool> _tryRefreshToken() async {
    try {
      final newToken = await refreshToken();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', newToken);
      return true;
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      return false;
    }
  }

  Exception _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return Exception('Connection timeout');
      case DioExceptionType.receiveTimeout:
        return Exception('Receive timeout');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = e.response?.data['message'] ?? 'Server error';
        
        switch (statusCode) {
          case 400:
            return Exception('Bad request: \$message');
          case 401:
            return Exception('Unauthorized: \$message');
          case 403:
            return Exception('Forbidden: \$message');
          case 404:
            return Exception('Not found: \$message');
          case 422:
            return Exception('Validation error: \$message');
          case 500:
            return Exception('Internal server error');
          default:
            return Exception('Server error: \$message');
        }
      case DioExceptionType.cancel:
        return Exception('Request cancelled');
      case DioExceptionType.unknown:
        return Exception('Network error: \${e.message}');
      default:
        return Exception('Unknown error occurred');
    }
  }
}
''';
  }

  /// User Model code template (for API provider)
  String getUserModelCode() {
    return '''
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final String id;
  final String name;
  final String email;
  @JsonKey(name: 'email_verified_at')
  final String? emailVerifiedAt;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'updated_at')
  final String updatedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.emailVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _\$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _\$UserModelToJson(this);

  @override
  String toString() {
    return 'UserModel(id: \$id, name: \$name, email: \$email, emailVerifiedAt: \$emailVerifiedAt, createdAt: \$createdAt, updatedAt: \$updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.emailVerifiedAt == emailVerifiedAt &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        email.hashCode ^
        emailVerifiedAt.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
''';
  }

  /// Pubspec dependencies template
  String getPubspecDependencies() {
    final isFirebase = provider == auth_provider.AuthProvider.firebase;
    return '''
dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5
  shared_preferences: ^2.2.2
  ${isFirebase ? '''
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  ''' : '''
  dio: ^5.3.4
  pretty_dio_logger: ^1.3.1
  json_annotation: ^4.8.1
  '''}

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  ${isFirebase ? '' : '''
  build_runner: ^2.4.7
  json_serializable: ^6.7.1
  '''}
''';
  }
}