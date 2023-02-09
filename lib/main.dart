import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:json_book_detail/modules/book.dart';
import 'package:json_book_detail/modules/book_response.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.lime,
          scaffoldBackgroundColor: Color(0xfff0f4c0)),
        themeMode: ThemeMode.system,
        home: HomeScreen()
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  BookResponse? response;
  bool isLoading = false;

  TextEditingController textEditController = TextEditingController();
  var value;
  // @override
  // void initState(){
  //   super.initState();
  //   _getBooks();
  // }

  _getBooks() async {
    setState(() {
      isLoading = true;
    });
    try {
      //value = textEditController.text;
      var url = Uri.parse(
          'https://www.googleapis.com/books/v1/volumes?q=${textEditController.text}');
      var response = await http.get(url);
      var responseSTR = response.body;
      var decodedJson = jsonDecode(responseSTR);
      setState(() {
        this.response = BookResponse.fromJson(decodedJson);
      });
    } catch (e) {
      print(e);
      setState(() {
        this.response = null;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Books'),
        ),
        body: Column(

          children: [
            Row(
              children: [
                Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 3,top: 10,right: 5),
                  padding: EdgeInsets.all(3),
                  decoration: BoxDecoration(color: Color(0xfff9fbe0)
                      ,borderRadius: BorderRadius.all(Radius.circular(20)), border: Border.all(color: Color(0xfff9fbe9))
                  ),
                  child: TextField(controller: textEditController,style: TextStyle(fontWeight: FontWeight.normal),
                  decoration: InputDecoration(hintText: "Enter book type",hintStyle: TextStyle(color: Colors.lime[300],fontWeight: FontWeight.normal)
                  ,border: InputBorder.none),
                  ),
                )
                ),
                Container(
                  margin: EdgeInsets.only(right: 5,top: 5),
                  child: ElevatedButton(onPressed: (){
                    _getBooks();
                  },
                      child: Text('Click!')),
                ),
              ],
            ),
              if(!isLoading)
              Expanded(
              child: ListView.builder(itemCount: response?.items?.length ?? 0,
                itemBuilder: (_, index) => ListTile(
                  onTap: ()=>
                  {
                    Navigator.push(context, MaterialPageRoute(
                        builder: (_) =>
                            BookDetails(
                                bookList: (response?.items![index])!)))
                  },
                  title:
                  Text(response?.items![index].volumeInfo?.title ?? ""),
                  subtitle: Text(
                      response?.items![index].volumeInfo?.authors?.first ??
                          ""),
                  leading: Image.network(response?.items![index].volumeInfo?.imageLinks?.thumbnail ??
                      ""),

                ),

              ),
            ),
            if(isLoading)
              Center(child: CircularProgressIndicator())
          ],
        ));

  }

}

class BookDetails extends StatefulWidget{
  //String? bookId;
  Book bookList;


  BookDetails({required this.bookList});

  @override
  State<BookDetails> createState() => _BookDetailsState();
}

class _BookDetailsState extends State<BookDetails> {

  //var book = widget.bookList;

   late Book book;
   bool isLoading = false;
   @override
  void initState() {
    // TODO: implement initState
    super.initState();
    book = widget.bookList;
    _getBookDetail();
  }

  _getBookDetail() async {
     setState(() {
       isLoading = true;
     });

     try{
       var uri = Uri.parse("https://www.googleapis.com/books/v1/volumes/${book.id}");
       var response = await http.get(uri);
       var reponseStr = response.body;
       var jsonDecoded = jsonDecode(reponseStr);

       setState(() {
         book = Book.fromJson(jsonDecoded);
       });

     }
     catch(e){
       setState(() {
         book = widget.bookList;
       });
     }

     setState(() {
       isLoading = false;
     });

}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book Detail Page'),

      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Text(book.volumeInfo?.title ?? ""),
            Image.network(book.volumeInfo?.imageLinks?.extraLarge ??
                book.volumeInfo?.imageLinks?.thumbnail ?? ""),
            Text(book.volumeInfo?.authors?.first ?? ""),
            if(isLoading) CircularProgressIndicator()
          ],
        ),
      ),

    );
  }
}
