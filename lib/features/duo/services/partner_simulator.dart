import 'dart:math';
import '../models/partner_model.dart';

class PartnerSimulator {
  static PartnerModel generateMockPartner() {
    final random = Random();
    final todayHabitsTotal = 5;
    final todayHabitsDone = random.nextInt(3) + 3; // 3 to 5 done
    
    return PartnerModel(
      id: 'mira_id',
      name: 'Mira',
      avatarEmoji: '🐰',
      lastActiveAt: DateTime.now().subtract(Duration(minutes: random.nextInt(240))),
      todayHabitsDone: todayHabitsDone,
      todayHabitsTotal: todayHabitsTotal,
      currentStreak: 15,
    );
  }

  static Map<String, List<double>> generateWeeklyReport() {
    final random = Random();
    return {
      'you': List.generate(7, (_) => 0.6 + random.nextDouble() * 0.4),
      'partner': List.generate(7, (_) => 0.5 + random.nextDouble() * 0.5),
    };
  }
}
