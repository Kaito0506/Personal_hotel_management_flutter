class Tenant{
  final String name;
  final String dob;
  final String cccd;
  final String phone;
  final String startDate;
  final String? endDate;

  Tenant({
    required this.name,
    required this.dob,
    required this.cccd,
    required this.phone,
    required this.startDate,
    this.endDate

  });

  Map<String, dynamic> toJson(){
    return {
      'name': name,
      'dob': dob,
      'startDate': startDate,
      'endDate': endDate,
      'phone': phone,
      'cccd': cccd,
    };
  }

  Tenant fromJson(Map<String, dynamic> t){
    return Tenant(name: t['name'],
        dob: t['dob'],
        cccd: t['cccd'],
        phone: t['phone'],
        startDate: t['startDate'],
        endDate: t['endDate']!=null ? t['endDate'] : null
        );
  }

}