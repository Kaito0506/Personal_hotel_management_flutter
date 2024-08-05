class Utility {
  final int electricityReading;
  final int waterReading;
  final bool rentPaid;

  Utility({
    required this.electricityReading,
    required this.waterReading,
    required this.rentPaid,
  });

  Map<String, dynamic> toJson() {
    return {
      'electricityReading': electricityReading,
      'waterReading': waterReading,
      'rentPaid': rentPaid,
    };
  }

  static Utility fromJson(Map<String, dynamic> json) {
    return Utility(
      electricityReading: json['electricityReading'],
      waterReading: json['waterReading'],
      rentPaid: json['rentPaid'],
    );
  }
}