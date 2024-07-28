class CoinModel {
  final int chainId;
  final String symbol;
  final String name;
  final String address;
  final int decimals;
  final String logoURI;
  final List<String> providers;
  final bool eip2612;
  final bool isFoT;
  final List<String> tags;

  CoinModel({
    required this.chainId,
    required this.symbol,
    required this.name,
    required this.address,
    required this.decimals,
    required this.logoURI,
    required this.providers,
    required this.eip2612,
    required this.isFoT,
    required this.tags,
  });

  // Factory constructor to create a Token from JSON
  factory CoinModel.fromJson(Map<String, dynamic> json) {
    return CoinModel(
      chainId: json['chainId'],
      symbol: json['symbol'],
      name: json['name'],
      address: json['address'],
      decimals: json['decimals'],
      logoURI: json['logoURI'],
      providers: List<String>.from(json['providers']),
      eip2612: json['eip2612'],
      isFoT: json['isFoT'],
      tags: List<String>.from(json['tags']),
    );
  }

  // Method to convert Token to JSON
  Map<String, dynamic> toJson() {
    return {
      'chainId': chainId,
      'symbol': symbol,
      'name': name,
      'address': address,
      'decimals': decimals,
      'logoURI': logoURI,
      'providers': providers,
      'eip2612': eip2612,
      'isFoT': isFoT,
      'tags': tags,
    };
  }

  @override
  String toString() {
    return 'CoinModel(chainId: $chainId, symbol: $symbol, name: $name, address: $address, decimals: $decimals, logoURI: $logoURI, providers: $providers, eip2612: $eip2612, isFoT: $isFoT, tags: $tags)';
  }

  CoinModel copyWith({
    int? chainId,
    String? symbol,
    String? name,
    String? address,
    int? decimals,
    String? logoURI,
    List<String>? providers,
    bool? eip2612,
    bool? isFoT,
    List<String>? tags,
  }) {
    return CoinModel(
      chainId: chainId ?? this.chainId,
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      address: address ?? this.address,
      decimals: decimals ?? this.decimals,
      logoURI: logoURI ?? this.logoURI,
      providers: providers ?? this.providers,
      eip2612: eip2612 ?? this.eip2612,
      isFoT: isFoT ?? this.isFoT,
      tags: tags ?? this.tags,
    );
  }
}
