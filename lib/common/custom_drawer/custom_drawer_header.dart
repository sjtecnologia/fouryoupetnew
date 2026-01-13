import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fouryoupet/models/page_manager.dart';
import 'package:fouryoupet/models/user/user_manager.dart';

class CustomDrawerHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserManager>(
      builder: (_, userManager, __) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              //color: Colors.white,
              child: SizedBox(
                width: 100,
                height: 100,
                child: Image.asset('images/4YOUPET/logo app smal.png'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                userManager.isLoggedIn && userManager.userapp?.name != null
                    ? 'Olá, ${userManager.userapp!.name}'
                    : 'Bem-vindo!',
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextButton(
                onPressed: () {
                  if (userManager.isLoggedIn) {
                    context.read<PageManager>().setPage(0);
                    userManager.signOut();
                  } else {
                    Navigator.of(context).pushReplacementNamed(
                        '/login'); //  pushNamed('/login');
                  }
                },
                child: Text(
                  userManager.isLoggedIn ? 'Sair' : 'Entre ou cadastre-se >',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
