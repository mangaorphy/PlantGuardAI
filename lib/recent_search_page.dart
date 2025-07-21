import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';

class RecentSearchPage extends StatefulWidget {
  const RecentSearchPage({super.key});

  @override
  State<RecentSearchPage> createState() => _RecentSearchPageState();
}

class _RecentSearchPageState extends State<RecentSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';

  final List<Map<String, dynamic>> _recentSearches = [
    {
      'id': '1',
      'query': 'bacterial leaf spot',
      'category': 'Disease',
      'date': '2024-01-15',
      'time': '14:30',
      'results': 12,
      'isPopular': true,
    },
    {
      'id': '2',
      'query': 'organic pesticide',
      'category': 'Product',
      'date': '2024-01-14',
      'time': '10:15',
      'results': 8,
      'isPopular': false,
    },
    {
      'id': '3',
      'query': 'powdery mildew treatment',
      'category': 'Disease',
      'date': '2024-01-13',
      'time': '16:45',
      'results': 15,
      'isPopular': true,
    },
    {
      'id': '4',
      'query': 'bio fertilizer',
      'category': 'Product',
      'date': '2024-01-12',
      'time': '09:20',
      'results': 24,
      'isPopular': false,
    },
    {
      'id': '5',
      'query': 'plant nutrient deficiency',
      'category': 'Disease',
      'date': '2024-01-11',
      'time': '13:10',
      'results': 6,
      'isPopular': true,
    },
  ];

  final List<String> _popularSearches = [
    'bacterial leaf spot',
    'organic fertilizer',
    'fungal disease',
    'pest control',
    'plant nutrition',
    'crop protection',
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: themeProvider.backgroundColor,
          appBar: AppBar(
            backgroundColor: themeProvider.backgroundColor,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: themeProvider.textColor),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Recent Searches',
              style: TextStyle(
                color: themeProvider.textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.clear_all, color: themeProvider.textColor),
                onPressed: () => _clearAllSearches(themeProvider),
              ),
            ],
          ),
          body: Column(
            children: [
              _buildSearchBar(themeProvider),
              _buildCategoryFilter(themeProvider),
              Expanded(
                child:
                    _filteredSearches.isEmpty
                        ? _buildEmptyState(themeProvider)
                        : _buildSearchList(themeProvider),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Map<String, dynamic>> get _filteredSearches {
    if (_selectedCategory == 'All') return _recentSearches;
    return _recentSearches
        .where((search) => search['category'] == _selectedCategory)
        .toList();
  }

  Widget _buildSearchBar(ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        style: TextStyle(color: themeProvider.textColor),
        decoration: InputDecoration(
          hintText: 'Search diseases, products, treatments...',
          hintStyle: TextStyle(color: themeProvider.secondaryTextColor),
          prefixIcon: Icon(
            Icons.search,
            color: themeProvider.secondaryTextColor,
          ),
          suffixIcon:
              _searchController.text.isNotEmpty
                  ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: themeProvider.secondaryTextColor,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                  )
                  : null,
          filled: true,
          fillColor: themeProvider.cardColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: themeProvider.borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.green),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: themeProvider.borderColor),
          ),
        ),
        onChanged: (value) => setState(() {}),
        onSubmitted: _performSearch,
      ),
    );
  }

  Widget _buildCategoryFilter(ThemeProvider themeProvider) {
    final categories = ['All', 'Disease', 'Product', 'Treatment'];

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _selectedCategory == category;

          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category;
                });
              },
              backgroundColor: themeProvider.cardColor,
              selectedColor: Colors.green,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : themeProvider.textColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected ? Colors.green : themeProvider.borderColor,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(ThemeProvider themeProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: themeProvider.secondaryTextColor,
          ),
          const SizedBox(height: 20),
          Text(
            'No search history',
            style: TextStyle(
              color: themeProvider.textColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start searching to see your history here',
            style: TextStyle(
              color: themeProvider.secondaryTextColor,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 30),
          _buildPopularSearches(themeProvider),
        ],
      ),
    );
  }

  Widget _buildPopularSearches(ThemeProvider themeProvider) {
    return Column(
      children: [
        Text(
          'Popular Searches',
          style: TextStyle(
            color: themeProvider.textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              _popularSearches.map((search) {
                return GestureDetector(
                  onTap: () => _performSearch(search),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: themeProvider.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: themeProvider.borderColor),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.trending_up, color: Colors.green, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          search,
                          style: TextStyle(
                            color: themeProvider.textColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildSearchList(ThemeProvider themeProvider) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredSearches.length,
      itemBuilder: (context, index) {
        return _buildSearchItem(_filteredSearches[index], themeProvider);
      },
    );
  }

  Widget _buildSearchItem(
    Map<String, dynamic> search,
    ThemeProvider themeProvider,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeProvider.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: themeProvider.borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getCategoryColor(search['category']).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getCategoryIcon(search['category']),
              color: _getCategoryColor(search['category']),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        search['query'],
                        style: TextStyle(
                          color: themeProvider.textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (search['isPopular'])
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Popular',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(search['category']),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        search['category'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${search['results']} results',
                      style: TextStyle(
                        color: themeProvider.secondaryTextColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: themeProvider.secondaryTextColor,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${search['date']} ${search['time']}',
                      style: TextStyle(
                        color: themeProvider.secondaryTextColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                onPressed: () => _performSearch(search['query']),
                icon: Icon(Icons.search, color: Colors.green, size: 20),
              ),
              IconButton(
                onPressed: () => _removeSearch(search, themeProvider),
                icon: Icon(
                  Icons.close,
                  color: themeProvider.secondaryTextColor,
                  size: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Disease':
        return Colors.red;
      case 'Product':
        return Colors.blue;
      case 'Treatment':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Disease':
        return Icons.bug_report;
      case 'Product':
        return Icons.shopping_bag;
      case 'Treatment':
        return Icons.healing;
      default:
        return Icons.search;
    }
  }

  void _performSearch(String query) {
    // Add to recent searches if not already there
    final existingIndex = _recentSearches.indexWhere(
      (search) => search['query'] == query,
    );
    if (existingIndex == -1) {
      setState(() {
        _recentSearches.insert(0, {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'query': query,
          'category': 'Search',
          'date': '2024-01-15',
          'time': '${DateTime.now().hour}:${DateTime.now().minute}',
          'results': (query.length * 2) + 5, // Mock result count
          'isPopular': false,
        });
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Searching for "$query"...'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _removeSearch(Map<String, dynamic> search, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: themeProvider.cardColor,
            title: Text(
              'Remove Search',
              style: TextStyle(color: themeProvider.textColor),
            ),
            content: Text(
              'Remove "${search['query']}" from search history?',
              style: TextStyle(color: themeProvider.secondaryTextColor),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: themeProvider.secondaryTextColor),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _recentSearches.removeWhere(
                      (item) => item['id'] == search['id'],
                    );
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Search removed successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text(
                  'Remove',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  void _clearAllSearches(ThemeProvider themeProvider) {
    if (_recentSearches.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No searches to clear'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: themeProvider.cardColor,
            title: Text(
              'Clear All Searches',
              style: TextStyle(color: themeProvider.textColor),
            ),
            content: Text(
              'Are you sure you want to clear all search history?',
              style: TextStyle(color: themeProvider.secondaryTextColor),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: themeProvider.secondaryTextColor),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _recentSearches.clear();
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('All searches cleared successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text(
                  'Clear All',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
