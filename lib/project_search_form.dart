import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ProjectSearchForm extends StatefulWidget {
  const ProjectSearchForm({super.key});

  @override
  State<ProjectSearchForm> createState() => _ProjectSearchFormState();
}

class _ProjectSearchFormState extends State<ProjectSearchForm> {
  final _formKey = GlobalKey<FormState>();
  final _ideaTitleController = TextEditingController();
  final _featuresController = TextEditingController();
  final _techStackController = TextEditingController();
  final _targetAudienceController = TextEditingController();
  final _ideaDescriptionController = TextEditingController();
  bool _isLoading = false;
  List<Map<String, dynamic>> _searchResults = [];
  double _threshold = 0.3;
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
    _ideaTitleController.dispose();
    _featuresController.dispose();
    _techStackController.dispose();
    _targetAudienceController.dispose();
    _ideaDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _searchProjects() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Convert comma-separated strings to lists
      List<String> featuresRequired = _featuresController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      
      List<String> preferredTechStack = _techStackController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final response = await http.post(
        Uri.parse('http://localhost:8080/api/projects/search'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'ideaTitle': _ideaTitleController.text,
          'featuresRequired': featuresRequired,
          'preferredTechStack': preferredTechStack,
          'targetAudience': _targetAudienceController.text,
          'ideaDescription': _ideaDescriptionController.text,
          'domain': _selectedDomain ?? '',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _searchResults = List<Map<String, dynamic>>.from(data['results'] ?? []);
          _threshold = (data['threshold'] ?? 0.3).toDouble();
        });
        
        if (mounted) {
          if (_searchResults.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('❌ No similar projects found'),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      } else {
        throw Exception('Failed to search projects');
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
          'Project Finder',
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
                controller: _ideaTitleController,
                label: 'Idea Title',
                maxLines: 1,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _featuresController,
                label: 'Features Required',
                maxLines: 5,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _techStackController,
                label: 'Preferred Tech Stack (comma-separated)',
                maxLines: 1,
              ),
              const SizedBox(height: 20),
              _buildDomainDropdown(),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _targetAudienceController,
                label: 'Target Audience',
                maxLines: 1,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _ideaDescriptionController,
                label: 'Idea Description',
                maxLines: 5,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _searchProjects,
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
                        'Search',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(height: 32),
              
              // Display search results
              if (_searchResults.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🔍 Found ${_searchResults.length} similar projects',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ..._searchResults.map((result) {
                      var project = result['project'];
                      var score = (result['similarityScore'] as num).toDouble();
                      var matchPercentage = (result['matchPercentage'] as num).toInt();
                      
                      return _buildResultCard(
                        title: project['title'] ?? 'N/A',
                        description: project['description'] ?? 'N/A',
                        techStack: List<String>.from(project['techStack'] ?? []),
                        features: List<String>.from(project['features'] ?? []),
                        similarity: score,
                        matchPercentage: matchPercentage,
                      );
                    }),
                  ],
                )
              else if (_searchResults.isEmpty && !_isLoading && _ideaTitleController.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    '❌ No projects found matching your criteria',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard({
    required String title,
    required String description,
    required List<String> techStack,
    required List<String> features,
    required double similarity,
    required int matchPercentage,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getScoreColor(matchPercentage).withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getScoreColor(matchPercentage),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$matchPercentage%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              color: Colors.grey[300],
              fontSize: 12,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (techStack.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: techStack.map((tech) {
                return Chip(
                  label: Text(tech),
                  labelStyle: const TextStyle(color: Colors.white, fontSize: 11),
                  backgroundColor: Colors.blue[900],
                );
              }).toList(),
            ),
          ],
          if (features.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: features.map((feature) {
                return Chip(
                  label: Text(feature),
                  labelStyle: const TextStyle(color: Colors.white, fontSize: 11),
                  backgroundColor: Colors.green[900],
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            'Similarity Score: ${(similarity * 100).toStringAsFixed(2)}%',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(int percentage) {
    if (percentage >= 70) return Colors.green;
    if (percentage >= 50) return Colors.yellow[700]!;
    return Colors.orange;
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
            'Select Domain (Optional)',
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
