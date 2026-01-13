import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;

import 'package:http/http.dart' as http;

class PushNotificationService {
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
      body: jsonEncode(msg),
    );
    if (response.statusCode == 200) {
      print('Notification sent successfully');
    } else {
      print('Fail, notification not sent: ${response.statusCode}');
    }
  }
}
