//import 'dart:developer';

import 'package:brasil_fields/brasil_fields.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:fouryoupet/common/order/chat/widgets/message_tile.dart';
import 'package:fouryoupet/models/order/orders_manager.dart';
import 'package:provider/provider.dart';


class ChatPage extends StatefulWidget {
  final String groupId;

  final String userName;
  final List<String>? userToken;
  const ChatPage(
      {Key? key,
      required this.groupId,
      required this.userName,
      required this.userToken})
      : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  FocusNode myFocusNode = FocusNode();
  Stream<QuerySnapshot>? chats;
  TextEditingController messageController = TextEditingController();

  String admin = "";

  @override
  void initState() {
    super.initState();
    getChatandAdmin();

    myFocusNode.addListener(() {
      if (myFocusNode.hasFocus) {
        Future.delayed(
          const Duration(seconds: 1),
          () {
            scrollDown();
          },
        );
      }
    });

    Future.delayed(
      const Duration(seconds: 1),
      () => scrollDown(),
    );
  }

  @override
  void dispose() {
    super.dispose();
    myFocusNode.dispose();
    messageController.dispose();
    _scrollController.dispose();
  }

  getChatandAdmin() {
    OrdersManager().getChats(widget.groupId).then((val) {
      setState(() {
        chats = val;
      });
    });
  }

  final ScrollController _scrollController = ScrollController();
  void scrollDown() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 200,
          duration: const Duration(milliseconds: 500),
          curve: Curves.fastOutSlowIn,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Visibility(
        visible: (!_scrollController.hasClients),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(shape: StadiumBorder()),
          onPressed: () {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 500),
              curve: Curves.fastOutSlowIn,
            );
            setState(() {});
          },
          child: Container(
            child: Icon(
              FluentIcons.arrow_download_48_regular,
              color: Colors.green,
            ),
          ),
        ),
      ),
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: Text(
          'Chat do Pedido ${widget.groupId}',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          // chat messages here
          Expanded(
            child: chatMessages(),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            width: MediaQuery.of(context).size.width,
            color: Colors.grey[400],
            child: Row(children: [
              Expanded(
                  child: TextFormField(
                controller: messageController,
                focusNode: myFocusNode,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  hintText: "Mensagem...",
                  hintStyle: TextStyle(color: Colors.black, fontSize: 16),
                  border: InputBorder.none,
                ),
              )),
              const SizedBox(
                width: 12,
              ),
              GestureDetector(
                onTap: () async {
                  await sendMessage(widget.userToken);
                },
                child: Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Center(
                      child: Icon(
                    Icons.send,
                    color: Colors.white,
                  )),
                ),
              )
            ]),
          )
        ],
      ),
    );
  }

  chatMessages() {
    return StreamBuilder(
      stream: chats,
      builder: (context, AsyncSnapshot snapshot) {
        return snapshot.hasData
            ? CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => MessageTile(
                        message: snapshot.data.docs[index]['message'],
                        sender: snapshot.data.docs[index]['sender'],
                        sentByMe: widget.userName ==
                            snapshot.data.docs[index]['sender'],
                        time: UtilData.obterHoraHHMMSS(
                            DateTime.fromMillisecondsSinceEpoch(
                                snapshot.data.docs[index]['time'])),
                        lido: snapshot.data.docs[index]['lido'] as bool,
                        orderId: widget.groupId,
                        userName: widget.userName,
                      ),
                      childCount: snapshot.data.docs.length,
                    ),
                  ),
                ],
                reverse: false,
              )
            : Container();
      },
    );
  }

sendMessage(List<String>? userToken) async {
    if (messageController.text.isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
        "message": messageController.text,
        "sender": widget.userName,
        "time": DateTime.now().millisecondsSinceEpoch,
        "type": 'order',
        "click": widget.groupId,
        "lido": false,
      };

      context
          .read<OrdersManager>()
          .order
          .sendMessage(widget.groupId, chatMessageMap);
      setState(() {
        messageController.clear();
        Future.delayed(const Duration(milliseconds: 500));
        scrollDown();
      });

      if (userToken != null && userToken.isNotEmpty) {
        final callable =
            FirebaseFunctions.instance.httpsCallable('sendChatNotification');
        for (final token in userToken) {
          callable.call(<String, dynamic>{
            'token': token,
            'title': 'Nova mensagem do pedido ${widget.groupId}',
            'body': chatMessageMap['message'].toString(),
            'data': {
              'name': chatMessageMap['sender'] ?? '',
              'click_action': chatMessageMap['click'] ?? '',
              'type': chatMessageMap['type'] ?? '',
            },
          }).catchError((dynamic e) {
            debugPrint('Erro ao enviar notificação: $e');
          });
        }
      }
    }
  }
}
