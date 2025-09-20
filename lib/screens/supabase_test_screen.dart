import 'package:flutter/material.dart';
import 'package:jamiifund/services/supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseTestScreen extends StatefulWidget {
  const SupabaseTestScreen({super.key});

  @override
  State<SupabaseTestScreen> createState() => _SupabaseTestScreenState();
}

class _SupabaseTestScreenState extends State<SupabaseTestScreen> {
  String _status = 'Testing...';
  List<dynamic> _profiles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _testSupabase();
  }

  Future<void> _testSupabase() async {
    try {
      setState(() {
        _status = 'Testing Supabase connection...';
        _isLoading = true;
      });

      // Test if Supabase client is initialized
      final client = Supabase.instance.client;
      
      // Test if we can query the profiles table
      final response = await client.from('profiles').select().limit(10);
      
      setState(() {
        _status = 'Connection successful!';
        _profiles = response;
        _isLoading = false;
      });
      
      print('Raw profiles response: $response');
      print('Number of profiles: ${response.length}');
      
    } catch (e) {
      setState(() {
        _status = 'Error: ${e.toString()}';
        _isLoading = false;
      });
      print('Supabase test error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supabase Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _status,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _status.contains('Error') ? Colors.red : Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _profiles.isEmpty
                    ? const Center(child: Text('No profiles found in database'))
                    : Expanded(
                        child: ListView.builder(
                          itemCount: _profiles.length,
                          itemBuilder: (context, index) {
                            final profile = _profiles[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              child: ListTile(
                                title: Text(profile['full_name'] ?? 'No name'),
                                subtitle: Text(profile['email'] ?? 'No email'),
                                trailing: Text('ID: ${profile['id']}'),
                              ),
                            );
                          },
                        ),
                      ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _testSupabase,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
