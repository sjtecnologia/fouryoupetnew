import 'dart:io';

import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fouryoupet/screens/edit_company/components/doc_source_sheet.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../../../models/company/company.dart';

class DocumentsForm extends StatefulWidget {
  const DocumentsForm(this.company, {Key? key}) : super(key: key);

  final Company company;

  @override
  State<DocumentsForm> createState() => _DocumentsFormState();
}

class _DocumentsFormState extends State<DocumentsForm> {
  Future<void> _openPdfViewer(BuildContext context, dynamic document) async {
    String documentName;
    String? localPath;

    if (document is File) {
      // Arquivo local
      documentName = document.path.split('/').last;
      localPath = document.path;
    } else if (document is String) {
      // URL do Firebase Storage - fazer download
      documentName = document.split('/').last.split('?').first;

      // Mostrar indicador de carregamento
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      try {
        // Fazer download do PDF
        final response = await http.get(Uri.parse(document));

        if (response.statusCode == 200) {
          // Salvar temporariamente
          final dir = await getTemporaryDirectory();
          final file = File('${dir.path}/$documentName');
          await file.writeAsBytes(response.bodyBytes);
          localPath = file.path;

          // Fechar loading
          Navigator.of(context).pop();
        } else {
          // Fechar loading
          Navigator.of(context).pop();

          // Mostrar erro
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Erro ao carregar documento: ${response.statusCode}'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      } catch (e) {
        // Fechar loading
        Navigator.of(context).pop();

        // Mostrar erro
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao baixar documento: $e'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    } else {
      return;
    }

    // Abrir visualizador com o arquivo local
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(documentName),
            backgroundColor: const Color.fromARGB(255, 255, 111, 0),
          ),
          body: PDFView(
            filePath: localPath!,
            enableSwipe: true,
            swipeHorizontal: false,
            autoSpacing: false,
            pageFling: true,
            pageSnap: true,
            defaultPage: 0,
            fitPolicy: FitPolicy.BOTH,
            preventLinkNavigation: false,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FormField<List<dynamic>>(
      initialValue: List<dynamic>.from(widget.company.documents ?? []),
      validator: (documents) {
        if (documents != null && documents.isNotEmpty) {
          for (var doc in documents) {
            String fileName;
            if (doc is File) {
              fileName = doc.path.toLowerCase();
            } else if (doc is String) {
              fileName = doc.toLowerCase();
            } else {
              continue;
            }

            if (!fileName.endsWith('.pdf')) {
              return 'Apenas arquivos PDF são aceitos';
            }
          }
        }
        return null;
      },
      onSaved: (documents) {
        widget.company.newDocuments = documents;
      },
      builder: (state) {
        void onDocumentSelected(File file) {
          state.value!.add(file);
          state.didChange(state.value);
          Navigator.of(context).pop();
        }

        final List<Widget> documentWidgets =
            state.value!.map<Widget>((documentItem) {
          String displayName;

          if (documentItem is File) {
            displayName = documentItem.path.split('/').last;
          } else if (documentItem is String) {
            displayName = documentItem.split('/').last;
          } else {
            displayName = 'Documento desconhecido';
          }

          return Stack(
            fit: StackFit.expand,
            children: <Widget>[
              // Card com preview do PDF
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Column(
                    children: [
                      // Preview do PDF (ocupa 75% da altura)
                      Expanded(
                        flex: 3,
                        child: documentItem is File
                            ? PDFThumbnailWidget(file: documentItem)
                            : Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.red[50]!,
                                      Colors.red[100]!,
                                    ],
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.picture_as_pdf,
                                      size: 64,
                                      color: Color(0xFFD32F2F),
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.9),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: const [
                                          Icon(
                                            Icons.cloud_done,
                                            size: 16,
                                            color: Color(0xFFD32F2F),
                                          ),
                                          SizedBox(width: 6),
                                          Text(
                                            'Salvo na nuvem',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFFD32F2F),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                      // Informações do documento (ocupa 25% da altura)
                      Expanded(
                        flex: 1,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            border: Border(
                              top: BorderSide(
                                  color: Colors.grey[300]!, width: 1),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.picture_as_pdf,
                                      size: 16, color: Color(0xFFD32F2F)),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      displayName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (documentItem is String) ...[
                                const SizedBox(height: 2),
                                const Text(
                                  'Salvo na Nuvem',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Botão de visualizar (centro)
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.visibility, color: Colors.white),
                    iconSize: 28,
                    onPressed: () => _openPdfViewer(context, documentItem),
                  ),
                ),
              ),

              // Botão de remover (topo direito)
              Positioned(
                top: 8,
                right: 16,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    iconSize: 20,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Confirmar Exclusão'),
                          content: Text('Remover o documento "$displayName"?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                state.value!.remove(documentItem);
                                state.didChange(state.value);
                              },
                              child: const Text('Confirmar',
                                  style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        }).toList();

        documentWidgets.add(
          Material(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                if (state.value!.length >= 5) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('Limite máximo de 5 documentos atingido.')),
                  );
                  return;
                }

                if (Theme.of(context).platform == TargetPlatform.android) {
                  showModalBottomSheet(
                    context: context,
                    builder: (_) =>
                        DocSourceSheet(onDocumentSelected: onDocumentSelected),
                  );
                } else {
                  showCupertinoModalPopup(
                    context: context,
                    builder: (_) =>
                        DocSourceSheet(onDocumentSelected: onDocumentSelected),
                  );
                }
              },
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle_outline,
                        size: 60, color: Theme.of(context).primaryColor),
                    const SizedBox(height: 12),
                    Text(
                      'Adicionar PDF',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).primaryColor),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        return Column(
          children: <Widget>[
            AspectRatio(
              aspectRatio: 1,
              child: CarouselSlider(
                items: documentWidgets,
                options: CarouselOptions(
                  height: MediaQuery.of(context).size.width,
                  enableInfiniteScroll: false,
                  viewportFraction: 0.8,
                  initialPage: 0,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class PDFThumbnailWidget extends StatelessWidget {
  final File file;

  const PDFThumbnailWidget({Key? key, required this.file}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFEEEEEE),
      child: PDFView(
        filePath: file.path,
        enableSwipe: false,
        swipeHorizontal: false,
        autoSpacing: false,
        pageFling: false,
        pageSnap: false,
        defaultPage: 0,
        fitPolicy: FitPolicy.BOTH,
        preventLinkNavigation: true,
      ),
    );
  }
}
