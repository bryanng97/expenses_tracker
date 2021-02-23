import 'package:expenses_tracker/models/transactions.dart';
import 'package:expenses_tracker/models/users.dart';
import 'package:expenses_tracker/pages/home.dart';
import 'package:expenses_tracker/services/transactions_provider.dart';
import 'package:expenses_tracker/services/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<Users> _user;
    List<Transactions> _trx;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: UserProvider(_user),
        ),
        ChangeNotifierProvider.value(
          value: TransactionProvider(_trx),
        )
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Personal Expenses',
        theme: ThemeData.dark(),
        home: HomePage(),
      ),
    );
  }
}
