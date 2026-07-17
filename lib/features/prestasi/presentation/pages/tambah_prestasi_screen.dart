import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:sikarema_mobile/app/theme/app_colors.dart';
import 'package:sikarema_mobile/app/theme/app_text_styles.dart';
import 'package:sikarema_mobile/features/prestasi/data/models/prestasi_model.dart';
import 'package:sikarema_mobile/features/prestasi/data/services/prestasi_master_service.dart';
import 'package:sikarema_mobile/features/prestasi/data/services/prestasi_service.dart';

/// =====================================================================
/// TAMBAH PRESTASI SCREEN
/// =====================================================================
/// Catatan:
/// - Submit ke POST /api/v1/prestasi via PrestasiService.createPrestasi()
///   menggunakan multipart/form-data.
/// - Dropdown Kategori & Tingkat memakai PrestasiMasterService
///   (placeholder statis, mudah diganti API nanti tanpa mengubah UI).
/// - Field & nama parameter mengikuti spesifikasi API secara persis:
///   id_kategori, id_tingkat, nama_kegiatan, penyelenggara,
///   tanggal_kegiatan (YYYY-MM-DD), juara, file_sertifikat.
/// - Setelah berhasil: Snackbar dengan message dari API, lalu kembali
///   ke PrestasiScreen membawa sinyal (true) untuk memicu refresh list.
/// =====================================================================

class TambahPrestasiScreen extends StatefulWidget {
  const TambahPrestasiScreen({super.key});

  @override
  State<TambahPrestasiScreen> createState() => _TambahPrestasiScreenState();
}

class _TambahPrestasiScreenState extends State<TambahPrestasiScreen> {
  final _formKey = GlobalKey<FormState>();
  final PrestasiService _prestasiService = PrestasiService();
  final PrestasiMasterService _masterService = PrestasiMasterService();

  final _namaKegiatanController = TextEditingController();
  final _penyelenggaraController = TextEditingController();
  final _juaraController = TextEditingController();
  final _tanggalController = TextEditingController();

  bool _isLoadingMaster = true;
  String? _masterErrorMessage;
  List<MasterOption> _kategoriList = [];
  List<MasterOption> _tingkatList = [];

  MasterOption? _selectedKategori;
  MasterOption? _selectedTingkat;
  DateTime? _selectedTanggal;
  File? _selectedFile;

  bool _isSubmitting = false;
  String? _submitErrorMessage;

  @override
  void initState() {
    super.initState();
    _fetchMasterData();
  }

  @override
  void dispose() {
    _namaKegiatanController.dispose();
    _penyelenggaraController.dispose();
    _juaraController.dispose();
    _tanggalController.dispose();
    super.dispose();
  }

  Future<void> _fetchMasterData() async {
    setState(() {
      _isLoadingMaster = true;
      _masterErrorMessage = null;
    });

    try {
      final results = await Future.wait([
        _masterService.getKategoriList(),
        _masterService.getTingkatList(),
      ]);
      if (!mounted) return;
      setState(() {
        _kategoriList = results[0];
        _tingkatList = results[1];
        _isLoadingMaster = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _masterErrorMessage = 'Gagal memuat data kategori/tingkat.';
        _isLoadingMaster = false;
      });
    }
  }

  Future<void> _pickTanggal() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedTanggal ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
    );
    if (picked == null) return;
    setState(() {
      _selectedTanggal = picked;
      _tanggalController.text =
          '${picked.year.toString().padLeft(4, '0')}-'
          '${picked.month.toString().padLeft(2, '0')}-'
          '${picked.day.toString().padLeft(2, '0')}';
    });
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result == null || result.files.single.path == null) return;
    setState(() {
      _selectedFile = File(result.files.single.path!);
    });
  }

  Future<void> _submit() async {
    final isFormValid = _formKey.currentState?.validate() ?? false;

    if (!isFormValid) return;

    if (_selectedKategori == null) {
      setState(() => _submitErrorMessage = 'Kategori wajib dipilih.');
      return;
    }
    if (_selectedTingkat == null) {
      setState(() => _submitErrorMessage = 'Tingkat wajib dipilih.');
      return;
    }
    if (_selectedFile == null) {
      setState(() => _submitErrorMessage = 'Sertifikat wajib diunggah.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _submitErrorMessage = null;
    });

    try {
      final response = await _prestasiService.createPrestasi(
        idKategori: _selectedKategori!.id,
        idTingkat: _selectedTingkat!.id,
        namaKegiatan: _namaKegiatanController.text.trim(),
        penyelenggara: _penyelenggaraController.text.trim(),
        tanggalKegiatan: _tanggalController.text.trim(),
        juara: _juaraController.text.trim(),
        fileSertifikat: _selectedFile!,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message),
          backgroundColor: AppColors.success,
        ),
      );

      Navigator.pop(context, true);
    } on DioException catch (e) {
      if (!mounted) return;
      final message = e.response?.data is Map<String, dynamic>
          ? (e.response?.data['message']?.toString() ??
                'Gagal mengajukan prestasi.')
          : 'Terjadi kesalahan saat mengajukan prestasi.';
      setState(() {
        _submitErrorMessage = message;
        _isSubmitting = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _submitErrorMessage = 'Terjadi kesalahan saat mengajukan prestasi.';
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text('Tambah Prestasi', style: AppTextStyles.titleMedium),
      ),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_isLoadingMaster) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryBlue),
      );
    }

    if (_masterErrorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: AppColors.danger,
                size: 40,
              ),
              const SizedBox(height: 12),
              Text(
                _masterErrorMessage!,
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchMasterData,
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _FieldLabel('Nama Prestasi'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _namaKegiatanController,
              hint: 'Masukkan nama prestasi',
            ),
            const SizedBox(height: 16),

            _FieldLabel('Kategori'),
            const SizedBox(height: 8),
            _buildDropdown(
              value: _selectedKategori,
              items: _kategoriList,
              hint: 'Pilih kategori',
              onChanged: (value) => setState(() => _selectedKategori = value),
            ),
            const SizedBox(height: 16),

            _FieldLabel('Tingkat'),
            const SizedBox(height: 8),
            _buildDropdown(
              value: _selectedTingkat,
              items: _tingkatList,
              hint: 'Pilih tingkat',
              onChanged: (value) => setState(() => _selectedTingkat = value),
            ),
            const SizedBox(height: 16),

            _FieldLabel('Penyelenggara'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _penyelenggaraController,
              hint: 'Masukkan nama penyelenggara',
            ),
            const SizedBox(height: 16),

            _FieldLabel('Tanggal Prestasi'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _tanggalController,
              hint: 'Pilih tanggal',
              readOnly: true,
              onTap: _pickTanggal,
              suffixIcon: Icons.calendar_today_outlined,
            ),
            const SizedBox(height: 16),

            _FieldLabel('Predikat / Juara'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _juaraController,
              hint: 'Contoh: Juara 1 Kategori Poster',
            ),
            const SizedBox(height: 16),

            _FieldLabel('Upload Sertifikat'),
            const SizedBox(height: 8),
            _UploadFileField(file: _selectedFile, onTap: _pickFile),

            if (_submitErrorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _submitErrorMessage!,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.danger,
                  fontSize: 12,
                ),
              ),
            ],

            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: AppColors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'Ajukan Prestasi',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
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
    required String hint,
    bool readOnly = false,
    VoidCallback? onTap,
    IconData? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      style: AppTextStyles.bodyMedium,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Field ini wajib diisi.';
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey),
        suffixIcon: suffixIcon != null
            ? Icon(suffixIcon, color: AppColors.grey, size: 20)
            : null,
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.grey.withValues(alpha: 0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.grey.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primaryBlue),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required MasterOption? value,
    required List<MasterOption> items,
    required String hint,
    required ValueChanged<MasterOption?> onChanged,
  }) {
    return DropdownButtonFormField<MasterOption>(
      initialValue: value,
      isExpanded: true,
      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.black),
      validator: (value) {
        if (value == null) return 'Field ini wajib dipilih.';
        return null;
      },
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey),
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 4,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.grey.withValues(alpha: 0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.grey.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primaryBlue),
        ),
      ),
      items: items
          .map(
            (option) => DropdownMenuItem<MasterOption>(
              value: option,
              child: Text(option.label, style: AppTextStyles.bodyMedium),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}

/// =====================================================================
/// LABEL FIELD
/// =====================================================================
class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.bodyMedium.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

/// =====================================================================
/// UPLOAD FILE FIELD
/// =====================================================================
class _UploadFileField extends StatelessWidget {
  const _UploadFileField({required this.file, required this.onTap});

  final File? file;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fileName = file?.path.split('/').last;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: fileName != null
                ? AppColors.primaryBlue.withValues(alpha: 0.4)
                : AppColors.grey.withValues(alpha: 0.25),
          ),
        ),
        child: fileName == null
            ? Column(
                children: [
                  Icon(
                    Icons.upload_file_outlined,
                    color: AppColors.grey.withValues(alpha: 0.7),
                    size: 28,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ketuk untuk memilih file sertifikat',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 12,
                      color: AppColors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'PDF, JPG, atau PNG',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 11,
                      color: AppColors.grey.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              )
            : Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.insert_drive_file_outlined,
                      color: AppColors.primaryBlue,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      fileName,
                      style: AppTextStyles.bodyMedium.copyWith(fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    'Ganti',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 12,
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}