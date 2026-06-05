import 'dart:ui';

class Category {
  final String name;
  final String emoji;
  final double amount;
  final Color color;
  Category(this.name, this.emoji, this.amount, this.color);
}



class Transaction {
  final String merchant;
  final String category;
  final String emoji;
  final double amount;
  final String date;
  final Color color;
  Transaction(this.merchant, this.category, this.emoji, this.amount, this.date, this.color);
}