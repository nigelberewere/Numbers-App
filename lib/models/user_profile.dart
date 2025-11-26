class UserProfile {
  final String businessName;
  final String industry;
  final double monthlyRevenueTarget;
  final double monthlyExpenseCap;
  final bool emailNotifications;
  final bool smsNotifications;
  final String preferredCurrency;

  UserProfile({
    this.businessName = '',
    this.industry = '',
    this.monthlyRevenueTarget = 0,
    this.monthlyExpenseCap = 0,
    this.emailNotifications = true,
    this.smsNotifications = false,
    this.preferredCurrency = 'USD',
  });

  Map<String, dynamic> toMap() {
    return {
      'businessName': businessName,
      'industry': industry,
      'monthlyRevenueTarget': monthlyRevenueTarget,
      'monthlyExpenseCap': monthlyExpenseCap,
      'emailNotifications': emailNotifications,
      'smsNotifications': smsNotifications,
      'preferredCurrency': preferredCurrency,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      businessName: map['businessName'] ?? '',
      industry: map['industry'] ?? '',
      monthlyRevenueTarget: (map['monthlyRevenueTarget'] ?? 0).toDouble(),
      monthlyExpenseCap: (map['monthlyExpenseCap'] ?? 0).toDouble(),
      emailNotifications: map['emailNotifications'] ?? true,
      smsNotifications: map['smsNotifications'] ?? false,
      preferredCurrency: map['preferredCurrency'] ?? 'USD',
    );
  }

  UserProfile copyWith({
    String? businessName,
    String? industry,
    double? monthlyRevenueTarget,
    double? monthlyExpenseCap,
    bool? emailNotifications,
    bool? smsNotifications,
    String? preferredCurrency,
  }) {
    return UserProfile(
      businessName: businessName ?? this.businessName,
      industry: industry ?? this.industry,
      monthlyRevenueTarget: monthlyRevenueTarget ?? this.monthlyRevenueTarget,
      monthlyExpenseCap: monthlyExpenseCap ?? this.monthlyExpenseCap,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      smsNotifications: smsNotifications ?? this.smsNotifications,
      preferredCurrency: preferredCurrency ?? this.preferredCurrency,
    );
  }
}
