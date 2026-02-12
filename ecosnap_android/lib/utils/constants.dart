import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Color Scheme - Green & White
  static const Color primaryGreen = Color(0xFF2D6A4F);
  static const Color lightGreen = Color(0xFF52B788);
  static const Color accentGreen = Color(0xFF74C69D);
  static const Color backgroundWhite = Color(0xFFFFFFFF);
  static const Color lightGray = Color(0xFFF8F9FA);
  static const Color darkGray = Color(0xFF495057);
  static const Color errorRed = Color(0xFFDC3545);
  static const Color warningOrange = Color(0xFFFF9800);
  static const Color successGreen = Color(0xFF40916C);
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: primaryGreen,
        secondary: accentGreen,
        surface: backgroundWhite,
        background: lightGray,
        error: errorRed,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: darkGray,
        onBackground: darkGray,
      ),
      textTheme: GoogleFonts.interTextTheme(),
      scaffoldBackgroundColor: lightGray,
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundWhite,
        foregroundColor: primaryGreen,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: primaryGreen,
        ),
      ),
      cardTheme: CardThemeData(
        color: backgroundWhite,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: backgroundWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: lightGreen.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: lightGreen.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryGreen, width: 2),
        ),
      ),
    );
  }
}

class AppConstants {
  // App Info
  static const String appName = 'EcoSnap';
  static const String appVersion = '1.0.0';
  static const String helpSupportUrl = 'https://forms.gle/1mtoVY4BYQTRfQGGA';
  
  // Feature Toggles
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = false;
  
  // ML Model Settings
  static const String modelFileName = 'waste_classifier.tflite';
  static const String labelsFileName = 'labels.txt';
  static const int imageSize = 224;
  static const double confidenceThreshold = 0.6;
  
// Recycling Centers by Malaysian States
  static const Map<String, List<Map<String, dynamic>>> recyclingCentersByState = {
    'Kuala Lumpur': [
      {
        'name': 'KL Recycling Hub',
        'address': 'Jalan Raja Laut, 50350 Kuala Lumpur',
        'phone': '+603-2698-5566',
        'acceptedItems': ['Paper', 'Plastic', 'Glass', 'Metal', 'E-waste'],
      },
      {
        'name': 'KLCC E-waste Collection',
        'address': 'KLCC, Kuala Lumpur City Centre',
        'phone': '+603-2382-2828',
        'acceptedItems': ['E-waste', 'Batteries'],
      },
      {
        'name': 'Alam Flora Recycling Centre',
        'address': 'Taman Tun Dr Ismail, 60000 Kuala Lumpur',
        'phone': '+603-7784-5050',
        'acceptedItems': ['Paper', 'Plastic', 'Glass', 'Metal'],
      },
    ],
    'Selangor': [
      {
        'name': 'Shah Alam Green Centre',
        'address': 'Seksyen 7, 40000 Shah Alam',
        'phone': '+603-5511-2233',
        'acceptedItems': ['Paper', 'Plastic', 'Glass', 'Metal', 'E-waste'],
      },
      {
        'name': 'Petaling Jaya Recycling Point',
        'address': 'SS2, 47300 Petaling Jaya',
        'phone': '+603-7956-8899',
        'acceptedItems': ['Paper', 'Plastic', 'Glass', 'Metal'],
      },
    ],
    'Johor': [
      {
        'name': 'JB Eco Recycling Centre',
        'address': 'Jalan Skudai, 80200 Johor Bahru',
        'phone': '+607-556-7788',
        'acceptedItems': ['Paper', 'Plastic', 'Glass', 'Metal', 'E-waste'],
      },
      {
        'name': 'Skudai Green Point',
        'address': 'Taman Universiti, 81300 Skudai',
        'phone': '+607-520-1122',
        'acceptedItems': ['Paper', 'Plastic', 'Glass'],
      },
    ],
    'Penang': [
      {
        'name': 'Georgetown Recycling Hub',
        'address': 'Jalan Penang, 10000 Georgetown',
        'phone': '+604-226-3344',
        'acceptedItems': ['Paper', 'Plastic', 'Glass', 'Metal', 'E-waste'],
      },
      {
        'name': 'Bayan Lepas Green Centre',
        'address': 'Bayan Lepas, 11900 Penang',
        'phone': '+604-643-5566',
        'acceptedItems': ['Paper', 'Plastic', 'E-waste'],
      },
    ],
    'Perak': [
      {
        'name': 'Ipoh Recycling Centre',
        'address': 'Jalan Sultan Idris Shah, 30000 Ipoh',
        'phone': '+605-254-7788',
        'acceptedItems': ['Paper', 'Plastic', 'Glass', 'Metal'],
      },
      {
        'name': 'Taiping Eco Point',
        'address': 'Jalan Kota, 34000 Taiping',
        'phone': '+605-806-9900',
        'acceptedItems': ['Paper', 'Plastic', 'Glass'],
      },
    ],
    'Kedah': [
      {
        'name': 'Alor Setar Green Hub',
        'address': 'Jalan Sultanah Sambungan, 05050 Alor Setar',
        'phone': '+604-733-1122',
        'acceptedItems': ['Paper', 'Plastic', 'Glass', 'Metal'],
      },
      {
        'name': 'Sungai Petani Recycling Point',
        'address': 'Jalan Ibrahim, 08000 Sungai Petani',
        'phone': '+604-421-3344',
        'acceptedItems': ['Paper', 'Plastic'],
      },
    ],
    'Melaka': [
      {
        'name': 'Melaka City Recycling Centre',
        'address': 'Jalan Munshi Abdullah, 75100 Melaka',
        'phone': '+606-282-5566',
        'acceptedItems': ['Paper', 'Plastic', 'Glass', 'Metal', 'E-waste'],
      },
      {
        'name': 'Ayer Keroh Green Point',
        'address': 'Ayer Keroh, 75450 Melaka',
        'phone': '+606-232-7788',
        'acceptedItems': ['Paper', 'Plastic', 'Glass'],
      },
    ],
    'Negeri Sembilan': [
      {
        'name': 'Seremban Green Centre',
        'address': 'Jalan Tuanku Munawir, 70000 Seremban',
        'phone': '+606-762-7788',
        'acceptedItems': ['Paper', 'Plastic', 'Glass', 'Metal'],
      },
      {
        'name': 'Port Dickson Recycling Hub',
        'address': 'Jalan Pantai, 71000 Port Dickson',
        'phone': '+606-647-3344',
        'acceptedItems': ['Paper', 'Plastic'],
      },
    ],
    'Pahang': [
      {
        'name': 'Kuantan Recycling Hub',
        'address': 'Jalan Teluk Sisek, 25050 Kuantan',
        'phone': '+609-513-9900',
        'acceptedItems': ['Paper', 'Plastic', 'Glass', 'Metal'],
      },
      {
        'name': 'Temerloh Green Point',
        'address': 'Jalan Ahmad Shah, 28000 Temerloh',
        'phone': '+609-296-5566',
        'acceptedItems': ['Paper', 'Plastic'],
      },
    ],
    'Terengganu': [
      {
        'name': 'Kuala Terengganu Eco Point',
        'address': 'Jalan Sultan Zainal Abidin, 20000 Kuala Terengganu',
        'phone': '+609-622-1122',
        'acceptedItems': ['Paper', 'Plastic', 'Glass'],
      },
      {
        'name': 'Kemaman Recycling Centre',
        'address': 'Jalan Tengku Muhammad, 24000 Kemaman',
        'phone': '+609-859-3344',
        'acceptedItems': ['Paper', 'Plastic'],
      },
    ],
    'Kelantan': [
      {
        'name': 'Kota Bharu Green Centre',
        'address': 'Jalan Sultanah Zainab, 15000 Kota Bharu',
        'phone': '+609-748-3344',
        'acceptedItems': ['Paper', 'Plastic', 'Glass', 'Metal'],
      },
      {
        'name': 'Pasir Mas Eco Point',
        'address': 'Jalan Hospital, 17000 Pasir Mas',
        'phone': '+609-790-5566',
        'acceptedItems': ['Paper', 'Plastic'],
      },
    ],
    'Sabah': [
      {
        'name': 'Kota Kinabalu Recycling Hub',
        'address': 'Jalan Tuaran, 88400 Kota Kinabalu',
        'phone': '+6088-211-5566',
        'acceptedItems': ['Paper', 'Plastic', 'Glass', 'Metal', 'E-waste'],
      },
      {
        'name': 'Sandakan Green Point',
        'address': 'Jalan Utara, 90000 Sandakan',
        'phone': '+6089-213-3344',
        'acceptedItems': ['Paper', 'Plastic'],
      },
    ],
    'Sarawak': [
      {
        'name': 'Kuching Green Centre',
        'address': 'Jalan Tun Ahmad Zaidi Adruce, 93150 Kuching',
        'phone': '+6082-240-7788',
        'acceptedItems': ['Paper', 'Plastic', 'Glass', 'Metal'],
      },
      {
        'name': 'Miri Recycling Hub',
        'address': 'Jalan Raja, 98000 Miri',
        'phone': '+6085-413-5566',
        'acceptedItems': ['Paper', 'Plastic', 'E-waste'],
      },
    ],
    'Perlis': [
      {
        'name': 'Kangar Recycling Point',
        'address': 'Jalan Kangar-Alor Setar, 01000 Kangar',
        'phone': '+604-976-1122',
        'acceptedItems': ['Paper', 'Plastic', 'Glass'],
      },
      {
        'name': 'Arau Green Centre',
        'address': 'Jalan Padang Behor, 02600 Arau',
        'phone': '+604-986-3344',
        'acceptedItems': ['Paper', 'Plastic'],
      },
    ],
  };

  static List<String> get malaysianStates => recyclingCentersByState.keys.toList();
  
  // Reuse Ideas with YouTube tutorials
  static const Map<String, List<Map<String, dynamic>>> reuseIdeas = {
    'Glass Bottle': [
      {
        'title': 'Plant Pot',
        'difficulty': 'Easy',
        'description': 'Transform into a beautiful indoor planter',
        'estimatedValue': {'min': 8, 'max': 15},
        'youtubeUrl': 'https://www.youtube.com/results?search_query=diy+glass+bottle+planter',
      },
      {
        'title': 'Desk Organizer',
        'difficulty': 'Medium',
        'description': 'Store pens, brushes, or utensils',
        'estimatedValue': {'min': 10, 'max': 20},
        'youtubeUrl': 'https://www.youtube.com/results?search_query=glass+bottle+desk+organizer',
      },
      {
        'title': 'Decorative Lamp',
        'difficulty': 'Hard',
        'description': 'Create a unique lighting fixture',
        'estimatedValue': {'min': 25, 'max': 50},
        'youtubeUrl': 'https://www.youtube.com/results?search_query=glass+bottle+lamp+diy',
      },
    ],
    'Plastic Container': [
      {
        'title': 'Storage Box',
        'difficulty': 'Easy',
        'description': 'Organize small items efficiently',
        'estimatedValue': {'min': 5, 'max': 10},
        'youtubeUrl': 'https://www.youtube.com/results?search_query=plastic+container+storage+ideas',
      },
      {
        'title': 'Seed Starter',
        'difficulty': 'Easy',
        'description': 'Perfect for growing seedlings',
        'estimatedValue': {'min': 3, 'max': 8},
        'youtubeUrl': 'https://www.youtube.com/results?search_query=plastic+container+seed+starter',
      },
      {
        'title': 'Craft Organizer',
        'difficulty': 'Medium',
        'description': 'Sort beads, buttons, and small craft supplies',
        'estimatedValue': {'min': 8, 'max': 15},
        'youtubeUrl': 'https://www.youtube.com/results?search_query=plastic+container+craft+organizer',
      },
    ],
    'Cardboard Box': [
      {
        'title': 'Pet House',
        'difficulty': 'Medium',
        'description': 'Cozy shelter for cats or small pets',
        'estimatedValue': {'min': 15, 'max': 30},
        'youtubeUrl': 'https://www.youtube.com/results?search_query=cardboard+box+cat+house',
      },
      {
        'title': 'Storage Organizer',
        'difficulty': 'Easy',
        'description': 'Divide and organize drawers',
        'estimatedValue': {'min': 5, 'max': 12},
        'youtubeUrl': 'https://www.youtube.com/results?search_query=cardboard+box+organizer+diy',
      },
      {
        'title': 'Kids Playhouse',
        'difficulty': 'Medium',
        'description': 'Create imaginative play space for children',
        'estimatedValue': {'min': 20, 'max': 40},
        'youtubeUrl': 'https://www.youtube.com/results?search_query=cardboard+box+playhouse',
      },
    ],
    'Tin Can': [
      {
        'title': 'Pencil Holder',
        'difficulty': 'Easy',
        'description': 'Wrap with fabric or paint decoratively',
        'estimatedValue': {'min': 8, 'max': 15},
        'youtubeUrl': 'https://www.youtube.com/results?search_query=tin+can+pencil+holder',
      },
      {
        'title': 'Herb Planter',
        'difficulty': 'Easy',
        'description': 'Grow kitchen herbs',
        'estimatedValue': {'min': 10, 'max': 18},
        'youtubeUrl': 'https://www.youtube.com/results?search_query=tin+can+herb+garden',
      },
      {
        'title': 'Candle Holder',
        'difficulty': 'Medium',
        'description': 'Create decorative lanterns with punched patterns',
        'estimatedValue': {'min': 12, 'max': 22},
        'youtubeUrl': 'https://www.youtube.com/results?search_query=tin+can+candle+holder',
      },
    ],
    'Clothing': [
      {
        'title': 'Tote Bag',
        'difficulty': 'Medium',
        'description': 'Repurpose old shirts into reusable shopping bags',
        'estimatedValue': {'min': 15, 'max': 25},
        'youtubeUrl': 'https://www.youtube.com/results?search_query=old+clothes+tote+bag+diy',
      },
      {
        'title': 'Cleaning Rags',
        'difficulty': 'Easy',
        'description': 'Cut into squares for eco-friendly cleaning',
        'estimatedValue': {'min': 5, 'max': 10},
        'youtubeUrl': 'https://www.youtube.com/results?search_query=turn+clothes+into+cleaning+rags',
      },
      {
        'title': 'Patchwork Quilt',
        'difficulty': 'Hard',
        'description': 'Sew fabric pieces into cozy blanket',
        'estimatedValue': {'min': 40, 'max': 80},
        'youtubeUrl': 'https://www.youtube.com/results?search_query=patchwork+quilt+from+old+clothes',
      },
    ],
    'Food Can': [
      {
        'title': 'Desk Organizer',
        'difficulty': 'Easy',
        'description': 'Store pens, scissors, and office supplies',
        'estimatedValue': {'min': 8, 'max': 15},
        'youtubeUrl': 'https://www.youtube.com/results?search_query=aluminum+can+desk+organizer',
      },
      {
        'title': 'Succulent Planter',
        'difficulty': 'Easy',
        'description': 'Paint and fill with small cacti or succulents',
        'estimatedValue': {'min': 10, 'max': 18},
        'youtubeUrl': 'https://www.youtube.com/results?search_query=aluminum+can+succulent+planter',
      },
      {
        'title': 'Wind Chime',
        'difficulty': 'Medium',
        'description': 'Create musical garden decoration',
        'estimatedValue': {'min': 15, 'max': 30},
        'youtubeUrl': 'https://www.youtube.com/results?search_query=aluminum+can+wind+chime',
      },
    ],
    'Magazine': [
      {
        'title': 'Paper Beads',
        'difficulty': 'Medium',
        'description': 'Roll pages into decorative jewelry beads',
        'estimatedValue': {'min': 12, 'max': 25},
        'youtubeUrl': 'https://www.youtube.com/results?search_query=magazine+paper+beads+tutorial',
      },
      {
        'title': 'Collage Art',
        'difficulty': 'Easy',
        'description': 'Create artwork from magazine cutouts',
        'estimatedValue': {'min': 10, 'max': 30},
        'youtubeUrl': 'https://www.youtube.com/results?search_query=magazine+collage+art',
      },
      {
        'title': 'Gift Wrap',
        'difficulty': 'Easy',
        'description': 'Use colorful pages as unique wrapping paper',
        'estimatedValue': {'min': 5, 'max': 10},
        'youtubeUrl': 'https://www.youtube.com/results?search_query=magazine+gift+wrap+ideas',
      },
    ],
    'Newspaper': [
      {
        'title': 'Plant Pot Seedling',
        'difficulty': 'Easy',
        'description': 'Fold into biodegradable seed starter pots',
        'estimatedValue': {'min': 3, 'max': 8},
        'youtubeUrl': 'https://www.youtube.com/results?search_query=newspaper+seed+starter+pots',
      },
      {
        'title': 'Paper Mache Crafts',
        'difficulty': 'Medium',
        'description': 'Create bowls, masks, or decorative items',
        'estimatedValue': {'min': 10, 'max': 25},
        'youtubeUrl': 'https://www.youtube.com/results?search_query=newspaper+paper+mache+crafts',
      },
      {
        'title': 'Gift Bags',
        'difficulty': 'Easy',
        'description': 'Fold and glue into reusable gift bags',
        'estimatedValue': {'min': 5, 'max': 12},
        'youtubeUrl': 'https://www.youtube.com/results?search_query=newspaper+gift+bags+diy',
      },
    ],
    'Plastic Bag': [
      {
        'title': 'Woven Mat',
        'difficulty': 'Hard',
        'description': 'Weave multiple bags into durable floor mat',
        'estimatedValue': {'min': 20, 'max': 40},
        'youtubeUrl': 'https://www.youtube.com/results?search_query=plastic+bag+woven+mat',
      },
      {
        'title': 'Yarn Alternative',
        'difficulty': 'Medium',
        'description': 'Cut into strips for crocheting or knitting',
        'estimatedValue': {'min': 8, 'max': 15},
        'youtubeUrl': 'https://www.youtube.com/results?search_query=plastic+bag+yarn+plarn',
      },
      {
        'title': 'Trash Bag Organizer',
        'difficulty': 'Easy',
        'description': 'Store bags inside one bag for easy access',
        'estimatedValue': {'min': 3, 'max': 6},
        'youtubeUrl': 'https://www.youtube.com/results?search_query=plastic+bag+storage+holder',
      },
    ],
    'Plastic Bottle': [
      {
        'title': 'Hanging Planter',
        'difficulty': 'Easy',
        'description': 'Cut and hang as vertical garden',
        'estimatedValue': {'min': 8, 'max': 15},
        'youtubeUrl': 'https://www.youtube.com/results?search_query=plastic+bottle+hanging+planter',
      },
      {
        'title': 'Bird Feeder',
        'difficulty': 'Easy',
        'description': 'Create feeding station for garden birds',
        'estimatedValue': {'min': 10, 'max': 18},
        'youtubeUrl': 'https://www.youtube.com/results?search_query=plastic+bottle+bird+feeder',
      },
      {
        'title': 'Sprinkler System',
        'difficulty': 'Medium',
        'description': 'Poke holes for garden irrigation',
        'estimatedValue': {'min': 5, 'max': 12},
        'youtubeUrl': 'https://www.youtube.com/results?search_query=plastic+bottle+sprinkler',
      },
    ],
    'Styrofoam': [
      {
        'title': 'Stamp Printing',
        'difficulty': 'Easy',
        'description': 'Carve designs for art printing projects',
        'estimatedValue': {'min': 5, 'max': 10},
        'youtubeUrl': 'https://www.youtube.com/results?search_query=styrofoam+stamp+printing',
      },
      {
        'title': 'Floating Pool Noodle',
        'difficulty': 'Medium',
        'description': 'Cut and shape into pool toys',
        'estimatedValue': {'min': 8, 'max': 15},
        'youtubeUrl': 'https://www.youtube.com/results?search_query=styrofoam+pool+float+diy',
      },
      {
        'title': 'Insulation Material',
        'difficulty': 'Easy',
        'description': 'Use for packaging or cold storage insulation',
        'estimatedValue': {'min': 3, 'max': 8},
        'youtubeUrl': 'https://www.youtube.com/results?search_query=styrofoam+insulation+uses',
      },
    ],
  };
}