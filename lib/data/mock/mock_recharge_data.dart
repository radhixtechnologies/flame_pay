import '../models/operator_model.dart';
import '../models/recharge_plan_model.dart';

class MockRechargeData {
  MockRechargeData._();

  static const List<OperatorModel> mobileOperators = [
    OperatorModel(id: 'jio', name: 'Jio Prepaid', type: 'mobile', code: 'JIO'),
    OperatorModel(id: 'airtel', name: 'Airtel Prepaid', type: 'mobile', code: 'AIRTEL'),
    OperatorModel(id: 'vi', name: 'Vodafone Idea (Vi)', type: 'mobile', code: 'VI'),
    OperatorModel(id: 'bsnl', name: 'BSNL Prepaid', type: 'mobile', code: 'BSNL'),
  ];

  static const List<OperatorModel> dthOperators = [
    OperatorModel(id: 'tata_play', name: 'Tata Play (Tata Sky)', type: 'dth', code: 'TATAPLAY'),
    OperatorModel(id: 'airtel_dth', name: 'Airtel Digital TV', type: 'dth', code: 'AIRTELDTH'),
    OperatorModel(id: 'dish_tv', name: 'Dish TV', type: 'dth', code: 'DISHTV'),
    OperatorModel(id: 'sun_direct', name: 'Sun Direct', type: 'dth', code: 'SUNDIRECT'),
    OperatorModel(id: 'd2h', name: 'D2H (Videocon)', type: 'dth', code: 'D2H'),
  ];

  static const List<String> circles = [
    'Delhi NCR',
    'Maharashtra & Goa',
    'Mumbai',
    'Karnataka',
    'Tamil Nadu',
    'Andhra Pradesh & Telangana',
    'Gujarat',
    'Uttar Pradesh (East)',
    'Uttar Pradesh (West)',
    'Punjab',
    'Rajasthan',
    'West Bengal & Kolkata',
  ];

  static const List<RechargePlanModel> jioPlans = [
    RechargePlanModel(
      id: 'jio_299',
      amount: 299.0,
      validity: '28 Days',
      data: '1.5 GB/Day',
      talktime: 'Unlimited',
      description: 'Truly Unlimited Voice Calls + 1.5 GB/Day High Speed Data + 100 SMS/Day + JioCinema, JioTV complimentary subscription.',
      category: 'Recommended',
      ottBenefits: ['JioCinema', 'JioTV', 'JioCloud'],
      isPopular: true,
    ),
    RechargePlanModel(
      id: 'jio_349',
      amount: 349.0,
      validity: '28 Days',
      data: '2.0 GB/Day',
      talktime: 'Unlimited',
      description: 'Hero Unlimited 5G Data eligible + 2 GB/Day + 100 SMS/Day + Unlimited Calls.',
      category: 'Recommended',
      ottBenefits: ['JioCinema Premium', 'JioTV'],
      isPopular: true,
    ),
    RechargePlanModel(
      id: 'jio_666',
      amount: 666.0,
      validity: '70 Days',
      data: '1.5 GB/Day',
      talktime: 'Unlimited',
      description: 'Super Value Pack: 1.5 GB/Day + Unlimited Calling + 100 SMS/Day for 70 Days.',
      category: 'Popular',
      ottBenefits: ['JioCinema', 'JioTV'],
    ),
    RechargePlanModel(
      id: 'jio_899',
      amount: 899.0,
      validity: '90 Days',
      data: '2.0 GB/Day + 20GB extra',
      talktime: 'Unlimited',
      description: 'Quarterly Monster Pack: 2 GB/Day data + 20 GB Bonus + Unlimited 5G Data.',
      category: 'Popular',
      ottBenefits: ['Disney+ Hotstar (3M)', 'JioCinema'],
      isPopular: true,
    ),
    RechargePlanModel(
      id: 'jio_19',
      amount: 19.0,
      validity: 'Active Base Plan',
      data: '1.5 GB Total',
      talktime: 'NA',
      description: 'Data Booster: 1.5 GB High Speed Data added to existing plan validity.',
      category: 'Data Only',
    ),
    RechargePlanModel(
      id: 'jio_29',
      amount: 29.0,
      validity: 'Active Base Plan',
      data: '2.5 GB Total',
      talktime: 'NA',
      description: 'Data Add-on: 2.5 GB extra data immediately available.',
      category: 'Data Only',
    ),
    RechargePlanModel(
      id: 'jio_3599',
      amount: 3599.0,
      validity: '365 Days',
      data: '2.5 GB/Day',
      talktime: 'Unlimited',
      description: 'Annual Mega Pack: 2.5 GB/Day (912.5 GB Total) + Unlimited 5G + 1 Year Disney+ Hotstar Mobile.',
      category: 'Annual',
      ottBenefits: ['Disney+ Hotstar 1Yr', 'JioCinema Premium', 'JioTV'],
      isPopular: true,
    ),
  ];

  static const List<OperatorModel> billers = [
    // Electricity
    OperatorModel(id: 'tata_power_delhi', name: 'Tata Power Delhi Distribution (TPDDL)', type: 'electricity'),
    OperatorModel(id: 'bses_rajdhani', name: 'BSES Rajdhani Power Limited', type: 'electricity'),
    OperatorModel(id: 'bses_yamuna', name: 'BSES Yamuna Power Limited', type: 'electricity'),
    OperatorModel(id: 'adani_mumbai', name: 'Adani Electricity Mumbai Limited', type: 'electricity'),
    OperatorModel(id: 'bescom', name: 'Bangalore Electricity (BESCOM)', type: 'electricity'),
    OperatorModel(id: 'uppcl_urban', name: 'UPPCL (Urban Electricity)', type: 'electricity'),
    OperatorModel(id: 'mseb', name: 'Mahavitaran (MSEDCL Maharashtra)', type: 'electricity'),

    // Water
    OperatorModel(id: 'delhi_jal_board', name: 'Delhi Jal Board (DJB)', type: 'water'),
    OperatorModel(id: 'mcgm_water', name: 'Municipal Corp of Greater Mumbai', type: 'water'),
    OperatorModel(id: 'bwssb_water', name: 'Bangalore Water Supply (BWSSB)', type: 'water'),

    // Piped Gas
    OperatorModel(id: 'igl_gas', name: 'Indraprastha Gas Limited (IGL)', type: 'gas'),
    OperatorModel(id: 'mgl_gas', name: 'Mahanagar Gas Limited (MGL)', type: 'gas'),
    OperatorModel(id: 'adani_gas', name: 'Adani Total Gas', type: 'gas'),

    // Broadband
    OperatorModel(id: 'airtel_broadband', name: 'Airtel Xstream Fiber', type: 'broadband'),
    OperatorModel(id: 'jio_fiber', name: 'JioFiber Broadband', type: 'broadband'),
    OperatorModel(id: 'act_fibernet', name: 'ACT Fibernet', type: 'broadband'),

    // Loan / EMI
    OperatorModel(id: 'bajaj_finserv', name: 'Bajaj Finance Limited', type: 'emi'),
    OperatorModel(id: 'hdfc_bank_loan', name: 'HDFC Bank Personal Loan EMI', type: 'emi'),
    OperatorModel(id: 'idfc_first_loan', name: 'IDFC FIRST Bank Loan', type: 'emi'),
    OperatorModel(id: 'tata_capital', name: 'Tata Capital Financial Services', type: 'emi'),
  ];
}
