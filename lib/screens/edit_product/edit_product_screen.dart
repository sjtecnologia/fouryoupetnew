import 'package:flutter/material.dart';
import 'package:fouryoupet/helpers/styles/text_styles.dart';

import 'package:provider/provider.dart';
import 'package:fouryoupet/models/product/product.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import '../../models/page_manager.dart';
import '../../models/product/product_manager.dart';
import 'components/dropdown.dart';
import 'components/images_form.dart';
import 'components/sizes_form.dart';

class EditProductScreen extends StatelessWidget {
  EditProductScreen(Product? p)
      : editing = p != null,
        product = p != null ? p.clone() : Product();

  final Product product;
  final bool editing;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    return ChangeNotifierProvider.value(
      value: product,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: primaryColor,
          title: Text(editing ? 'Editar Produto' : 'Cadastrar Produto',
              style: TextStyle(color: Colors.white)),
          centerTitle: true,
          actions: <Widget>[
            if (editing)
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Confirmar'),
                        content: Text(
                          'Confirmar a exclusão do produto',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Cancelar',
                              style: context.textStyles.textBold
                                  .copyWith(color: Colors.red),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              context.read<ProductManager>().delete(product);
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              'Confirmar',
                              style: context.textStyles.textBold,
                            ),
                          )
                        ],
                      );
                    },
                  );
                },
              ),
            IconButton(
              onPressed: () {
                context.read<PageManager>().setPage(0);
                // Se necessário, feche telas abertas
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              icon: Icon(Icons.home),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        body: Form(
          key: formKey,
          child: ListView(
            children: <Widget>[
              ImagesForm(product),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    SizedBox(
                      width: 50,
                    ),
                    DropDown(product),
                    TextFormField(
                      initialValue: product.name,
                      decoration: const InputDecoration(
                        hintText: 'Nome do Produto',
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w600),
                      validator: (name) {
                        if (name!.length < 6) {
                          return 'Título muito curto';
                        }
                        return null;
                      },
                      onSaved: (name) => product.name = name!.toUpperCase(),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'A partir de',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Text(
                      'R\$ ...',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    TextFormField(
                      initialValue: product.description,
                      decoration: const InputDecoration(
                        hintText: 'Descrição',
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w600),
                      validator: (description) {
                        if (description!.length < 10) {
                          return 'Descrição muito curta';
                        }
                        return null;
                      },
                      onSaved: (description) =>
                          product.description = description!.toUpperCase(),
                    ),
                    SizesForm(product),
                    const SizedBox(
                      height: 20,
                    ),
                    Consumer<Product>(
                      builder: (_, product, __) {
                        return SizedBox(
                          height: 44,
                          child: ElevatedButton(
                            onPressed: !product.loading
                                ? () async {
                                    product.companyID = context
                                        .read<ProductManager>()
                                        .user!
                                        .companyID;
                                    if (formKey.currentState!.validate()) {
                                      formKey.currentState!.save();
                                      await product.save();
                                      context
                                          .read<ProductManager>()
                                          .update(product);
                                      showTopSnackBar(
                                        Overlay.of(context),
                                        CustomSnackBar.success(
                                          message: "Salvo com sucesso",
                                        ),
                                      );
                                      Navigator.of(context).pop();
                                    }
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor:
                                  Theme.of(context).primaryColor.withAlpha(100),
                            ),
                            child: product.loading
                                ? const CircularProgressIndicator.adaptive(
                                    valueColor:
                                        AlwaysStoppedAnimation(Colors.white),
                                  )
                                : const Text(
                                    'Salvar',
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
