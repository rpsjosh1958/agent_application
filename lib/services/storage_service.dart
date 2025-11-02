import 'package:shared_preferences/shared_preferences.dart';
import '../models/prospect.dart';

class StorageService {
  static const String _prospectsKey = 'prospects';
  static const String _currentFormKey = 'current_form';

  static Future<List<Prospect>> getProspects() async {
    final prefs = await SharedPreferences.getInstance();
    final prospectsJson = prefs.getStringList(_prospectsKey) ?? [];
    return prospectsJson.map((json) => Prospect.fromJson(json)).toList();
  }

  static Future<List<Prospect>> getIncompleteProspects() async {
    final prospects = await getProspects();
    return prospects.where((prospect) => !prospect.isComplete).toList();
  }

  static Future<List<Prospect>> getCompleteProspects() async {
    final prospects = await getProspects();
    return prospects.where((prospect) => prospect.isComplete).toList();
  }

  static Future<void> saveProspect(Prospect prospect) async {
    final prefs = await SharedPreferences.getInstance();
    final prospects = await getProspects();
    
    final existingIndex = prospects.indexWhere((p) => p.id == prospect.id);
    if (existingIndex >= 0) {
      prospects[existingIndex] = prospect;
    } else {
      prospects.add(prospect);
    }
    
    final prospectsJson = prospects.map((p) => p.toJson()).toList();
    await prefs.setStringList(_prospectsKey, prospectsJson);
  }

  static Future<void> deleteProspect(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final prospects = await getProspects();
    prospects.removeWhere((p) => p.id == id);
    
    final prospectsJson = prospects.map((p) => p.toJson()).toList();
    await prefs.setStringList(_prospectsKey, prospectsJson);
  }

  static Future<void> saveCurrentForm(Prospect prospect) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentFormKey, prospect.toJson());
  }

  static Future<Prospect?> getCurrentForm() async {
    final prefs = await SharedPreferences.getInstance();
    final formJson = prefs.getString(_currentFormKey);
    if (formJson != null) {
      return Prospect.fromJson(formJson);
    }
    return null;
  }

  static Future<void> clearCurrentForm() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentFormKey);
  }

  static Future<List<Prospect>> searchProspects(String query) async {
    final prospects = await getProspects();
    if (query.isEmpty) return prospects;
    
    return prospects.where((prospect) {
      return prospect.fullName.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  static Future<List<Prospect>> getTodaysProspects() async {
    final prospects = await getProspects();
    final today = DateTime.now();
    
    return prospects.where((prospect) {
      return prospect.onboardedDate.year == today.year &&
          prospect.onboardedDate.month == today.month &&
          prospect.onboardedDate.day == today.day;
    }).toList();
  }

  static Future<List<Prospect>> getPreviousProspects() async {
    final prospects = await getProspects();
    final today = DateTime.now();
    
    return prospects.where((prospect) {
      return !(prospect.onboardedDate.year == today.year &&
          prospect.onboardedDate.month == today.month &&
          prospect.onboardedDate.day == today.day);
    }).toList();
  }
}
