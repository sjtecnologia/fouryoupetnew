import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:fouryoupet/helpers/styles/text_styles.dart';
import 'package:fouryoupet/models/user/user_manager.dart';
import 'package:fouryoupet/screens/edit_pet/components/checkboxcastrado.dart';
import 'package:fouryoupet/screens/edit_pet/components/dropdown_gen.dart';
import 'package:intl/intl.dart';

import 'package:provider/provider.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import '../../models/page_manager.dart';
import '../../models/pet/pet.dart'; // Certifique-se que o modelo Pet está na pasta correta
import '../../models/pet/pet_manager.dart'; // Certifique-se que o PetManager está na pasta correta

import 'components/checkboxpedigree.dart'; // Caminho para o componente de checkbox
import 'components/dropdown_category.dart'; // Caminho para o componente de dropdown
import 'components/images_form.dart'; // Caminho para o componente de formulário de imagens

class EditPetScreen extends StatefulWidget {
  EditPetScreen(Pet? p)
      : editing = p != null,
        pet = p != null ? p.clone() : Pet();

  final Pet pet;
  final bool editing;

  @override
  State<EditPetScreen> createState() => _EditPetScreenState();
}

class _EditPetScreenState extends State<EditPetScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Função para fechar o teclado
  void _closeKeyboard() {
    FocusScope.of(context).unfocus();
  }

  // Função auxiliar para Input Decoration de campos de texto
  InputDecoration _buildTextFormFieldDecoration(
      String labelText, String hintText) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: const TextStyle(
        color: Colors.grey,
      ),
      hintText: hintText,
      border: InputBorder.none,
    );
  }

  // Função auxiliar para Input Decoration de campos de data
  InputDecoration _buildDateTimePickerDecoration(String labelText) {
    return InputDecoration(
      label: Text(
        labelText,
        style: const TextStyle(
          color: Colors.black54,
        ),
      ),
      border: InputBorder.none,
      prefixIcon: const Icon(
        Icons.calendar_today_sharp,
        color: Colors.grey,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: widget.pet,
      child: GestureDetector(
        // Detecta toque fora dos campos para fechar o teclado
        onTap: _closeKeyboard,
        child: Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.white),
            foregroundColor: Colors.white,
            title: Text(widget.editing ? 'Editar Pet' : 'Cadastrar Pet',
                style: const TextStyle(color: Colors.white)),
            centerTitle: true,
            actions: <Widget>[
              if (widget.editing)
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.white),
                  onPressed: () {
                    _closeKeyboard(); // Fecha o teclado antes de abrir o dialog
                    showDialog(
                      context: context,
                      builder: (dialogContext) {
                        // Use dialogContext para evitar confusão
                        return AlertDialog(
                          title: const Text('Confirmar'),
                          content: const Text(
                            'Confirmar a exclusão do pet?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(dialogContext); // Volta do dialog
                              },
                              child: Text(
                                'Cancelar',
                                style: context.textStyles.textBold
                                    .copyWith(color: Colors.red),
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                Navigator.pop(dialogContext); // Volta do dialog
                                // Assegure-se de que o contexto ainda é válido antes de usar
                                if (!mounted) return;
                                try {
                                  context.read<PetManager>().delete(widget.pet);
                                  showTopSnackBar(
                                    Overlay.of(context),
                                    const CustomSnackBar.success(
                                      message: "Pet excluído com sucesso!",
                                    ),
                                  );
                                  if (mounted) {
                                    Navigator.of(context)
                                        .pop(); // Volta para a tela anterior
                                  }
                                } catch (e) {
                                  debugPrint('Erro ao excluir pet: $e');
                                  if (mounted) {
                                    showTopSnackBar(
                                      Overlay.of(context),
                                      CustomSnackBar.error(
                                        message:
                                            "Falha ao excluir: ${e.toString()}",
                                      ),
                                    );
                                  }
                                }
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
                  _closeKeyboard(); // Fecha o teclado antes de navegar
                  context.read<PageManager>().setPage(0);
                  // Se necessário, feche telas abertas
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                icon: const Icon(Icons.home, color: Colors.white),
              ),
            ],
          ),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 255, 111, 0),
                  Color.fromARGB(255, 255, 161, 0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Form(
              key: formKey,
              child: ListView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior
                    .onDrag, // Fecha o teclado ao arrastar
                children: <Widget>[
                  // Certifique-se de que ImagesForm não precisa de argumentos posicionais,
                  // ou ajuste se ele espera um Pet.
                  // Se o componente ImagesForm precisar do pet para carregar imagens, ajuste assim:
                  // ImagesForm(pet: widget.pet),
                  ImagesForm(), // Se ImagesForm não requer argumentos posicionais
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        DropDownCategory(widget.pet),
                        DropDownGen(widget.pet),
                        MyCheckboxPedigree(widget.pet),
                        MyCheckboxCastrado(widget.pet),
                        TextFormField(
                          maxLines: 1,
                          initialValue: widget.pet.name,
                          decoration: _buildTextFormFieldDecoration(
                              'Nome do Pet', 'Nome do Pet'),
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                          validator: (name) {
                            if (name == null || name.trim().isEmpty) {
                              return 'Nome do Pet não pode ser vazio';
                            }
                            return null;
                          },
                          onSaved: (name) => widget.pet.name = name,
                          textInputAction:
                              TextInputAction.next, // Adiciona ação de próximo
                          onFieldSubmitted: (_) => FocusScope.of(context)
                              .nextFocus(), // Move para próximo campo
                        ),
                        TextFormField(
                          initialValue: widget.pet.breed,
                          maxLines: 1,
                          decoration:
                              _buildTextFormFieldDecoration('Raça', 'Raça'),
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                          validator: (name) {
                            if (name == null || name.trim().isEmpty) {
                              return 'Nome da raça não pode ser vazio';
                            }
                            return null;
                          },
                          onSaved: (breed) => widget.pet.breed = breed,
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) =>
                              FocusScope.of(context).nextFocus(),
                        ),
                        TextFormField(
                          initialValue: widget.pet.color,
                          maxLines: 1,
                          decoration:
                              _buildTextFormFieldDecoration('Cor', 'Cor'),
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                          validator: (name) {
                            if (name == null || name.trim().isEmpty) {
                              return 'Nome da cor não pode ser vazio';
                            }
                            return null;
                          },
                          onSaved: (color) => widget.pet.color = color,
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) =>
                              FocusScope.of(context).nextFocus(),
                        ),
                        TextFormField(
                          initialValue: widget.pet.size,
                          maxLines: 1,
                          decoration:
                              _buildTextFormFieldDecoration('Porte', 'Porte'),
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                          validator: (name) {
                            if (name == null || name.trim().isEmpty) {
                              return 'Descrição do Porte não pode ser vazio';
                            }
                            return null;
                          },
                          onSaved: (size) => widget.pet.size = size,
                          textInputAction:
                              TextInputAction.done, // Último campo de texto
                          onFieldSubmitted: (_) =>
                              _closeKeyboard(), // Fecha o teclado
                        ),
                        FormBuilderDateTimePicker(
                          // Defina um intervalo de datas razoável para nascimento de pets
                          firstDate: DateTime.now().subtract(
                              const Duration(days: 365 * 25)), // 25 anos atrás
                          lastDate: DateTime.now(), // Não permite datas futuras
                          validator: (birth) {
                            if (birth == null) {
                              return 'Deve ser informada a data de Nascimento do seu Pet';
                            }
                            return null;
                          },
                          name: 'birth',
                          style: const TextStyle(
                            color: Colors.black,
                          ),
                          initialValue: widget.pet.birth,
                          fieldHintText: 'Data de Nascimento do Pet',
                          locale: const Locale('pt', 'BR'),
                          inputType: InputType.date,
                          format: DateFormat('dd/MM/yyyy'),
                          fieldLabelText: 'Data de Nascimento do Pet',
                          decoration: _buildDateTimePickerDecoration(
                              'Data de Nascimento do Pet'),
                          onSaved: (birth) => widget.pet.birth = birth,
                          onChanged: (_) =>
                              _closeKeyboard(), // Fecha o teclado ao selecionar data
                        ),
                        FormBuilderDateTimePicker(
                          // Defina um intervalo de datas razoável para início de vacinação
                          firstDate: DateTime.now().subtract(
                              const Duration(days: 365 * 25)), // 25 anos atrás
                          lastDate: DateTime.now(), // Não permite datas futuras
                          validator: (datainivacinas) {
                            if (datainivacinas == null) {
                              return 'Deve ser informada a data de Início da vacinação do seu Pet';
                            }
                            return null;
                          },
                          name: 'datainivacinas',
                          style: const TextStyle(
                            color: Colors.black,
                          ),
                          initialValue: widget.pet.datainivacinas,
                          fieldHintText: 'Data de Início da Vacinação do Pet',
                          locale: const Locale('pt', 'BR'),
                          inputType: InputType.date,
                          format: DateFormat('dd/MM/yyyy'),
                          fieldLabelText: 'Data de Início da Vacinação do Pet',
                          decoration: _buildDateTimePickerDecoration(
                              'Data de Início da Vacinação do Pet'),
                          onSaved: (datainivacinas) =>
                              widget.pet.datainivacinas = datainivacinas,
                          onChanged: (_) =>
                              _closeKeyboard(), // Fecha o teclado ao selecionar data
                        ),
                        const SizedBox(
                            height: 20), // Espaçamento antes do botão
                        Consumer<Pet>(
                          builder: (_, pet, __) {
                            return SizedBox(
                              height: 44,
                              child: ElevatedButton(
                                onPressed: !pet.loading
                                    ? () async {
                                        // Fecha o teclado antes de processar
                                        _closeKeyboard();

                                        if (formKey.currentState!.validate()) {
                                          // Salva os dados do formulário
                                          formKey.currentState!.save();

                                          final userManager =
                                              context.read<UserManager>();
                                          if (userManager.userapp == null ||
                                              userManager.userapp!.id == null) {
                                            if (mounted) {
                                              showTopSnackBar(
                                                Overlay.of(context),
                                                const CustomSnackBar.error(
                                                  message:
                                                      "Usuário não logado. Por favor, faça login novamente.",
                                                ),
                                              );
                                            }
                                            return; // Interrompe o processo se o usuário não estiver logado
                                          }

                                          // Define o user_id (agora com verificação)
                                          pet.user_id = userManager.userapp!.id;

                                          try {
                                            // Tenta salvar o pet
                                            await pet.save();

                                            // Verifica se o widget ainda está montado antes de usar o contexto
                                            if (!mounted) return;

                                            // Atualiza o PetManager
                                            context
                                                .read<PetManager>()
                                                .update(pet);

                                            // Mostra mensagem de sucesso
                                            showTopSnackBar(
                                              Overlay.of(context),
                                              const CustomSnackBar.success(
                                                message: "Salvo com sucesso",
                                              ),
                                            );

                                            // Navega de volta
                                            if (mounted) {
                                              Navigator.of(context).pop();
                                            }
                                          } catch (e) {
                                            // Tratamento de erro
                                            debugPrint(
                                                'Erro ao salvar pet: $e');

                                            if (!mounted) return;

                                            // Mostra mensagem de erro
                                            showTopSnackBar(
                                              Overlay.of(context),
                                              CustomSnackBar.error(
                                                message:
                                                    "Falha ao salvar: ${e.toString()}",
                                              ),
                                            );
                                          }
                                        }
                                      }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: Theme.of(context)
                                      .primaryColor
                                      .withAlpha(100),
                                ),
                                child: pet.loading
                                    ? const CircularProgressIndicator.adaptive(
                                        valueColor: AlwaysStoppedAnimation(
                                            Colors.white),
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
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
