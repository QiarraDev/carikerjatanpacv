import 'package:flutter/material.dart';
import '../../core/api_service.dart';

class PostJobScreen extends StatefulWidget {
  const PostJobScreen({super.key});

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  // 🔥 Controllers
  final _titleController = TextEditingController();
  final _companyController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _salaryController = TextEditingController();
  final _skillsController = TextEditingController();
  
  // 📍 Location & Contact
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _websiteController = TextEditingController();

  //  pilihan
  String _workModel = "Onsite"; // Remote, Onsite, Hybrid
  String _jobType = "Full-time"; // Full-time, Freelance, Contract
  
  bool _isLoading = false;

  void _submit() async {
    if (_titleController.text.isEmpty || _companyController.text.isEmpty || _salaryController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mohon isi field wajib (*)")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final jobData = {
        "title": _titleController.text,
        "company": _companyController.text,
        "description": _descriptionController.text,
        "salary": _salaryController.text,
        "location": _addressController.text,
        "contact_phone": _phoneController.text,
        "company_website": _websiteController.text,
        "work_model": _workModel,
        "job_type": _jobType,
        "required_skills": _skillsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        "min_score": 70,
      };

      await ApiService().createJob(jobData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Job berhasil dipost 🚀"), backgroundColor: Color(0xFF10B981)),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal memposting job: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Buat Lowongan Lengkap"),
        backgroundColor: const Color(0xFF10B981),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle("Informasi Dasar"),
            _buildLabel("Nama Pekerjaan *"),
            _buildTextField(_titleController, "Contoh: Senior Mobile Developer"),

            const SizedBox(height: 16),
            _buildLabel("Nama Perusahaan *"),
            _buildTextField(_companyController, "Nama Perusahaan Anda"),

            const SizedBox(height: 16),
            _buildLabel("Range Gaji (jt/bulan) *"),
            _buildTextField(_salaryController, "Contoh: 10 - 15", keyboardType: TextInputType.number),

            const SizedBox(height: 24),
            _sectionTitle("Jenis & Model Kerja"),
            _buildLabel("Model Kerja"),
            _buildChoiceChips(
              options: ["Onsite", "Remote", "Hybrid"],
              selected: _workModel,
              onSelected: (val) => setState(() => _workModel = val),
            ),
            
            const SizedBox(height: 16),
            _buildLabel("Jenis Pekerjaan"),
            _buildChoiceChips(
              options: ["Full-time", "Freelance", "Contract"],
              selected: _jobType,
              onSelected: (val) => setState(() => _jobType = val),
            ),

            const SizedBox(height: 24),
            _sectionTitle("Kontak & Lokasi"),
            _buildLabel("Alamat Lengkap"),
            _buildTextField(_addressController, "Jl. Sudirman No. 123, Jakarta", maxLines: 2),

            const SizedBox(height: 16),
            _buildLabel("No. WhatsApp / Telp (Optional)"),
            _buildTextField(_phoneController, "08123456789", keyboardType: TextInputType.phone),

            const SizedBox(height: 16),
            _buildLabel("Website Perusahaan (Optional)"),
            _buildTextField(_websiteController, "https://company.com"),

            const SizedBox(height: 24),
            _sectionTitle("Detail Tambahan"),
            _buildLabel("Keahlian (Pisahkan dengan koma)"),
            _buildTextField(_skillsController, "Flutter, Dart, Firebase"),

            const SizedBox(height: 16),
            _buildLabel("Deskripsi Pekerjaan"),
            _buildTextField(_descriptionController, "Jelaskan tanggung jawab...", maxLines: 4),

            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 5,
                ),
                child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("PUBLIKASIKAN LOWONGAN", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF64748B))),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildChoiceChips({required List<String> options, required String selected, required ValueChanged<String> onSelected}) {
    return Wrap(
      spacing: 12,
      children: options.map((opt) {
        final isSelected = selected == opt;
        return ChoiceChip(
          label: Text(opt),
          selected: isSelected,
          onSelected: (_) => onSelected(opt),
          selectedColor: const Color(0xFF10B981).withOpacity(0.2),
          labelStyle: TextStyle(
            color: isSelected ? const Color(0xFF059669) : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          backgroundColor: Colors.white,
          side: BorderSide(color: isSelected ? const Color(0xFF10B981) : Colors.grey.shade200),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        );
      }).toList(),
    );
  }
}
