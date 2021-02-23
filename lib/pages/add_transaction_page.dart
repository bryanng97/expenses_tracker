import 'package:expenses_tracker/services/transactions_provider.dart';
import 'package:expenses_tracker/widgets/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AddTransactionPage extends StatefulWidget {
  @override
  _AddTransactionPageState createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _txFormKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _selectedDateController = TextEditingController();
  bool _validate = false;

  Map<String, String> _txData = {
    'title': '',
    'amount': '',
    'selectedDate': '',
  };

  @override
  void dispose() {
    super.dispose();
  }

  void _submitData() {
    if (!_txFormKey.currentState.validate()) {
      return;
    }

    _txFormKey.currentState.save();

    Future.delayed(Duration.zero).then((value) async {
      await Provider.of<TransactionProvider>(context, listen: false)
          .addTransaction(
        _txData['title'],
        _txData['amount'],
        _txData['selectedDate'],
      )
          .catchError((err) {
        print(err);
      }).whenComplete(() {
        Navigator.of(context).pop(true);
      });
    });
  }

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2019),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      setState(() {
        _selectedDateController.text = DateFormat("yyyy-MM-dd").format(pickedDate);
      });
    });
    print('...');
  }

  void checkValidate(controller) {
    controller.text.isEmpty ? _validate = true : _validate = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            top: 10,
            left: 10,
            right: 10,
            bottom: MediaQuery.of(context).viewInsets.bottom + 10,
          ),
          child: Form(
            key: _txFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    errorText: _validate ? '' : null,
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please Enter Title';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _txData['title'] = value;
                  },
                ),
                TextFormField(
                  controller: _amountController,
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    errorText: _validate ? '' : null,
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please Enter Title';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.number,
                  inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                  onSaved: (value) {
                    _txData['amount'] = value;
                  },
                ),
                InkWell(
                  onTap: () {
                    FocusManager.instance.primaryFocus.unfocus();
                    _presentDatePicker();
                  },
                  child: IgnorePointer(
                    child: TextFormField(
                      controller: _selectedDateController,
                      decoration: InputDecoration(
                        labelText: 'Date',
                        errorText: _validate ? '' : null,
                        suffixIcon: Icon(
                          Icons.calendar_today,
                        ),
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please choose a date';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _txData['selectedDate'] = value;
                      },
                    ),
                  ),
                ),
                RaisedButton(
                  child: Text('Add'),
                  onPressed: _submitData,
                  textColor: Theme.of(context).cardColor,
                  color: Theme.of(context).accentColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
