import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class FileUploadWidget extends StatelessWidget {
  final String label;
  final File? file;
  final String? existingUrl;
  final Function(File) onFilePicked;
  
  const FileUploadWidget({
    super.key,
    required this.label,
    this.file,
    this.existingUrl,
    required this.onFilePicked,
  });

  @override
  Widget build(BuildContext context) {
    final hasFile = file != null || existingUrl != null;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: hasFile ? Colors.green : Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                hasFile ? Icons.check_circle : Icons.upload_file,
                color: hasFile ? Colors.green : Colors.grey[700],
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              if (hasFile)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green[300]!),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check, color: Colors.green, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'Uploaded',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          
          // File preview
          if (hasFile) ...[
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: file != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: kIsWeb 
                        ? Image.network(
                            file!.path,
                            fit: BoxFit.cover,
                            height: 120,
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(Icons.file_present, size: 48, color: Colors.grey),
                              );
                            },
                          )
                        : Image.file(
                            file!,
                            fit: BoxFit.cover,
                            height: 120,
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(Icons.file_present, size: 48, color: Colors.grey),
                              );
                            },
                          ),
                    )
                  : existingUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            existingUrl!,
                            fit: BoxFit.cover,
                            height: 120,
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(Icons.file_present, size: 48, color: Colors.grey),
                              );
                            },
                          ),
                        )
                      : const SizedBox.shrink(),
            ),
            const SizedBox(height: 16),
          ],
          
          // Upload buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Camera button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final pickedFile = await _pickImage(ImageSource.camera, context);
                    if (pickedFile != null) {
                      onFilePicked(pickedFile);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8A2BE2),
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Camera'),
                ),
              ),
              const SizedBox(width: 16),
              
              // Gallery button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final pickedFile = await _pickImage(ImageSource.gallery, context);
                    if (pickedFile != null) {
                      onFilePicked(pickedFile);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.black87,
                  ),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Gallery'),
                ),
              ),
            ],
          ),
          
          if (hasFile) ...[
            const SizedBox(height: 8),
            Center(
              child: TextButton.icon(
                onPressed: () => onFilePicked(File('')), // Pass empty file to clear
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
                icon: const Icon(Icons.delete_outline),
                label: const Text('Remove File'),
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Future<File?> _pickImage(ImageSource source, BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source, 
        maxWidth: 1024,
        imageQuality: 80,
      );
      
      if (image != null) {
        if (kIsWeb) {
          // For web, we can't use File directly, so create a web-compatible File
          // We'll use XFile's path directly and handle it specially during upload
          return File(image.path);
        } else {
          // Create a temporary file in the app's temporary directory for mobile platforms
          final tempDir = Directory.systemTemp;
          final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
          final tempFile = File('${tempDir.path}/$fileName');
          
          // Read the image bytes and write to the temporary file
          final imageBytes = await image.readAsBytes();
          await tempFile.writeAsBytes(imageBytes);
          
          return tempFile;
        }
      }
      
      return null;
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
      return null;
    }
  }
}
