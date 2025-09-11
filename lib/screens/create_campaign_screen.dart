import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:jamiifund/widgets/app_drawer.dart';
import 'package:jamiifund/widgets/app_bottom_nav_bar.dart';

class CreateCampaignScreen extends StatefulWidget {
  const CreateCampaignScreen({Key? key}) : super(key: key);

  @override
  State<CreateCampaignScreen> createState() => _CreateCampaignScreenState();
}

class _CreateCampaignScreenState extends State<CreateCampaignScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _goalAmountController = TextEditingController();
  
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  String _selectedCategory = 'Education';
  
  final List<String> _categories = [
    'Education',
    'Health',
    'Water',
    'Food',
    'Housing',
    'Agriculture',
    'Technology',
    'Other'
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _goalAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Create Campaign',
          style: GoogleFonts.nunito(
            color: const Color(0xFF8A2BE2),
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      drawer: const AppDrawer(),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 2),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildImageSelector(),
              const SizedBox(height: 24.0),
              _buildTitleField(),
              const SizedBox(height: 16.0),
              _buildCategoryDropdown(),
              const SizedBox(height: 16.0),
              _buildGoalAmountField(),
              const SizedBox(height: 16.0),
              _buildEndDatePicker(),
              const SizedBox(height: 16.0),
              _buildDescriptionField(),
              const SizedBox(height: 32.0),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSelector() {
    return InkWell(
      onTap: () {
        // TODO: Implement image picking
      },
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_photo_alternate_outlined,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 8.0),
              Text(
                'Add Campaign Image',
                style: GoogleFonts.nunito(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2, end: 0, duration: 300.ms);
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: InputDecoration(
        labelText: 'Campaign Title',
        labelStyle: GoogleFonts.nunito(color: Colors.grey[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a campaign title';
        }
        return null;
      },
    ).animate().fadeIn(duration: 300.ms, delay: 100.ms).slideY(begin: 0.2, end: 0, duration: 300.ms);
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      decoration: InputDecoration(
        labelText: 'Category',
        labelStyle: GoogleFonts.nunito(color: Colors.grey[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      items: _categories.map((String category) {
        return DropdownMenuItem<String>(
          value: category,
          child: Text(category),
        );
      }).toList(),
      onChanged: (String? newValue) {
        if (newValue != null) {
          setState(() {
            _selectedCategory = newValue;
          });
        }
      },
    ).animate().fadeIn(duration: 300.ms, delay: 150.ms).slideY(begin: 0.2, end: 0, duration: 300.ms);
  }

  Widget _buildGoalAmountField() {
    return TextFormField(
      controller: _goalAmountController,
      decoration: InputDecoration(
        labelText: 'Goal Amount (USD)',
        labelStyle: GoogleFonts.nunito(color: Colors.grey[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        filled: true,
        fillColor: Colors.white,
        prefixIcon: const Icon(Icons.attach_money),
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a goal amount';
        }
        if (double.tryParse(value) == null) {
          return 'Please enter a valid number';
        }
        if (double.parse(value) <= 0) {
          return 'Goal amount must be greater than zero';
        }
        return null;
      },
    ).animate().fadeIn(duration: 300.ms, delay: 200.ms).slideY(begin: 0.2, end: 0, duration: 300.ms);
  }

  Widget _buildEndDatePicker() {
    return GestureDetector(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _endDate,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null && picked != _endDate) {
          setState(() {
            _endDate = picked;
          });
        }
      },
      child: AbsorbPointer(
        child: TextFormField(
          decoration: InputDecoration(
            labelText: 'End Date',
            labelStyle: GoogleFonts.nunito(color: Colors.grey[600]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            filled: true,
            fillColor: Colors.white,
            suffixIcon: const Icon(Icons.calendar_today),
          ),
          controller: TextEditingController(
            text: "${_endDate.day}/${_endDate.month}/${_endDate.year}",
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 250.ms).slideY(begin: 0.2, end: 0, duration: 300.ms);
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: InputDecoration(
        labelText: 'Campaign Description',
        labelStyle: GoogleFonts.nunito(color: Colors.grey[600]),
        hintText: 'Describe your campaign and how the funds will be used...',
        hintStyle: GoogleFonts.nunito(color: Colors.grey[400]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      maxLines: 5,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a campaign description';
        }
        if (value.trim().length < 50) {
          return 'Description should be at least 50 characters';
        }
        return null;
      },
    ).animate().fadeIn(duration: 300.ms, delay: 300.ms).slideY(begin: 0.2, end: 0, duration: 300.ms);
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          // TODO: Implement campaign creation
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Creating campaign...'),
              backgroundColor: Color(0xFF8A2BE2),
            ),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF8A2BE2),
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      child: Text(
        'Create Campaign',
        style: GoogleFonts.nunito(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 350.ms).scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1), duration: 300.ms);
  }
}
