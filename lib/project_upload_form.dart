import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ProjectUploadForm extends StatefulWidget {
  const ProjectUploadForm({super.key});

  @override
  State<ProjectUploadForm> createState() => _ProjectUploadFormState();
}

class _ProjectUploadFormState extends State<ProjectUploadForm> {
  final _formKey = GlobalKey<FormState>();
  final _projectTitleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _techStackController = TextEditingController();
  final _githubUrlController = TextEditingController();
  final _featuresController = TextEditingController();
  final _targetAudienceController = TextEditingController();
  bool _isLoading = false;
  String? _selectedDomain;

  final List<String> _domainOptions = [
    'E-commerce',
    'Social Media',
    'Streaming Platform',
    'Marketplace',
    'Booking Platform',
    'Job Portal',
    'Learning Platform',
    'Community Platform',
    'Portfolio Website',
    'News Platform',
    
    'FinTech',
    'HealthTech',
    'EdTech',
    'TravelTech',
    'FoodTech',
    'AgriTech',
    'Real Estate Tech',
    'Logistics Platform',
    'CRM System',
    
    'AI Tools',
    'Machine Learning',
    'Data Analytics',
    'Recommendation System',
    'Chatbot Platform',
    'Search Engine',
    'Automation Tools',
    'Image Processing',
    'Speech Processing',
    
    'Cloud Platform',
    'DevOps Tools',
    'API Platform',
    'Microservices',
    'SaaS Platform',
    'Monitoring System',
    'Authentication System',
    
    'Cybersecurity',
    'Identity Management',
    'Payment System',
    'Fraud Detection',
    'Network Management',
    
    'Other',
  ];

  @override
  void dispose() {
    _projectTitleController.dispose();
    _descriptionController.dispose();
    _techStackController.dispose();
    _githubUrlController.dispose();
    _featuresController.dispose();
    _targetAudienceController.dispose();
    super.dispose();
  }

  Future<void> _submitProject() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Convert comma-separated strings to lists
      List<String> techStack = _techStackController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      
      List<String> features = _featuresController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final response = await http.post(
        Uri.parse('http://localhost:8080/api/projects/upload'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': _projectTitleController.text,
          'description': _descriptionController.text,
          'techStack': techStack,
          'githubUrl': _githubUrlController.text,
          'features': features,
          'targetAudience': _targetAudienceController.text,
          'domain': _selectedDomain ?? '',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ ${data['message']}\nEmbedding dimensions: ${data['embeddingDimensions']}'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 4),
            ),
          );
          // Clear form
          _projectTitleController.clear();
          _descriptionController.clear();
          _techStackController.clear();
          _githubUrlController.clear();
          _featuresController.clear();
          _targetAudienceController.clear();
          setState(() {
            _selectedDomain = null;
          });
        }
      } else {
        throw Exception('Failed to upload project');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Project Upload',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              _buildTextField(
                controller: _projectTitleController,
                label: 'Project Title',
                maxLines: 1,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _descriptionController,
                label: 'Project Description / README',
                maxLines: 5,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _techStackController,
                label: 'Needed Tech Stack (comma-separated)',
                maxLines: 1,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _githubUrlController,
                label: 'GitHub Repository URL',
                maxLines: 1,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _featuresController,
                label: 'Features Provided',
                maxLines: 5,
              ),
              const SizedBox(height: 20),
              _buildDomainDropdown(),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _targetAudienceController,
                label: 'Target Audience',
                maxLines: 1,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitProject,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                        ),
                      )
                    : const Text(
                        'Submit',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required int maxLines,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.grey[900],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[800]!, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white, width: 1),
        ),
      ),
    );
  }

  Widget _buildDomainDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!, width: 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedDomain,
          hint: const Text(
            'Select Domain *',
            style: TextStyle(color: Colors.grey),
          ),
          isExpanded: true,
          dropdownColor: Colors.grey[900],
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
          style: const TextStyle(color: Colors.white, fontSize: 16),
          items: _domainOptions.map((String domain) {
            return DropdownMenuItem<String>(
              value: domain,
              child: Text(
                domain,
                style: const TextStyle(color: Colors.white),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedDomain = newValue;
            });
          },
        ),
      ),
    );
  }
}
