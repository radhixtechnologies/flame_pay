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
    // --- Electricity (Pan-India State Boards & Discoms) ---
    // Delhi
    OperatorModel(id: 'tata_power_delhi', name: 'Tata Power Delhi Distribution (TPDDL)', type: 'electricity'),
    OperatorModel(id: 'bses_rajdhani', name: 'BSES Rajdhani Power Limited (BRPL Delhi)', type: 'electricity'),
    OperatorModel(id: 'bses_yamuna', name: 'BSES Yamuna Power Limited (BYPL Delhi)', type: 'electricity'),
    OperatorModel(id: 'ndmc_delhi', name: 'New Delhi Municipal Council (NDMC Electricity)', type: 'electricity'),

    // Maharashtra & Mumbai
    OperatorModel(id: 'adani_mumbai', name: 'Adani Electricity Mumbai Limited', type: 'electricity'),
    OperatorModel(id: 'tata_power_mumbai', name: 'Tata Power Mumbai Distribution', type: 'electricity'),
    OperatorModel(id: 'best_mumbai', name: 'BEST Undertaking Mumbai', type: 'electricity'),
    OperatorModel(id: 'mseb', name: 'Mahavitaran (MSEDCL Maharashtra State)', type: 'electricity'),

    // Uttar Pradesh
    OperatorModel(id: 'uppcl_urban', name: 'UPPCL (Urban Electricity Uttar Pradesh)', type: 'electricity'),
    OperatorModel(id: 'uppcl_rural', name: 'UPPCL (Rural Electricity Uttar Pradesh)', type: 'electricity'),
    OperatorModel(id: 'npcl_noida', name: 'Noida Power Company Limited (NPCL)', type: 'electricity'),
    OperatorModel(id: 'torrent_power_agra', name: 'Torrent Power (Agra)', type: 'electricity'),

    // Haryana & Punjab
    OperatorModel(id: 'dhbvn_haryana', name: 'Dakshin Haryana Bijli Vitran Nigam (DHBVN)', type: 'electricity'),
    OperatorModel(id: 'uhbvn_haryana', name: 'Uttar Haryana Bijli Vitran Nigam (UHBVN)', type: 'electricity'),
    OperatorModel(id: 'pspcl_punjab', name: 'Punjab State Power Corporation (PSPCL)', type: 'electricity'),

    // Rajasthan
    OperatorModel(id: 'jvvnl_jaipur', name: 'Jaipur Vidyut Vitran Nigam (JVVNL)', type: 'electricity'),
    OperatorModel(id: 'jdvvnl_jodhpur', name: 'Jodhpur Vidyut Vitran Nigam (JDVVNL)', type: 'electricity'),
    OperatorModel(id: 'avvnl_ajmer', name: 'Ajmer Vidyut Vitran Nigam (AVVNL)', type: 'electricity'),

    // Gujarat
    OperatorModel(id: 'torrent_power_gujarat', name: 'Torrent Power (Ahmedabad / Surat / Gandhinagar)', type: 'electricity'),
    OperatorModel(id: 'ugvcl_gujarat', name: 'Uttar Gujarat Vij Company (UGVCL)', type: 'electricity'),
    OperatorModel(id: 'dgvcl_gujarat', name: 'Dakshin Gujarat Vij Company (DGVCL)', type: 'electricity'),
    OperatorModel(id: 'mgvcl_gujarat', name: 'Madhya Gujarat Vij Company (MGVCL)', type: 'electricity'),
    OperatorModel(id: 'pgvcl_gujarat', name: 'Paschim Gujarat Vij Company (PGVCL)', type: 'electricity'),

    // Karnataka
    OperatorModel(id: 'bescom', name: 'Bangalore Electricity Supply Company (BESCOM)', type: 'electricity'),
    OperatorModel(id: 'hescom', name: 'Hubli Electricity Supply (HESCOM)', type: 'electricity'),
    OperatorModel(id: 'mescom', name: 'Mangalore Electricity Supply (MESCOM)', type: 'electricity'),

    // Madhya Pradesh
    OperatorModel(id: 'mp_poorv_vitaran', name: 'MP Poorv Kshetra Vidyut Vitaran (Jabalpur)', type: 'electricity'),
    OperatorModel(id: 'mp_madhya_vitaran', name: 'MP Madhya Kshetra Vidyut Vitaran (Bhopal)', type: 'electricity'),
    OperatorModel(id: 'mp_paschim_vitaran', name: 'MP Paschim Kshetra Vidyut Vitaran (Indore)', type: 'electricity'),

    // West Bengal & Bihar
    OperatorModel(id: 'cesc_kolkata', name: 'CESC Limited (Kolkata & Howrah)', type: 'electricity'),
    OperatorModel(id: 'wbsedcl_bengal', name: 'West Bengal State Electricity (WBSEDCL)', type: 'electricity'),
    OperatorModel(id: 'nbpdcl_bihar', name: 'North Bihar Power Distribution (NBPDCL)', type: 'electricity'),
    OperatorModel(id: 'sbpdcl_bihar', name: 'South Bihar Power Distribution (SBPDCL)', type: 'electricity'),

    // South India (Tamil Nadu, Telangana, Andhra)
    OperatorModel(id: 'tangedco_tamilnadu', name: 'Tamil Nadu Electricity Board (TANGEDCO)', type: 'electricity'),
    OperatorModel(id: 'tsspdcl_telangana', name: 'Telangana Southern Power (TSSPDCL)', type: 'electricity'),
    OperatorModel(id: 'apspdcl_andhra', name: 'Andhra Pradesh Southern Power (APSPDCL)', type: 'electricity'),

    // --- Water Utilities ---
    OperatorModel(id: 'delhi_jal_board', name: 'Delhi Jal Board (DJB)', type: 'water'),
    OperatorModel(id: 'mcgm_water', name: 'Municipal Corp of Greater Mumbai (MCGM)', type: 'water'),
    OperatorModel(id: 'bwssb_water', name: 'Bangalore Water Supply & Sewerage (BWSSB)', type: 'water'),
    OperatorModel(id: 'hmwssb_hyderabad', name: 'Hyderabad Metro Water (HMWSSB)', type: 'water'),
    OperatorModel(id: 'cmwssb_chennai', name: 'Chennai Metro Water (CMWSSB)', type: 'water'),
    OperatorModel(id: 'up_jal_sansthan', name: 'UP Jal Sansthan (Uttar Pradesh)', type: 'water'),

    // --- Piped Gas ---
    OperatorModel(id: 'igl_gas', name: 'Indraprastha Gas Limited (IGL Delhi NCR)', type: 'gas'),
    OperatorModel(id: 'mgl_gas', name: 'Mahanagar Gas Limited (MGL Mumbai)', type: 'gas'),
    OperatorModel(id: 'adani_gas', name: 'Adani Total Gas Limited', type: 'gas'),
    OperatorModel(id: 'gujarat_gas', name: 'Gujarat Gas Limited (GGL)', type: 'gas'),
    OperatorModel(id: 'gail_gas', name: 'GAIL Gas Limited', type: 'gas'),
    OperatorModel(id: 'haryana_city_gas', name: 'Haryana City Gas (Gurugram)', type: 'gas'),

    // --- Broadband & Fiber ---
    OperatorModel(id: 'airtel_broadband', name: 'Airtel Xstream Fiber Broadband', type: 'broadband'),
    OperatorModel(id: 'jio_fiber', name: 'JioFiber Broadband', type: 'broadband'),
    OperatorModel(id: 'act_fibernet', name: 'ACT Fibernet', type: 'broadband'),
    OperatorModel(id: 'bsnl_broadband', name: 'BSNL Bharat Fiber Broadband', type: 'broadband'),
    OperatorModel(id: 'tata_play_fiber', name: 'Tata Play Fiber', type: 'broadband'),
    OperatorModel(id: 'hathway_broadband', name: 'Hathway Broadband', type: 'broadband'),

    // --- Loan / EMI ---
    OperatorModel(id: 'bajaj_finserv', name: 'Bajaj Finance Limited (EMI)', type: 'emi'),
    OperatorModel(id: 'hdfc_bank_loan', name: 'HDFC Bank Personal Loan EMI', type: 'emi'),
    OperatorModel(id: 'idfc_first_loan', name: 'IDFC FIRST Bank Loan EMI', type: 'emi'),
    OperatorModel(id: 'tata_capital', name: 'Tata Capital Financial Services', type: 'emi'),
    OperatorModel(id: 'hero_fincorp', name: 'Hero FinCorp Limited', type: 'emi'),
    OperatorModel(id: 'muthoot_finance', name: 'Muthoot Finance Loan Repayment', type: 'emi'),
    OperatorModel(id: 'lnt_finance', name: 'L&T Finance Limited', type: 'emi'),
    OperatorModel(id: 'bajaj_finserv', name: 'Bajaj Finance Limited (EMI)', type: 'loan_emi'),
    OperatorModel(id: 'hdfc_bank_loan', name: 'HDFC Bank Personal Loan EMI', type: 'loan_emi'),
    OperatorModel(id: 'idfc_first_loan', name: 'IDFC FIRST Bank Loan EMI', type: 'loan_emi'),
    OperatorModel(id: 'tata_capital', name: 'Tata Capital Financial Services', type: 'loan_emi'),
    OperatorModel(id: 'hero_fincorp', name: 'Hero FinCorp Limited', type: 'loan_emi'),
    OperatorModel(id: 'muthoot_finance', name: 'Muthoot Finance Loan Repayment', type: 'loan_emi'),
    OperatorModel(id: 'lnt_finance', name: 'L&T Finance Limited', type: 'loan_emi'),
    OperatorModel(id: 'home_credit', name: 'Home Credit India', type: 'loan_emi'),

    // --- Mobile Postpaid ---
    OperatorModel(id: 'airtel_postpaid', name: 'Airtel Postpaid', type: 'mobile_postpaid'),
    OperatorModel(id: 'jio_postpaid', name: 'Reliance Jio Postpaid Plus', type: 'mobile_postpaid'),
    OperatorModel(id: 'vi_postpaid', name: 'Vodafone Idea (Vi) Postpaid', type: 'mobile_postpaid'),
    OperatorModel(id: 'bsnl_postpaid', name: 'BSNL Mobile Postpaid', type: 'mobile_postpaid'),

    // --- Insurance Premium ---
    OperatorModel(id: 'lic_insurance', name: 'Life Insurance Corporation (LIC)', type: 'insurance_premium'),
    OperatorModel(id: 'hdfc_life', name: 'HDFC Life Insurance', type: 'insurance_premium'),
    OperatorModel(id: 'icici_pru_life', name: 'ICICI Prudential Life Insurance', type: 'insurance_premium'),
    OperatorModel(id: 'sbi_life', name: 'SBI Life Insurance', type: 'insurance_premium'),
    OperatorModel(id: 'max_life', name: 'Max Life Insurance', type: 'insurance_premium'),
    OperatorModel(id: 'tata_aia_life', name: 'Tata AIA Life Insurance', type: 'insurance_premium'),
    OperatorModel(id: 'star_health', name: 'Star Health & Allied Insurance', type: 'insurance_premium'),

    // --- Gas Cylinder Booking ---
    OperatorModel(id: 'indane_gas', name: 'Indane Gas (Indian Oil - IOCL)', type: 'gas_cylinder'),
    OperatorModel(id: 'bharat_gas', name: 'Bharat Gas (BPCL)', type: 'gas_cylinder'),
    OperatorModel(id: 'hp_gas', name: 'HP Gas (HPCL)', type: 'gas_cylinder'),

    // --- Subscription ---
    OperatorModel(id: 'netflix_sub', name: 'Netflix India', type: 'subscription'),
    OperatorModel(id: 'amazon_prime_sub', name: 'Amazon Prime Video', type: 'subscription'),
    OperatorModel(id: 'disney_hotstar_sub', name: 'Disney+ Hotstar', type: 'subscription'),
    OperatorModel(id: 'sonyliv_sub', name: 'SonyLIV Premium', type: 'subscription'),
    OperatorModel(id: 'zee5_sub', name: 'Zee5 Premium', type: 'subscription'),
    OperatorModel(id: 'spotify_sub', name: 'Spotify Premium', type: 'subscription'),
    OperatorModel(id: 'youtube_premium_sub', name: 'YouTube Premium Family', type: 'subscription'),

    // --- Rental ---
    OperatorModel(id: 'house_rent', name: 'House Rent Payment', type: 'rental'),
    OperatorModel(id: 'society_maintenance', name: 'Apartment Society Maintenance Dues', type: 'rental'),
    OperatorModel(id: 'commercial_rent', name: 'Commercial Office / Shop Rent', type: 'rental'),
    OperatorModel(id: 'pg_coliving_rent', name: 'Co-living & PG Monthly Rent', type: 'rental'),

    // --- Municipal Tax ---
    OperatorModel(id: 'mcd_delhi', name: 'Municipal Corporation of Delhi (MCD Property Tax)', type: 'municipal_tax'),
    OperatorModel(id: 'bmc_mumbai', name: 'Brihanmumbai Municipal Corporation (BMC Property Tax)', type: 'municipal_tax'),
    OperatorModel(id: 'bbmp_bengaluru', name: 'BBMP Property Tax Bengaluru', type: 'municipal_tax'),
    OperatorModel(id: 'ghmc_hyderabad', name: 'GHMC Property Tax Hyderabad', type: 'municipal_tax'),
    OperatorModel(id: 'gcc_chennai', name: 'Greater Chennai Corporation Property Tax', type: 'municipal_tax'),
    OperatorModel(id: 'pmc_pune', name: 'Pune Municipal Corporation (PMC Tax)', type: 'municipal_tax'),

    // --- Education ---
    OperatorModel(id: 'dps_school', name: 'Delhi Public School (DPS) Term Fees', type: 'education'),
    OperatorModel(id: 'kv_school', name: 'Kendriya Vidyalaya (KV) Quarterly Fees', type: 'education'),
    OperatorModel(id: 'amity_university', name: 'Amity University Semester Fees', type: 'education'),
    OperatorModel(id: 'allen_institute', name: 'Allen Career Institute Coaching Fees', type: 'education'),
    OperatorModel(id: 'aakash_institute', name: 'Aakash Institute Tuition Fees', type: 'education'),
    OperatorModel(id: 'fiitjee', name: 'FIITJEE Coaching Program Fees', type: 'education'),

    // --- Hospital ---
    OperatorModel(id: 'apollo_hospitals', name: 'Apollo Hospitals Medical & Consultation', type: 'hospital'),
    OperatorModel(id: 'fortis_healthcare', name: 'Fortis Healthcare', type: 'hospital'),
    OperatorModel(id: 'max_healthcare', name: 'Max Healthcare Hospitals', type: 'hospital'),
    OperatorModel(id: 'manipal_hospitals', name: 'Manipal Hospitals', type: 'hospital'),
    OperatorModel(id: 'medanta_medicity', name: 'Medanta - The Medicity', type: 'hospital'),
    OperatorModel(id: 'narayana_health', name: 'Narayana Health', type: 'hospital'),

    // --- Cable TV ---
    OperatorModel(id: 'hathway_cable', name: 'Hathway Digital Cable TV', type: 'cable_tv'),
    OperatorModel(id: 'den_networks', name: 'DEN Networks Cable', type: 'cable_tv'),
    OperatorModel(id: 'gtpl_hathway', name: 'GTPL Hathway Cable TV', type: 'cable_tv'),
    OperatorModel(id: 'siti_networks', name: 'Siti Cable Networks', type: 'cable_tv'),
    OperatorModel(id: 'asianet_cable', name: 'Asianet Digital Cable TV', type: 'cable_tv'),
    OperatorModel(id: 'fastway_cable', name: 'Fastway Transmissions', type: 'cable_tv'),
  ];
}
