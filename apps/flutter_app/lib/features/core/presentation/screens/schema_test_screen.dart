import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SchemaTestScreen extends StatefulWidget {
  const SchemaTestScreen({super.key});

  @override
  State<SchemaTestScreen> createState() => _SchemaTestScreenState();
}

class _SchemaTestScreenState extends State<SchemaTestScreen> {
  String _status = 'Testing database schema...';
  Map<String, bool> _tableStatus = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkTables();
  }

  Future<void> _checkTables() async {
    try {
      setState(() {
        _isLoading = true;
        _status = 'Checking database tables...';
      });

      final supabase = Supabase.instance.client;
      
      // List of expected tables based on the schema
      final expectedTables = [
        'users',
        'profiles',
        'clothing_items',
        'clothing_categories',
        'combinations',
        'combination_items',
        'follows',
        'likes',
        'social_posts',
        'notifications'
      ];
      
      Map<String, bool> tableResults = {};
      
      for (String table in expectedTables) {
        try {
          // Try to query each table
          await supabase.from(table).select('*').limit(1);
          tableResults[table] = true;
        } catch (e) {
          print('Error checking table $table: $e');
          tableResults[table] = false;
        }
      }

      setState(() {
        _tableStatus = tableResults;
        _status = 'Schema check complete';
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _status = 'Error checking schema: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Database Schema Test'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _checkTables,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _status,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  ...(_tableStatus.entries.map((entry) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(
                          entry.value ? Icons.check_circle : Icons.error,
                          color: entry.value ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          entry.key,
                          style: theme.textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ))),
                ],
              ),
            ),
    );
  }
}
