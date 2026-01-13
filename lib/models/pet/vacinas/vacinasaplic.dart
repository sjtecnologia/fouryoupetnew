class Vacinasaplic {
  bool? aplicated;
  bool incnewaplic = true;
  bool? aplicatednew;
  DateTime? dataaplicacao;
  DateTime? dtaplicnews;
  String? marca;
  String? lote;
  int? scheduleid;
  Vacinasaplic(
      {this.aplicated,
      this.incnewaplic = true,
      this.dataaplicacao,
      this.marca,
      this.lote,
      this.scheduleid});
  Vacinasaplic.fromMap(Map<String, dynamic> map) {
    aplicated = map['aplicated'] == null ? false : map['aplicated'] as bool?;
    dataaplicacao = map['dataaplicacao'].toDate() as DateTime?;

    marca = map['marca'] as String?;
    lote = map['lote'] as String?;
    scheduleid = map['scheduleid'] == null ? 0 : map['scheduleid'] as int?;
  }
  Map<String, dynamic> toMap() {
    return {
      'aplicated': aplicated,
      'dataaplicacao': dataaplicacao,
      'marca': marca,
      'lote': lote,
      'scheduleid': scheduleid,
    };
  }
}
