import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../models/brand_model.dart';
import '../../providers/brand_provider.dart';
import '../../services/brand_service.dart';

class BrandEditDialog extends ConsumerStatefulWidget {
  final Brand brand;
  final String brandId;

  const BrandEditDialog({
    super.key,
    required this.brand,
    required this.brandId,
  });

  @override
  ConsumerState<BrandEditDialog> createState() => _BrandEditDialogState();
}

class _BrandEditDialogState extends ConsumerState<BrandEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _addressController;
  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;

  File? _selectedLogoFile;
  String? _existingLogoPath;
  bool _isUpdating = false;
  bool _shouldDeleteLogo = false; // Track if user wants to delete logo

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.brand.brandName ?? '');
    _descriptionController = TextEditingController(
      text: widget.brand.description ?? '',
    );
    _addressController = TextEditingController(
      text: widget.brand.address ?? '',
    );
    _latitudeController = TextEditingController(
      text: widget.brand.latitude?.toString() ?? '',
    );
    _longitudeController = TextEditingController(
      text: widget.brand.longitude?.toString() ?? '',
    );
    _existingLogoPath = widget.brand.logoPath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedLogoFile = File(image.path);
          _shouldDeleteLogo = false; // New image selected, don't delete
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedLogoFile = File(image.path);
          _shouldDeleteLogo = false; // New image selected, don't delete
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error taking photo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Select Logo Source',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: Color(0xFFACBDAA),
              ),
              title: const Text(
                'Gallery',
                style: TextStyle(color: Colors.black),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFFACBDAA)),
              title: const Text(
                'Camera',
                style: TextStyle(color: Colors.black),
              ),
              onTap: () {
                Navigator.pop(context);
                _takePhoto();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _removeLogo() {
    setState(() {
      _selectedLogoFile = null;
      _shouldDeleteLogo = true; // Mark for deletion
    });
  }

  Future<void> _saveBrand() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isUpdating = true);

    try {
      final brandService = BrandService();
      String? logoPath = _existingLogoPath;

      // Handle logo deletion
      if (_shouldDeleteLogo && _existingLogoPath != null) {
        await brandService.deleteLogoFromStorage(_existingLogoPath!);
        await brandService.deleteLocalCache(_existingLogoPath!);
        logoPath = null;
      }

      // Handle new logo upload
      if (_selectedLogoFile != null) {
        // Delete old logo if exists
        if (_existingLogoPath != null && !_shouldDeleteLogo) {
          await brandService.deleteLogoFromStorage(_existingLogoPath!);
          await brandService.deleteLocalCache(_existingLogoPath!);
        }

        // Upload new logo
        logoPath = await brandService.uploadLogo(
          _selectedLogoFile!,
          widget.brandId,
        );

        if (logoPath == null) {
          throw Exception('Failed to upload logo');
        }
      }

      final updatedBrand = widget.brand.copyWith(
        brandName: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        latitude: _latitudeController.text.trim().isEmpty
            ? null
            : double.tryParse(_latitudeController.text.trim()),
        longitude: _longitudeController.text.trim().isEmpty
            ? null
            : double.tryParse(_longitudeController.text.trim()),
        logoPath: logoPath,
      );

      await brandService.updateBrand(updatedBrand);

      // Refresh the provider
      ref.invalidate(brandProvider(widget.brandId));

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Brand updated successfully',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Color(0xFFACBDAA),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.85,
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Edit Brand',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.black),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey[100],
                    ),
                  ),
                ],
              ),
            ),

            // Form Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Logo Section
                      const Text(
                        'Brand Logo',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),

                      Center(
                        child: Stack(
                          children: [
                            // Logo Display
                            if (_selectedLogoFile != null)
                              // Show newly selected logo
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFFACBDAA),
                                    width: 3,
                                  ),
                                ),
                                child: ClipOval(
                                  child: Image.file(
                                    _selectedLogoFile!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                            else if (_existingLogoPath != null &&
                                _existingLogoPath!.isNotEmpty &&
                                !_shouldDeleteLogo)
                              // Show existing logo from URL
                              FutureBuilder<String>(
                                future: BrandService().getLocalLogoPath(
                                  _existingLogoPath!,
                                ),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return Container(
                                      width: 120,
                                      height: 120,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: const Color(0xFFACBDAA),
                                          width: 3,
                                        ),
                                      ),
                                      child: ClipOval(
                                        child: Image.file(
                                          File(snapshot.data!),
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              Container(
                                                color: Colors.grey[100],
                                                child: Icon(
                                                  Icons.store,
                                                  size: 50,
                                                  color: Colors.grey[400],
                                                ),
                                              ),
                                        ),
                                      ),
                                    );
                                  }
                                  return Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.grey[100],
                                    ),
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        color: Color(0xFFACBDAA),
                                      ),
                                    ),
                                  );
                                },
                              )
                            else
                              // Show placeholder
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey[100],
                                  border: Border.all(
                                    color: Colors.grey[300]!,
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  Icons.store,
                                  size: 50,
                                  color: Colors.grey[400],
                                ),
                              ),

                            // Edit/Delete Buttons
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Row(
                                children: [
                                  IconButton(
                                    onPressed: _showImageSourceDialog,
                                    icon: const Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    style: IconButton.styleFrom(
                                      backgroundColor: const Color(0xFFACBDAA),
                                      padding: const EdgeInsets.all(8),
                                      minimumSize: const Size(36, 36),
                                    ),
                                  ),
                                  if (_selectedLogoFile != null ||
                                      (_existingLogoPath != null &&
                                          !_shouldDeleteLogo)) ...[
                                    const SizedBox(width: 8),
                                    IconButton(
                                      onPressed: _removeLogo,
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      style: IconButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        padding: const EdgeInsets.all(8),
                                        minimumSize: const Size(36, 36),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      _buildTextField(
                        controller: _nameController,
                        label: 'Brand Name',
                        hint: 'Enter brand name',
                        required: true,
                      ),
                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _descriptionController,
                        label: 'Description',
                        hint: 'Enter brand description',
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _addressController,
                        label: 'Address',
                        hint: 'Enter brand address',
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _latitudeController,
                              label: 'Latitude',
                              hint: '0.0',
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                    signed: true,
                                  ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: _longitudeController,
                              label: 'Longitude',
                              hint: '0.0',
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                    signed: true,
                                  ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ),

            // Footer Buttons
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey[200]!)),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isUpdating
                            ? null
                            : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black,
                          side: BorderSide(color: Colors.grey[300]!),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isUpdating ? null : _saveBrand,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFACBDAA),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _isUpdating
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Save Changes',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    bool required = false,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (required)
              const Text(
                ' *',
                style: TextStyle(color: Colors.red, fontSize: 14),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFACBDAA), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
          ),
          validator: (val) {
            if (required && (val?.trim().isEmpty ?? true)) {
              return 'This field is required';
            }
            if (keyboardType ==
                const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                )) {
              if (val != null &&
                  val.isNotEmpty &&
                  double.tryParse(val) == null) {
                return 'Please enter a valid number';
              }
            }
            return null;
          },
        ),
      ],
    );
  }
}
