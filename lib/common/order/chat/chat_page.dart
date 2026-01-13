import 'dart:convert';
//import 'dart:developer';

import 'package:brasil_fields/brasil_fields.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:fouryoupet/common/order/chat/widgets/message_tile.dart';
import 'package:fouryoupet/models/order/orders_manager.dart';
import 'package:provider/provider.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;

import 'package:http/http.dart' as http;

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

      String constructFCMPayload(
        String? token,
      ) {
        return jsonEncode(
          <String, dynamic>{
            'message': {
              'token': token,
              'notification': {
                'title': "Nova mensagem do pedido ${widget.groupId}",
                'body': chatMessageMap["message"].toString(),
              },
              'data': {
                'name': chatMessageMap["sender"],
                'click_action': chatMessageMap["click"],
                'type': chatMessageMap['type'],
              },
            },
          },
        );
      }

      for (var i = 0; i < userToken!.length; i++) {
        sendNotificationToSelectedDriver(
            userToken[i], context, constructFCMPayload(userToken[i]));
      }

      
    }
  }

  static sendNotificationToSelectedDriver(
      String deviceToken, BuildContext context, String msg) async {
    final String serverAccessToken = await getAccessToken();
    String endpointFirebaseCloudMessaging =
        'https://fcm.googleapis.com/v1/projects/fouryoupet-c6387/messages:send';

    final http.Response response = await http.post(
      Uri.parse(endpointFirebaseCloudMessaging),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $serverAccessToken',
      },
      body: msg,
    );
    if (response.statusCode == 200) {
      print('Notification sent successfully');
    } else {
      print('Fail, notification not sent: ${response.statusCode}');
    }
  }

  static Future<String> getAccessToken() async {
    final serviceAccontJson = {
      "type": "service_account",
      "project_id": "fouryoupet-c6387",
      "private_key_id": "7dfbdce7013673b0cb5d70a090e9b977cb6a224c",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDAILdusN0pRuXS\ni3x68JzH1Dukql6rZftMHYGDrMSU/RzGq9dcJ9NZ/vGYYVE3WlUBvWgIfLUQhfER\n7u6fJDsUZwm4FMZorzMKrjb99ontmLWdDUTdXmUx/nsgTiloDRWNN35Cr3AmwBci\nEMfLY5qyluUzAVliuH/V4gKUInkvjn7+rkS8T04UfpILx90DU+Hgrj6PoCTCz6Md\nweaOMXiY2tBcwXMb/a3+M8NthLsGyYkZ4ML482uoYSGtCcSniqLv2rv6jPm1ONOq\ncf/Rjywrc0ENaX/gEYtCgJLfPU2kg0WaPZQ6fIMDK7Rb0zMmMOku8qvm/nPBUAaE\nHl60aSdZAgMBAAECggEAA4U98zlqrghSawGbD/Ijf05iYuWryyp42LfUMRZb+kpq\nifHpZfMFXolrQiJrX28oblobA0fMtg8sQAq/pNsgOYMbVJwN2Cp4rhYL5Cqts5S4\nJDbzZ3aEtm4uMaT5AYL23YHyLnTiQlWD/v/td0q9kY7uB3mbepF8py3HZBE/JPnI\ndVp8CqZR8Ur6Kq4p2JJjXI7Dxls3padg9GUl8pEiXF/XyaYoHbMj0W9q2d/UQq8W\nqkX/I2aFcxzN0szqKf3qsopJkSXwELxWH3UVdcCSh1EIhQcDznRlkYKFMTqWqhJW\nnJdG39NLnpsQR5ROp3JShL3hRoB9BsELrk8+OtAekQKBgQDgmzrgiYzmLNdeAahu\nbsuALzXcBOpXgOY+V570VExsrjKkOLhM56ggx0Jlbyz2SnvGK2pb49JzgKMz6gjW\nb3e4nqpQasKSCE806jn4Ly9e7zzQMU2t2TMbSlLZ//h2fpWH8EHiufqU21GqIup9\nmNm9REv7hJYijBYDbU6JRthiqQKBgQDa+1om9gGsZA8+IcS4GmKcKzigjQDkmewJ\nBb+IQey8gYseePIYnkhHCVNr11iefnYH7Ik8BBEzEgYMwcD1RhmJaQqqMkjTxeAV\ne0qsgk+KUi72FUJ3udCn5S/WZcA9aapWa8kf0460wIBX14WBS8sYLxpVmIZsLTDA\nsDx3Uxw9MQKBgFlW5XByxgy4QWIvHqPuhhuSq8W8Xso3h1281IkzDsMb9yDDPuu4\nKXQATjSyqBu/PMRyeHfcgtVWkZQQvzssU16oHe6myIX1sCvIDw7dFeaZGoNlWRSR\nlHaCdbooyte3Ohs8QbjBaR7UrgMSqFsU9WcHR4HgFyfeuNLcI6UO/PshAoGBAMVq\nsuTLBckvz9oYwWukReA6yutbE0IEThn4N6sUm+N5+jy3lrKBB/Iawz1GwBrrMWeF\nZFdZ51OeXRvlFRtKXj1WGIpFmQhqrNFQ/Io3VJQD8Vhi5DBhsW2bnhvwUXZMK4eL\n1p89r7rejRYkM7TT6r3bwScHwbAGsZwVhf2hTKURAoGBALUaO7Tr2D6ilXAp0OaW\nTjuddFQOvW5HqlbI1/BD80HtDTu0HqxymIC4G6okbZ++d/TqfjeoZQKEQM9s1gcJ\nHJrkET8sM1IBT+cukTBjcmBWgS7cxuvaOLq2hpYDnMdvQM+T/IfPkAY8UP7qMVcZ\nihbwvNppZwR1Za3+64Xe6rKG\n-----END PRIVATE KEY-----\n",
      "client_email":
          "fouryoupet-notifications@fouryoupet-c6387.iam.gserviceaccount.com",
      "client_id": "111657539200994957862",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url":
          "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url":
          "https://www.googleapis.com/robot/v1/metadata/x509/fouryoupet-notifications%40fouryoupet-c6387.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    };
    List<String> scopes = [
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/firebase.database",
      "https://www.googleapis.com/auth/firebase.messaging"
    ];
    http.Client client = await auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccontJson),
      scopes,
    );
    //get the access token
    auth.AccessCredentials credentials =
        await auth.obtainAccessCredentialsViaServiceAccount(
            auth.ServiceAccountCredentials.fromJson(serviceAccontJson),
            scopes,
            client);
    client.close();
    return credentials.accessToken.data;
  }
}
