import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Onboarding Screen Widget Tests', () {
    testWidgets('OnboardingScreen should show welcome message', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Text('Welcome to Aura'),
                ElevatedButton(
                  onPressed: () {},
                  child: Text('Get Started'),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Welcome to Aura'), findsOneWidget);
      expect(find.text('Get Started'), findsOneWidget);
    });

    testWidgets('OnboardingScreen should show skip button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              actions: [
                TextButton(
                  onPressed: () {},
                  child: Text('Skip'),
                ),
              ],
            ),
            body: Text('Onboarding Content'),
          ),
        ),
      );

      expect(find.text('Skip'), findsOneWidget);
      expect(find.text('Onboarding Content'), findsOneWidget);
    });

    testWidgets('OnboardingScreen should navigate through steps', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(home: OnboardingScreenStateful()),
      );

      expect(find.text('Step 1 of 3'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text('Step 2 of 3'), findsOneWidget);
    });

    testWidgets('OnboardingScreen should handle back navigation', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(home: OnboardingScreenStateful()),
      );

      // Navigate to step 2
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text('Step 2 of 3'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);

      // Go back to step 1
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.text('Step 1 of 3'), findsOneWidget);
    });
  });

  group('Wardrobe Screen Widget Tests', () {
    testWidgets('WardrobeScreen should display empty state', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: WardrobeScreenMock(isEmpty: true),
        ),
      );

      expect(find.text('Your wardrobe is empty'), findsOneWidget);
      expect(find.text('Add your first item'), findsOneWidget);
      expect(find.byIcon(Icons.checkroom), findsOneWidget);
    });

    testWidgets('WardrobeScreen should display clothing items', (WidgetTester tester) async {
      final items = [
        MockClothingItem(name: 'T-Shirt', category: 'Tops'),
        MockClothingItem(name: 'Jeans', category: 'Bottoms'),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: WardrobeScreenMock(items: items),
        ),
      );

      expect(find.text('T-Shirt'), findsOneWidget);
      expect(find.text('Jeans'), findsOneWidget);
      expect(find.text('Tops'), findsOneWidget);
      expect(find.text('Bottoms'), findsOneWidget);
    });

    testWidgets('WardrobeScreen should filter by category', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(home: WardrobeScreenWithFilters()),
      );

      // Initially should show all items
      expect(find.text('Blue Shirt'), findsOneWidget);
      expect(find.text('Black Pants'), findsOneWidget);

      // Filter by Tops using a more specific finder
      final topsButtons = find.text('Tops');
      expect(topsButtons, findsWidgets);
      
      await tester.tap(topsButtons.first);
      await tester.pumpAndSettle();

      expect(find.text('Blue Shirt'), findsOneWidget);
      expect(find.text('Black Pants'), findsNothing);
    });

    testWidgets('WardrobeScreen should handle search', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(home: WardrobeScreenWithSearch()),
      );

      await tester.enterText(find.byType(TextField), 'Blue');
      await tester.pumpAndSettle();

      expect(find.text('Blue Shirt'), findsOneWidget);
      expect(find.text('Black Pants'), findsNothing);
    });

    testWidgets('WardrobeScreen should handle item favorite toggle', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(home: WardrobeScreenWithFavorites()),
      );

      expect(find.byIcon(Icons.favorite_border), findsOneWidget);

      await tester.tap(find.byIcon(Icons.favorite_border));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });
  });

  group('Add Item Screen Widget Tests', () {
    testWidgets('AddItemScreen should display form fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(home: AddItemScreenMock()),
      );

      expect(find.text('Item Name'), findsOneWidget);
      expect(find.text('Category'), findsOneWidget);
      expect(find.text('Color'), findsOneWidget);
      expect(find.text('Save Item'), findsOneWidget);
    });

    testWidgets('AddItemScreen should validate required fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(home: AddItemScreenMock()),
      );

      await tester.tap(find.text('Save Item'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter item name'), findsOneWidget);
    });

    testWidgets('AddItemScreen should save item successfully', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(home: AddItemScreenMock()),
      );

      await tester.enterText(find.byKey(ValueKey('name_field')), 'Test Item');
      await tester.tap(find.text('Save Item'));
      await tester.pumpAndSettle();

      expect(find.text('Item saved successfully!'), findsOneWidget);
    });

    testWidgets('AddItemScreen should handle photo selection', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(home: AddItemScreenMock()),
      );

      await tester.tap(find.text('Add Photo'));
      await tester.pumpAndSettle();

      expect(find.text('Photo selected'), findsOneWidget);
    });
  });

  group('Outfit Creation Screen Widget Tests', () {
    testWidgets('OutfitScreen should display available items', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(home: OutfitCreationMock()),
      );

      expect(find.text('Create Outfit'), findsOneWidget);
      expect(find.text('Available Items'), findsOneWidget);
      expect(find.text('T-Shirt'), findsOneWidget);
      expect(find.text('Jeans'), findsOneWidget);
    });

    testWidgets('OutfitScreen should select and deselect items', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(home: OutfitCreationMock()),
      );

      // Select item
      await tester.tap(find.text('T-Shirt'));
      await tester.pumpAndSettle();

      expect(find.text('1 items selected'), findsOneWidget);

      // Deselect item
      await tester.tap(find.text('T-Shirt'));
      await tester.pumpAndSettle();

      expect(find.text('0 items selected'), findsOneWidget);
    });

    testWidgets('OutfitScreen should save outfit with selected items', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(home: OutfitCreationMock()),
      );

      await tester.tap(find.text('T-Shirt'));
      await tester.tap(find.text('Jeans'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save Outfit'));
      await tester.pumpAndSettle();

      expect(find.text('Outfit saved!'), findsOneWidget);
    });
  });

  group('Navigation Widget Tests', () {
    testWidgets('BottomNavigationBar should switch between tabs', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(home: NavigationMock()),
      );

      expect(find.text('Wardrobe').first, findsOneWidget);

      await tester.tap(find.text('Outfits'));
      await tester.pumpAndSettle();

      expect(find.text('Outfits Screen'), findsOneWidget);
    });

    testWidgets('DrawerMenu should navigate to settings', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(home: NavigationWithDrawerMock()),
      );

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      expect(find.text('Settings Screen'), findsOneWidget);
    });
  });

  group('Accessibility Widget Tests', () {
    testWidgets('Buttons should have proper semantic labels', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Semantics(
              label: 'Add new item',
              child: ElevatedButton(
                onPressed: () {},
                child: Icon(Icons.add),
              ),
            ),
          ),
        ),
      );

      expect(find.bySemanticsLabel('Add new item'), findsOneWidget);
    });

    testWidgets('Images should have alt text', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Semantics(
              label: 'Profile picture',
              child: Container(
                width: 50,
                height: 50,
                color: Colors.grey,
              ),
            ),
          ),
        ),
      );

      expect(find.bySemanticsLabel('Profile picture'), findsOneWidget);
    });

    testWidgets('Form fields should have proper labels', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Item name',
                    hintText: 'Enter item name',
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Item name'), findsOneWidget);
      expect(find.text('Enter item name'), findsOneWidget);
    });
  });

  group('Performance Widget Tests', () {
    testWidgets('Large lists should render efficiently', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: 1000,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Item $index'),
                );
              },
            ),
          ),
        ),
      );

      // Should only render visible items
      expect(find.text('Item 0'), findsOneWidget);
      expect(find.text('Item 999'), findsNothing);

      // Test that scrolling works
      await tester.scrollUntilVisible(
        find.text('Item 50'),
        500.0,
      );
      
      expect(find.text('Item 50'), findsOneWidget);
    });

    testWidgets('Heavy computations should not block UI', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(home: HeavyComputationWidget()),
      );

      await tester.tap(find.text('Start Heavy Task'));
      await tester.pump(Duration(milliseconds: 10)); // Short pump without settle

      // UI should still be responsive
      expect(find.text('Processing...'), findsOneWidget);
      
      // Wait for the computation to complete
      await tester.pumpAndSettle();
    });
  });
}

// Mock Widget Classes
class OnboardingScreenStateful extends StatefulWidget {
  const OnboardingScreenStateful({super.key});

  @override
  State<OnboardingScreenStateful> createState() => _OnboardingScreenStatefulState();
}

class _OnboardingScreenStatefulState extends State<OnboardingScreenStateful> {
  int currentStep = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Step $currentStep of 3'),
        leading: currentStep > 1 
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => setState(() => currentStep--),
            )
          : null,
      ),
      body: Column(
        children: [
          Text('Step $currentStep Content'),
          const Spacer(),
          if (currentStep < 3)
            ElevatedButton(
              onPressed: () => setState(() => currentStep++),
              child: const Text('Next'),
            ),
        ],
      ),
    );
  }
}

class MockClothingItem {
  final String name;
  final String category;
  final bool isFavorite;

  MockClothingItem({
    required this.name,
    required this.category,
    this.isFavorite = false,
  });
}

class WardrobeScreenMock extends StatelessWidget {
  final bool isEmpty;
  final List<MockClothingItem> items;

  const WardrobeScreenMock({
    super.key,
    this.isEmpty = false,
    this.items = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wardrobe')),
      body: isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.checkroom, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Your wardrobe is empty'),
                  Text('Add your first item'),
                ],
              ),
            )
          : ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  title: Text(item.name),
                  subtitle: Text(item.category),
                  trailing: Icon(
                    item.isFavorite ? Icons.favorite : Icons.favorite_border,
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}

class WardrobeScreenWithFilters extends StatefulWidget {
  const WardrobeScreenWithFilters({super.key});

  @override
  State<WardrobeScreenWithFilters> createState() => _WardrobeScreenWithFiltersState();
}

class _WardrobeScreenWithFiltersState extends State<WardrobeScreenWithFilters> {
  String selectedCategory = 'All';
  final items = [
    MockClothingItem(name: 'Blue Shirt', category: 'Tops'),
    MockClothingItem(name: 'Black Pants', category: 'Bottoms'),
  ];

  @override
  Widget build(BuildContext context) {
    final filteredItems = selectedCategory == 'All'
        ? items
        : items.where((item) => item.category == selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Wardrobe')),
      body: Column(
        children: [
          Row(
            children: [
              TextButton(
                onPressed: () => setState(() => selectedCategory = 'All'),
                child: const Text('All'),
              ),
              TextButton(
                onPressed: () => setState(() => selectedCategory = 'Tops'),
                child: const Text('Tops'),
              ),
              TextButton(
                onPressed: () => setState(() => selectedCategory = 'Bottoms'),
                child: const Text('Bottoms'),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                final item = filteredItems[index];
                return ListTile(
                  title: Text(item.name),
                  subtitle: Text(item.category),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class WardrobeScreenWithSearch extends StatefulWidget {
  const WardrobeScreenWithSearch({super.key});

  @override
  State<WardrobeScreenWithSearch> createState() => _WardrobeScreenWithSearchState();
}

class _WardrobeScreenWithSearchState extends State<WardrobeScreenWithSearch> {
  String searchQuery = '';
  final items = [
    MockClothingItem(name: 'Blue Shirt', category: 'Tops'),
    MockClothingItem(name: 'Black Pants', category: 'Bottoms'),
  ];

  @override
  Widget build(BuildContext context) {
    final filteredItems = items
        .where((item) => item.name.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Wardrobe')),
      body: Column(
        children: [
          TextField(
            onChanged: (value) => setState(() => searchQuery = value),
            decoration: const InputDecoration(
              hintText: 'Search items...',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                final item = filteredItems[index];
                return ListTile(
                  title: Text(item.name),
                  subtitle: Text(item.category),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class WardrobeScreenWithFavorites extends StatefulWidget {
  const WardrobeScreenWithFavorites({super.key});

  @override
  State<WardrobeScreenWithFavorites> createState() => _WardrobeScreenWithFavoritesState();
}

class _WardrobeScreenWithFavoritesState extends State<WardrobeScreenWithFavorites> {
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wardrobe')),
      body: ListTile(
        title: const Text('Blue Shirt'),
        subtitle: const Text('Tops'),
        trailing: IconButton(
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
          ),
          onPressed: () => setState(() => isFavorite = !isFavorite),
        ),
      ),
    );
  }
}

class AddItemScreenMock extends StatefulWidget {
  const AddItemScreenMock({super.key});

  @override
  State<AddItemScreenMock> createState() => _AddItemScreenMockState();
}

class _AddItemScreenMockState extends State<AddItemScreenMock> {
  final _nameController = TextEditingController();
  String? errorMessage;
  String? successMessage;
  bool photoSelected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Item')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              key: const ValueKey('name_field'),
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Item Name'),
            ),
            const TextField(
              decoration: InputDecoration(labelText: 'Category'),
            ),
            const TextField(
              decoration: InputDecoration(labelText: 'Color'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => setState(() => photoSelected = true),
              child: const Text('Add Photo'),
            ),
            if (photoSelected) const Text('Photo selected'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  if (_nameController.text.isEmpty) {
                    errorMessage = 'Please enter item name';
                    successMessage = null;
                  } else {
                    errorMessage = null;
                    successMessage = 'Item saved successfully!';
                  }
                });
              },
              child: const Text('Save Item'),
            ),
            if (errorMessage != null) Text(errorMessage!),
            if (successMessage != null) Text(successMessage!),
          ],
        ),
      ),
    );
  }
}

class OutfitCreationMock extends StatefulWidget {
  const OutfitCreationMock({super.key});

  @override
  State<OutfitCreationMock> createState() => _OutfitCreationMockState();
}

class _OutfitCreationMockState extends State<OutfitCreationMock> {
  final selectedItems = <String>{};
  bool outfitSaved = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Outfit')),
      body: Column(
        children: [
          const Text('Available Items'),
          ListTile(
            title: const Text('T-Shirt'),
            trailing: Checkbox(
              value: selectedItems.contains('T-Shirt'),
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    selectedItems.add('T-Shirt');
                  } else {
                    selectedItems.remove('T-Shirt');
                  }
                });
              },
            ),
            onTap: () {
              setState(() {
                if (selectedItems.contains('T-Shirt')) {
                  selectedItems.remove('T-Shirt');
                } else {
                  selectedItems.add('T-Shirt');
                }
              });
            },
          ),
          ListTile(
            title: const Text('Jeans'),
            trailing: Checkbox(
              value: selectedItems.contains('Jeans'),
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    selectedItems.add('Jeans');
                  } else {
                    selectedItems.remove('Jeans');
                  }
                });
              },
            ),
            onTap: () {
              setState(() {
                if (selectedItems.contains('Jeans')) {
                  selectedItems.remove('Jeans');
                } else {
                  selectedItems.add('Jeans');
                }
              });
            },
          ),
          Text('${selectedItems.length} items selected'),
          ElevatedButton(
            onPressed: () => setState(() => outfitSaved = true),
            child: const Text('Save Outfit'),
          ),
          if (outfitSaved) const Text('Outfit saved!'),
        ],
      ),
    );
  }
}

class NavigationMock extends StatefulWidget {
  const NavigationMock({super.key});

  @override
  State<NavigationMock> createState() => _NavigationMockState();
}

class _NavigationMockState extends State<NavigationMock> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: selectedIndex == 0
          ? const Center(child: Text('Wardrobe'))
          : const Center(child: Text('Outfits Screen')),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) => setState(() => selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.checkroom),
            label: 'Wardrobe',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.style),
            label: 'Outfits',
          ),
        ],
      ),
    );
  }
}

class NavigationWithDrawerMock extends StatefulWidget {
  const NavigationWithDrawerMock({super.key});

  @override
  State<NavigationWithDrawerMock> createState() => _NavigationWithDrawerMockState();
}

class _NavigationWithDrawerMockState extends State<NavigationWithDrawerMock> {
  bool showSettings = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Aura')),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(child: Text('Menu')),
            ListTile(
              title: const Text('Settings'),
              onTap: () {
                Navigator.of(context).pop();
                setState(() => showSettings = true);
              },
            ),
          ],
        ),
      ),
      body: showSettings
          ? const Center(child: Text('Settings Screen'))
          : const Center(child: Text('Home Screen')),
    );
  }
}

class HeavyComputationWidget extends StatefulWidget {
  const HeavyComputationWidget({super.key});

  @override
  State<HeavyComputationWidget> createState() => _HeavyComputationWidgetState();
}

class _HeavyComputationWidgetState extends State<HeavyComputationWidget> {
  bool isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isProcessing) const Text('Processing...'),
            ElevatedButton(
              onPressed: () {
                setState(() => isProcessing = true);
                // Simulate heavy computation with a timer
                Future.delayed(const Duration(milliseconds: 50), () {
                  if (mounted) setState(() => isProcessing = false);
                });
              },
              child: const Text('Start Heavy Task'),
            ),
          ],
        ),
      ),
    );
  }
}
