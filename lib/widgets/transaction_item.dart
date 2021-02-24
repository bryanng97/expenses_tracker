import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../pages/home.dart';
import '../pages/transaction_page.dart';
import '../models/transactions.dart';

class TransactionItem extends StatefulWidget {
  const TransactionItem({
    Key key,
    @required this.transaction,
    @required this.deleteTx,
  }) : super(key: key);

  final Transactions transaction;
  final Function deleteTx;

  @override
  _TransactionItemState createState() => _TransactionItemState();
}

class _TransactionItemState extends State<TransactionItem> {
  final databaseReference = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (BuildContext context) => TransactionPage(widget.transaction.id),
          ),
        );
      },
      child: Card(
        elevation: 5,
        margin: EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 5,
        ),
        child: ListTile(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.transaction.title,
              ),
              Text(
                'RM ${widget.transaction.amount.toStringAsFixed(2)}',
              ),
              SizedBox(
                height: 5,
              )
            ],
          ),
          subtitle: Text(widget.transaction.date),
          trailing: IconButton(
            icon: Icon(Icons.delete_forever, size: 30,),
            color: Theme.of(context).errorColor,
            onPressed: () {
              return showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      title: Text('Confirm Delete'),
                      content:
                          Text('Do you sure want to delete this transaction?'),
                      actions: [
                        FlatButton(
                          onPressed: () async {
                            await databaseReference
                                .collection('transaction')
                                .doc(widget.transaction.id.toString())
                                .delete()
                                .whenComplete(() {
                              widget.deleteTx(widget.transaction.id);
                              Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (context) => HomePage()),
                                  (Route<dynamic> route) => false);
                            });
                          },
                          child: Text('Yes'),
                        ),
                        FlatButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('No'),
                        ),
                      ],
                    );
                  });
            },
          ),
        ),
      ),
    );
  }
}
