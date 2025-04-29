import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(BudgetApp());
}

class BudgetApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // ← банер DEBUG вимкнено
      title: 'Бюджет Трекер',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.green,
        cardColor: Colors.white,
      ),
      darkTheme: ThemeData.dark(),
      home: BudgetHomePage(),
    );
  }
}

class Transaction {
  final String title;
  final double amount;
  final DateTime date;
  final bool isIncome;

  Transaction({
    required this.title,
    required this.amount,
    required this.date,
    required this.isIncome,
  });
}

class BudgetHomePage extends StatefulWidget {
  @override
  _BudgetHomePageState createState() => _BudgetHomePageState();
}

class _BudgetHomePageState extends State<BudgetHomePage> {
  final List<Transaction> _transactions = [];

  double get _balance {
    return _transactions.fold(0.0, (sum, tx) =>
        sum + (tx.isIncome ? tx.amount : -tx.amount));
  }

  void _addTransaction(String title, double amount, bool isIncome) {
    final tx = Transaction(
      title: title,
      amount: amount,
      date: DateTime.now(),
      isIncome: isIncome,
    );
    setState(() {
      _transactions.insert(0, tx);
    });
  }

  void _showAddDialog() {
    String title = '';
    String amountStr = '';
    bool isIncome = true;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Нова транзакція'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Назва'),
              onChanged: (value) => title = value,
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Сума'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              onChanged: (value) => amountStr = value,
            ),
            Row(
              children: [
                Text('Тип:'),
                SizedBox(width: 10),
                DropdownButton<bool>(
                  value: isIncome,
                  items: [
                    DropdownMenuItem(child: Text('Дохід'), value: true),
                    DropdownMenuItem(child: Text('Витрата'), value: false),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => isIncome = value);
                    }
                  },
                )
              ],
            )
          ],
        ),
        actions: [
          TextButton(
            child: Text('Скасувати'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            child: Text('Додати'),
            onPressed: () {
              final amount = double.tryParse(amountStr);
              if (title.isNotEmpty && amount != null) {
                _addTransaction(title, amount, isIncome);
                Navigator.of(context).pop();
              }
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.simpleCurrency(locale: 'uk_UA');

    return Scaffold(
      appBar: AppBar(
        title: Text('Бюджет Трекер'),
      ),
      body: Column(
        children: [
          Card(
            margin: EdgeInsets.all(16),
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Text('Загальний баланс', style: TextStyle(fontSize: 18)),
                  SizedBox(height: 8),
                  Text(
                    currencyFormat.format(_balance),
                    style: TextStyle(
                      fontSize: 32,
                      color: _balance >= 0 ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: _transactions.isEmpty
                ? Center(child: Text('Немає транзакцій'))
                : ListView.builder(
                    itemCount: _transactions.length,
                    itemBuilder: (ctx, index) {
                      final tx = _transactions[index];
                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        elevation: 2,
                        child: ListTile(
                          leading: Icon(
                            tx.isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                            color: tx.isIncome ? Colors.green : Colors.red,
                          ),
                          title: Text(tx.title),
                          subtitle: Text(DateFormat('dd.MM.yyyy – kk:mm').format(tx.date)),
                          trailing: Text(
                            (tx.isIncome ? '+' : '-') + currencyFormat.format(tx.amount),
                            style: TextStyle(
                              color: tx.isIncome ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: _showAddDialog,
      ),
    );
  }
}
