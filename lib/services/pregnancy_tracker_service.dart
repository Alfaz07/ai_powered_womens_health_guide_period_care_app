import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pregnancy_data.dart';

class PregnancyTrackerService {
  static const String _pregnancyDataKey = 'pregnancy_data';

  // Save pregnancy data
  Future<void> savePregnancyData(PregnancyData pregnancyData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _pregnancyDataKey,
      jsonEncode(pregnancyData.toJson()),
    );
  }

  // Get pregnancy data
  Future<PregnancyData?> getPregnancyData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? dataString = prefs.getString(_pregnancyDataKey);

    if (dataString != null) {
      return PregnancyData.fromJson(jsonDecode(dataString));
    }
    return null;
  }

  // Calculate current week based on last period date
  int calculateCurrentWeek(DateTime lastPeriodDate) {
    final now = DateTime.now();
    final difference = now.difference(lastPeriodDate).inDays;
    return (difference / 7).floor();
  }

  // Calculate due date (40 weeks from last period)
  DateTime calculateDueDate(DateTime lastPeriodDate) {
    return lastPeriodDate.add(const Duration(days: 280)); // 40 weeks
  }

  // Get weekly pregnancy information
  WeeklyPregnancyInfo getWeeklyInfo(int week) {
    switch (week) {
      case 1:
      case 2:
        return WeeklyPregnancyInfo(
          week: week,
          babyDevelopment:
              'Fertilization occurs and the fertilized egg implants in the uterus.',
          motherChanges:
              'You may not notice any changes yet, but your body is preparing for pregnancy.',
          nutritionTips: [
            'Start taking folic acid supplements',
            'Eat a balanced diet rich in fruits and vegetables',
            'Stay hydrated by drinking plenty of water',
            'Avoid alcohol and smoking',
          ],
          precautions: [
            'Avoid raw or undercooked foods',
            'Limit caffeine intake',
            'Get adequate rest',
            'Start prenatal vitamins',
          ],
          symptoms: [
            'Fatigue',
            'Mild cramping',
            'Breast tenderness',
            'Mood swings',
          ],
        );

      case 4:
        return WeeklyPregnancyInfo(
          week: week,
          babyDevelopment:
              'The neural tube begins to form, which will become the brain and spinal cord.',
          motherChanges:
              'You may experience morning sickness, fatigue, and breast changes.',
          nutritionTips: [
            'Eat small, frequent meals to manage nausea',
            'Include iron-rich foods like spinach and lentils',
            'Consume adequate protein from lean sources',
            'Take prenatal vitamins regularly',
          ],
          precautions: [
            'Avoid high-mercury fish',
            'Stay away from unpasteurized dairy',
            'Limit processed foods',
            'Get regular prenatal checkups',
          ],
          symptoms: [
            'Morning sickness',
            'Fatigue',
            'Frequent urination',
            'Food aversions',
          ],
        );

      case 8:
        return WeeklyPregnancyInfo(
          week: week,
          babyDevelopment:
              'Major organs are forming. The heart is beating and facial features are developing.',
          motherChanges:
              'Your uterus is growing and you may need to urinate more frequently.',
          nutritionTips: [
            'Increase calcium intake for bone development',
            'Eat omega-3 rich foods for brain development',
            'Include plenty of fiber to prevent constipation',
            'Stay hydrated throughout the day',
          ],
          precautions: [
            'Avoid strenuous exercise',
            'Get adequate sleep',
            'Manage stress through relaxation techniques',
            'Wear comfortable, supportive clothing',
          ],
          symptoms: [
            'Nausea and vomiting',
            'Fatigue',
            'Breast tenderness',
            'Mood changes',
          ],
        );

      case 12:
        return WeeklyPregnancyInfo(
          week: week,
          babyDevelopment:
              'First trimester ends. Baby has all major organs and is about the size of a lime.',
          motherChanges:
              'Morning sickness usually improves. You may start showing a small bump.',
          nutritionTips: [
            'Focus on nutrient-dense foods',
            'Include plenty of colorful vegetables',
            'Eat lean proteins for muscle development',
            'Stay hydrated with water and healthy beverages',
          ],
          precautions: [
            'Continue prenatal care',
            'Exercise moderately with doctor approval',
            'Get adequate rest',
            'Avoid hot tubs and saunas',
          ],
          symptoms: [
            'Reduced nausea',
            'Increased energy',
            'Growing belly',
            'Hair and nail changes',
          ],
        );

      case 20:
        return WeeklyPregnancyInfo(
          week: week,
          babyDevelopment:
              'Halfway point! Baby can hear sounds and is very active. Gender can often be determined.',
          motherChanges:
              'You\'re likely showing clearly now. You may feel the baby move for the first time.',
          nutritionTips: [
            'Increase protein intake for baby\'s growth',
            'Eat iron-rich foods to prevent anemia',
            'Include healthy fats for brain development',
            'Stay well-hydrated',
          ],
          precautions: [
            'Sleep on your left side',
            'Avoid lying flat on your back',
            'Continue moderate exercise',
            'Monitor blood pressure',
          ],
          symptoms: [
            'Baby movements (quickening)',
            'Growing belly',
            'Back pain',
            'Leg cramps',
          ],
        );

      case 28:
        return WeeklyPregnancyInfo(
          week: week,
          babyDevelopment:
              'Third trimester begins. Baby\'s eyes can open and close, and brain is developing rapidly.',
          motherChanges:
              'You may experience Braxton Hicks contractions and increased back pain.',
          nutritionTips: [
            'Increase calcium for baby\'s bone development',
            'Eat protein-rich foods for growth',
            'Include healthy fats for brain development',
            'Stay hydrated to prevent swelling',
          ],
          precautions: [
            'Monitor for signs of preterm labor',
            'Get plenty of rest',
            'Practice good posture',
            'Avoid heavy lifting',
          ],
          symptoms: [
            'Braxton Hicks contractions',
            'Back pain',
            'Swelling in feet and ankles',
            'Shortness of breath',
          ],
        );

      case 36:
        return WeeklyPregnancyInfo(
          week: week,
          babyDevelopment:
              'Baby is almost full-term. Lungs are mature and baby is gaining weight rapidly.',
          motherChanges:
              'Baby may drop into the pelvis (lightening). You may feel increased pressure.',
          nutritionTips: [
            'Eat small, frequent meals',
            'Include plenty of fiber to prevent constipation',
            'Stay hydrated',
            'Focus on nutrient-dense foods',
          ],
          precautions: [
            'Watch for signs of labor',
            'Pack your hospital bag',
            'Get plenty of rest',
            'Avoid long trips',
          ],
          symptoms: [
            'Increased pelvic pressure',
            'Frequent urination',
            'Difficulty sleeping',
            'Nesting instinct',
          ],
        );

      default:
        return WeeklyPregnancyInfo(
          week: week,
          babyDevelopment: 'Your baby is growing and developing normally.',
          motherChanges:
              'Your body continues to adapt to support your growing baby.',
          nutritionTips: [
            'Eat a balanced diet',
            'Stay hydrated',
            'Take prenatal vitamins',
            'Get adequate rest',
          ],
          precautions: [
            'Continue prenatal care',
            'Exercise moderately',
            'Avoid harmful substances',
            'Get plenty of sleep',
          ],
          symptoms: [
            'Fatigue',
            'Mood changes',
            'Physical changes',
            'Hormonal fluctuations',
          ],
        );
    }
  }

  // Get nutrition tips by category
  List<NutritionTip> getNutritionTips() {
    return [
      NutritionTip(
        title: 'Iron-Rich Foods',
        description:
            'Iron is essential for preventing anemia during pregnancy.',
        category: 'iron',
        foodItems: [
          'Spinach',
          'Lentils',
          'Lean red meat',
          'Fortified cereals',
          'Beans',
        ],
      ),
      NutritionTip(
        title: 'Calcium Sources',
        description:
            'Calcium helps build strong bones and teeth for your baby.',
        category: 'calcium',
        foodItems: [
          'Milk',
          'Yogurt',
          'Cheese',
          'Leafy greens',
          'Fortified orange juice',
        ],
      ),
      NutritionTip(
        title: 'Protein-Rich Foods',
        description:
            'Protein is crucial for your baby\'s growth and development.',
        category: 'protein',
        foodItems: ['Lean meat', 'Fish', 'Eggs', 'Beans', 'Nuts and seeds'],
      ),
      NutritionTip(
        title: 'Folic Acid Sources',
        description:
            'Folic acid prevents neural tube defects in early pregnancy.',
        category: 'folic_acid',
        foodItems: [
          'Dark leafy greens',
          'Fortified cereals',
          'Beans',
          'Citrus fruits',
          'Avocado',
        ],
      ),
    ];
  }
}
