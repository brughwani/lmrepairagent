import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class OfflineService {
  // ── Storage keys ──────────────────────────────────────────────────
  static const _complaintsKey = 'cached_complaints';
  static const _brandsKey = 'cached_brands';
  static const _villagesKey = 'cached_villages';
  static const _pendingUpdatesKey = 'pending_updates';

  static String _dealersKey(String village) =>
      'cached_dealers_${village.toLowerCase()}';
  static String _categoriesKey(String brand) =>
      'cached_categories_${brand.toLowerCase()}';
  static String _productsKey(String brand, String category) =>
      'cached_products_${brand.toLowerCase()}_${category.toLowerCase()}';

  // ── Complaints ────────────────────────────────────────────────────

  static Future<void> saveComplaints(
      Map<String, List<dynamic>> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_complaintsKey, jsonEncode(data));
  }

  static Future<Map<String, List<dynamic>>?> loadComplaints() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_complaintsKey);
    if (raw == null) return null;
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map(
        (k, v) => MapEntry(k, (v as List).cast<dynamic>()));
  }

  // ── Brands ────────────────────────────────────────────────────────

  static Future<void> saveBrands(List<String> brands) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_brandsKey, brands);
  }

  static Future<List<String>> loadBrands() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_brandsKey) ?? [];
  }

  // ── Villages ──────────────────────────────────────────────────────

  static Future<void> saveVillages(List<String> villages) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_villagesKey, villages);
  }

  static Future<List<String>> loadVillages() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_villagesKey) ?? [];
  }

  // ── Dealers (keyed per village) ───────────────────────────────────

  static Future<void> saveDealers(
      String village, List<String> dealers) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_dealersKey(village), dealers);
  }

  static Future<List<String>> loadDealers(String village) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_dealersKey(village)) ?? [];
  }

  // ── Categories (keyed per brand) ──────────────────────────────────

  static Future<void> saveCategories(
      String brand, List<String> categories) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_categoriesKey(brand), categories);
  }

  static Future<List<String>> loadCategories(String brand) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_categoriesKey(brand)) ?? [];
  }

  // ── Products (keyed per brand+category) ───────────────────────────

  static Future<void> saveProducts(
      String brand, String category, List<String> products) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        _productsKey(brand, category), products);
  }

  static Future<List<String>> loadProducts(
      String brand, String category) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_productsKey(brand, category)) ?? [];
  }

  // ── Pending update queue ──────────────────────────────────────────

  static Future<void> enqueuePendingUpdate(
      Map<String, dynamic> payload) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_pendingUpdatesKey);
    final List<dynamic> queue =
        raw != null ? jsonDecode(raw) : [];
    queue.add(payload);
    await prefs.setString(_pendingUpdatesKey, jsonEncode(queue));
  }

  static Future<List<Map<String, dynamic>>> getPendingUpdates() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_pendingUpdatesKey);
    if (raw == null) return [];
    return (jsonDecode(raw) as List)
        .cast<Map<String, dynamic>>();
  }

  static Future<void> removePendingUpdateAt(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_pendingUpdatesKey);
    if (raw == null) return;
    final List<dynamic> queue = jsonDecode(raw);
    if (index < queue.length) {
      queue.removeAt(index);
      await prefs.setString(_pendingUpdatesKey, jsonEncode(queue));
    }
  }

  static Future<void> clearPendingUpdates() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pendingUpdatesKey);
  }

  static Future<int> pendingUpdateCount() async {
    return (await getPendingUpdates()).length;
  }
}
