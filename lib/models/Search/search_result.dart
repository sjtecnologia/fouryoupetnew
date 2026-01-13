class SearchResult {
  final String id;
  final String name;
  final String? description;
  final String?
      companyName; // Inclua o nome da empresa para facilitar a identificação
  final String? companyID;
  final String type; // 'company', 'product' ou 'service'

  SearchResult({
    required this.id,
    required this.name,
    this.description,
    this.companyName,
    this.companyID,
    required this.type,
  });
}
