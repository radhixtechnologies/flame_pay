import '../models/cibil_model.dart';
import '../models/credit_card_model.dart';
import '../models/loan_model.dart';
import '../models/insurance_model.dart';

class MockPhase4Data {
  MockPhase4Data._();

  // CIBIL Mock Data
  static const cibilReport = CibilScoreModel(
    score: 785,
    rating: 'Excellent',
    lastUpdated: '15 Oct 2026',
    nextRefreshDate: '15 Nov 2026',
    reportId: 'CIBIL-2026-89412',
    factors: [
      CibilFactorModel(
        title: 'Payment History',
        status: 'Excellent',
        value: '100% On-time',
        impact: 'High',
        scorePercent: 1.0,
      ),
      CibilFactorModel(
        title: 'Credit Utilization',
        status: 'Good',
        value: '14% Used',
        impact: 'High',
        scorePercent: 0.86,
      ),
      CibilFactorModel(
        title: 'Credit Age',
        status: 'Average',
        value: '3 Yrs 8 Mos',
        impact: 'Medium',
        scorePercent: 0.65,
      ),
      CibilFactorModel(
        title: 'Total Accounts',
        status: 'Good',
        value: '5 Active (3 Loans, 2 Cards)',
        impact: 'Low',
        scorePercent: 0.80,
      ),
      CibilFactorModel(
        title: 'Recent Inquiries',
        status: 'Excellent',
        value: '1 Inquiry in 6 Months',
        impact: 'Low',
        scorePercent: 0.95,
      ),
    ],
    tips: [
      'Maintain credit utilization below 30% for consistent high rating.',
      'Avoid multiple loan/card applications in short intervals.',
      'Keep your oldest active credit card to build a longer credit age.',
      'Check your credit report every 30 days to catch reporting errors early.',
    ],
  );

  // Credit Cards Mock Data
  static const creditCards = [
    CreditCardModel(
      id: 'hdfc_millennia',
      name: 'Millennia Credit Card',
      bank: 'HDFC Bank',
      category: 'Cashback',
      annualFee: '₹1,000 (Waived on ₹1L spend)',
      joiningFee: '₹1,000',
      rewardRate: '5% Cashback',
      minCibil: 720,
      minIncome: 35000,
      gradientHex: ['#0A2A66', '#1E40AF'],
      cardNetwork: 'VISA Signature',
      benefits: [
        '5% Cashback on Amazon, Flipkart, Swiggy & Zomato',
        '1% Cashback on all other offline & online spends',
        '8 Complimentary Domestic Airport Lounge visits/year',
        '1% Fuel Surcharge Waiver up to ₹250/month',
      ],
    ),
    CreditCardModel(
      id: 'sbi_simplyclick',
      name: 'SimplyCLICK Card',
      bank: 'SBI Card',
      category: 'Rewards',
      annualFee: '₹499 (Waived on ₹1L spend)',
      joiningFee: '₹499',
      rewardRate: '10X Reward Points',
      minCibil: 700,
      minIncome: 25000,
      gradientHex: ['#065F46', '#059669'],
      cardNetwork: 'Mastercard',
      benefits: [
        '₹500 Amazon Gift Card on joining payment',
        '10X Reward Points on Cleartrip, Netmeds, BookMyShow',
        '5X Reward Points on all other online shopping',
        '1% Fuel Surcharge Waiver at all petrol pumps',
      ],
    ),
    CreditCardModel(
      id: 'axis_airtel',
      name: 'Airtel Axis Credit Card',
      bank: 'Axis Bank',
      category: 'Cashback',
      annualFee: '₹500 (Waived on ₹1.5L spend)',
      joiningFee: '₹500',
      rewardRate: '25% Cashback on Bills',
      minCibil: 710,
      minIncome: 30000,
      gradientHex: ['#7C2D12', '#DC2626'],
      cardNetwork: 'RuPay Contactless',
      benefits: [
        '25% Cashback on Airtel Mobile, Broadband & DTH',
        '10% Cashback on Swiggy, Zomato & BigBasket',
        '10% Cashback on utility bills via Airtel Thanks App',
        '4 Complimentary Domestic Lounge Visits per year',
      ],
    ),
    CreditCardModel(
      id: 'icici_amazon_pay',
      name: 'Amazon Pay ICICI Card',
      bank: 'ICICI Bank',
      category: 'Cashback',
      annualFee: 'Lifetime FREE',
      joiningFee: 'Lifetime FREE',
      rewardRate: '5% Unlimited Cashback',
      minCibil: 730,
      minIncome: 25000,
      gradientHex: ['#831843', '#DB2777'],
      cardNetwork: 'VISA Platinum',
      benefits: [
        '5% Unlimited Cashback on Amazon for Prime members',
        '2% Unlimited Cashback on 100+ partner merchants',
        '1% Unlimited Cashback on all other transactions',
        'No joining fee, no annual fee, lifetime zero cost',
      ],
    ),
  ];

  // Loan Offers Mock Data
  static const personalLoanOffer = LoanOfferModel(
    id: 'flame_instant_loan',
    title: 'Instant Pre-Approved Personal Loan',
    minAmount: 10000.0,
    maxAmount: 500000.0,
    annualInterestRate: 10.49,
    minTenureMonths: 3,
    maxTenureMonths: 36,
    processingFeePercent: 1.5,
    highlights: [
      'Money in bank in 2 minutes',
      '100% Paperless & Digital KYC',
      'No collateral or guarantor required',
      'Flexible repayment tenure 3 to 36 months',
      'Zero prepayment penalty after 6 months',
    ],
  );

  // Insurance Plans Mock Data
  static const insurancePlans = [
    // Health
    InsurancePlanModel(
      id: 'care_supreme',
      title: 'Care Supreme Health Shield',
      provider: 'Care Health Insurance',
      category: InsuranceCategory.health,
      coverAmount: 1000000.0,
      monthlyPremium: 480.0,
      yearlyPremium: 5299.0,
      claimRatioPercent: 98.4,
      cashlessHospitalsCount: 11400,
      isPopular: true,
      providerLogo: 'care',
      keyFeatures: [
        'Unlimited Automatic Recharge of sum insured',
        'Zero Copayment at all network hospitals',
        'Free Annual Health Checkup for all covered members',
        'Ayush & In-home treatment coverage included',
      ],
    ),
    InsurancePlanModel(
      id: 'star_comprehensive',
      title: 'Star Comprehensive Family Cover',
      provider: 'Star Health Insurance',
      category: InsuranceCategory.health,
      coverAmount: 1500000.0,
      monthlyPremium: 620.0,
      yearlyPremium: 6899.0,
      claimRatioPercent: 97.9,
      cashlessHospitalsCount: 14000,
      providerLogo: 'star',
      keyFeatures: [
        'Maternity & Newborn baby cover included',
        'Air Ambulance coverage up to ₹5 Lakhs',
        'No cap on room rent & ICU charges',
        'Bariatric surgery & daycare procedures covered',
      ],
    ),
    // Term Life
    InsurancePlanModel(
      id: 'hdfc_click_protect',
      title: 'Click 2 Protect Super Term',
      provider: 'HDFC Life',
      category: InsuranceCategory.termLife,
      coverAmount: 10000000.0, // 1 Crore
      monthlyPremium: 590.0,
      yearlyPremium: 6499.0,
      claimRatioPercent: 99.3,
      cashlessHospitalsCount: 0,
      isPopular: true,
      providerLogo: 'hdfc',
      keyFeatures: [
        '₹1 Crore lump-sum payout to family',
        'Accelerated Critical Illness benefit optional',
        'Return of premium option available',
        'Tax savings up to ₹46,800 under Section 80C',
      ],
    ),
    // Motor
    InsurancePlanModel(
      id: 'digit_zero_dep',
      title: 'Comprehensive Zero-Dep Shield',
      provider: 'Go Digit General Insurance',
      category: InsuranceCategory.motor,
      coverAmount: 650000.0,
      monthlyPremium: 320.0,
      yearlyPremium: 3499.0,
      claimRatioPercent: 99.1,
      cashlessHospitalsCount: 6800,
      isPopular: true,
      providerLogo: 'digit',
      keyFeatures: [
        'Zero Depreciation on bumper-to-bumper parts',
        '24x7 Roadside Assistance & towing included',
        'Engine & Gearbox protection add-on',
        'Instant smartphone self-inspection in 7 minutes',
      ],
    ),
    // Travel
    InsurancePlanModel(
      id: 'tata_travel_secure',
      title: 'International Travel Secure',
      provider: 'Tata AIG',
      category: InsuranceCategory.travel,
      coverAmount: 5000000.0,
      monthlyPremium: 199.0,
      yearlyPremium: 1899.0,
      claimRatioPercent: 98.7,
      cashlessHospitalsCount: 5000,
      providerLogo: 'tata',
      keyFeatures: [
        'Medical emergency cover up to USD 50,000',
        'Flight delay & baggage loss compensation',
        'Passport loss assistance & trip cancellation',
        'Cashless hospitalisation across 130+ countries',
      ],
    ),
  ];
}
