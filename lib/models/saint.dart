class Saint {
  final int month;
  final int day;
  final String saint;
  final String quote;
  final String attribution;
  final String prayer;

  const Saint({
    required this.month,
    required this.day,
    required this.saint,
    required this.quote,
    required this.attribution,
    required this.prayer,
  });

  factory Saint.fromJson(Map<String, dynamic> json) {
    return Saint(
      month: json['month'] as int,
      day: json['day'] as int,
      saint: json['saint'] as String,
      quote: json['quote'] as String,
      attribution: json['attribution'] as String,
      prayer: json['prayer'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'month': month,
      'day': day,
      'saint': saint,
      'quote': quote,
      'attribution': attribution,
      'prayer': prayer,
    };
  }

  String get dateKey => '$month-$day';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Saint &&
          runtimeType == other.runtimeType &&
          month == other.month &&
          day == other.day;

  @override
  int get hashCode => month.hashCode ^ day.hashCode;
}
