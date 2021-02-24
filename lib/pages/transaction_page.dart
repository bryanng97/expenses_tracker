import 'package:expenses_tracker/pages/home.dart';
import 'package:expenses_tracker/services/transactions_provider.dart';
import 'package:expenses_tracker/widgets/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class TransactionPage extends StatefulWidget {
  final String id;

  TransactionPage(this.id);

  @override
  _TransactionPageState createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  final _txFormKey = GlobalKey<FormState>();
  final _selectedDateController = TextEditingController();
  bool _validate = false;
  bool _isLoading = false;
  var _userTransaction;

  Map<String, String> _txData = {
    'title': '',
    'amount': '',
    'selectedDate': '',
  };

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.id.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      () async {
        try {
          await Provider.of<TransactionProvider>(context, listen: false)
              .getTransaction(widget.id)
              .whenComplete(() {
            setState(() {
              _userTransaction =
                  Provider.of<TransactionProvider>(context, listen: false)
                      .trxRecord;

              if (_userTransaction[0].date != null) {
                _selectedDateController.text = _userTransaction[0].date;
              }
            });
          }).catchError((err) {
            print(err);
          });
        } catch (err) {
          print(err);
        } finally {
          setState(() {
            _isLoading = false;
          });
        }
      }();
    }
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
        widget.id,
      )
          .catchError((err) {
        print(err);
      }).whenComplete(() {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => HomePage()),
            (Route<dynamic> route) => false);
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
      showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (BuildContext context, Widget child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child,
          );
        },
      ).then((time) {
        setState(() {
          _selectedDateController.text =
              "${pickedDate.year}-${pickedDate.month}-${pickedDate.day} ${time.hour.toString().padLeft(2, "0")}:${time.minute.toString().padLeft(2, "0")}";
        });
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
      appBar: appBar(
          context, widget.id.isNotEmpty ? "Edit Expenses" : "Add Expenses"),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                        initialValue: widget.id.isNotEmpty &&
                                _userTransaction[0].title != null
                            ? _userTransaction[0].title
                            : '',
                        decoration: InputDecoration(
                          labelText: 'Title',
                          errorText: _validate ? '' : null,
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter title';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _txData['title'] = value;
                        },
                      ),
                      TextFormField(
                        initialValue: widget.id.isNotEmpty &&
                                _userTransaction[0].amount != null
                            ? _userTransaction[0].amount.toStringAsFixed(2)
                            : '',
                        decoration: InputDecoration(
                          prefixText: 'RM ',
                          labelText: 'Amount',
                          errorText: _validate ? '' : null,
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter amount';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.number,
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
                        child: Text('Save'),
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
