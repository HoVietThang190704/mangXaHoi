import 'package:mangxahoi/Utils.dart';
import 'package:flutter/material.dart';
import 'package:signalr_core/signalr_core.dart';

import '../Components/AppBarComponent.dart';
import '../Components/BottomNavigationBarComponent.dart';

class ChatView extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _chatView();
  }

}
class _chatView extends State<ChatView>{

  _chatView(){
    _loadHubConnect();
  }
  _loadHubConnect() async{
    final connection = HubConnectionBuilder().withUrl('${Utils.baseUrl}/chatHub',
        HttpConnectionOptions(
          logging: (level, message) => print(message),
        )).build();
    await connection.start();
    connection.on('ReceiveMessage', (message) {
      print(message.toString());
    });
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBarComponent("Chat"),
      body: Column(
        children: [
        ],
      ),
      bottomNavigationBar: BottomNavigationBarComponent(),
    );
  }

}