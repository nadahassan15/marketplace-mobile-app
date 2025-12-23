import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import '../models/brand_model.dart';

class BrandService {
  final SupabaseClient supabase = Supabase.instance.client;
  static const String storageBucket = 'brand-logos'; // Your bucket name

  // Get the assets/images cache directory path
  Future<String> _getAssetsImagesPath() async {
    final directory = await getApplicationDocumentsDirectory();
    final assetsDir = Directory('${directory.path}/assets/images');

    if (!await assetsDir.exists()) {
      await assetsDir.create(recursive: true);
    }

    return assetsDir.path;
  }

  // Upload logo to Supabase Storage and return URL
  Future<String?> uploadLogo(File logoFile, String brandId) async {
    try {
      final fileName =
          '${brandId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = 'logos/$fileName';

      // Upload to Supabase Storage
      await supabase.storage.from(storageBucket).upload(filePath, logoFile);

      // Get public URL
      final url = supabase.storage.from(storageBucket).getPublicUrl(filePath);

      print('Logo uploaded to Supabase: $url');

      // Also cache it locally
      await _cacheImageLocally(url, logoFile);

      return url;
    } catch (e) {
      print('Error uploading logo: $e');
      return null;
    }
  }

  // Cache image locally for faster loading
  Future<void> _cacheImageLocally(String url, File sourceFile) async {
    try {
      final assetsPath = await _getAssetsImagesPath();
      final fileName = url.split('/').last;
      final localPath = '$assetsPath/$fileName';

      await sourceFile.copy(localPath);
      print('Logo cached locally: $localPath');
    } catch (e) {
      print('Error caching logo: $e');
    }
  }

  // Get local cached path or download from URL
  Future<String> getLocalLogoPath(String logoUrl) async {
    try {
      final assetsPath = await _getAssetsImagesPath();
      final fileName = logoUrl.split('/').last;
      final localPath = '$assetsPath/$fileName';
      final localFile = File(localPath);

      // If cached locally, return it
      if (await localFile.exists()) {
        print('Using cached logo: $localPath');
        return localPath;
      }

      // Otherwise download and cache it
      print('Downloading logo from: $logoUrl');
      final response = await http.get(Uri.parse(logoUrl));

      if (response.statusCode == 200) {
        await localFile.writeAsBytes(response.bodyBytes);
        print('Logo downloaded and cached: $localPath');
        return localPath;
      } else {
        throw Exception('Failed to download logo: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting logo: $e');
      rethrow;
    }
  }

  // Delete logo from Supabase Storage
  Future<void> deleteLogoFromStorage(String logoUrl) async {
    try {
      // Extract file path from URL
      final uri = Uri.parse(logoUrl);
      final pathSegments = uri.pathSegments;
      final bucketIndex = pathSegments.indexOf(storageBucket);

      if (bucketIndex != -1 && bucketIndex < pathSegments.length - 1) {
        final filePath = pathSegments.sublist(bucketIndex + 1).join('/');

        await supabase.storage.from(storageBucket).remove([filePath]);

        print('Logo deleted from Supabase Storage: $filePath');
      }
    } catch (e) {
      print('Error deleting logo from storage: $e');
    }
  }

  // Delete local cached logo
  Future<void> deleteLocalCache(String logoUrl) async {
    try {
      final assetsPath = await _getAssetsImagesPath();
      final fileName = logoUrl.split('/').last;
      final file = File('$assetsPath/$fileName');

      if (await file.exists()) {
        await file.delete();
        print('Local cache deleted: $fileName');
      }
    } catch (e) {
      print('Error deleting local cache: $e');
    }
  }

  Future<Brand> getBrand(String brandId) async {
    try {
      print('Loading brand with ID: $brandId');

      final response = await supabase
          .from('brandowner')
          .select()
          .eq('brandid', brandId)
          .single();

      print('Brand data loaded: $response');

      return Brand.fromJson(response);
    } catch (e, stackTrace) {
      print('Error loading brand: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> updateBrand(Brand brand) async {
    try {
      print('Updating brand: ${brand.brandId}');
      print('Update data: ${brand.toJson()}');

      final response = await supabase
          .from('brandowner')
          .update(brand.toJson())
          .eq('brandid', brand.brandId)
          .select();

      print('Brand updated successfully: $response');
    } catch (e) {
      print('Error updating brand: $e');
      rethrow;
    }
  }
}
