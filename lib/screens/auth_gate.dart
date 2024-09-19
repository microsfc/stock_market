import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stock_market/screens/home_screen.dart';

import '../blocs/auth_cubit.dart';
import '../blocs/market_cubit.dart';
import '../blocs/user_cubit.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(),
      child: BlocBuilder<AuthBloc, AuthenticationState>(
        builder: (context, authState) {
          if (authState is Authenticated) {
            return MultiBlocProvider(
              providers: [
                BlocProvider(create: (context) => MarketBloc()),
                BlocProvider(create: (context) => UserBloc()),
              ],
              child: HomeScreen(user: authState.user),
            );
          } else if (authState is Unauthenticated) {
            return SignInScreen(
              providers: [EmailAuthProvider()],
              actions: [
                AuthStateChangeAction<SignedIn>((context, state) {
                  print('SIGNEDIN');
                  //BlocProvider.of<AuthBloc>(context).handleSignIn(state.user);
                }),
                AuthStateChangeAction<UserCreated>((context, state) async {
                  print('USERCREATED');
                  await BlocProvider.of<AuthBloc>(context)
                      .handleUserCreation(state.credential);
                }),
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
