import 'dart:ffi';

import 'package:json_book_detail/modules/book.dart';

class BookResponse{

  int? totalItems;
  List<Book>? items;

  BookResponse({this.totalItems, this.items});

  factory BookResponse.fromJson(Map<String, dynamic> json) {
    var bookResponse = BookResponse();
    bookResponse.totalItems = json['totalItems'];
    bookResponse.items = [];
    for (var bookJson in (json['items'] as List<dynamic>)) {
      var bookMap = bookJson as Map<String, dynamic>;
      bookResponse.items?.add(Book.fromJson(bookMap));
    }
    return bookResponse;
  }
}