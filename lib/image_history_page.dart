import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'providers/image_history_provider.dart';

class ImageHistoryPage extends StatefulWidget {
  const ImageHistoryPage({super.key});

  @override
  State<ImageHistoryPage> createState() => _ImageHistoryPageState();
}

class _ImageHistoryPageState extends State<ImageHistoryPage> {
  String _selectedTab = 'All';
  bool _isGridView = true;
  List<ImageHistoryItem> _filteredImages = [];

  @override
  void initState() {
    super.initState();
    // Load image history when the page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateFilteredImages();
    });
  }

  void _updateFilteredImages() {
    final imageHistoryProvider = Provider.of<ImageHistoryProvider>(
      context,
      listen: false,
    );
    
    setState(() {
      switch (_selectedTab) {
        case 'Healthy':
          _filteredImages = imageHistoryProvider.healthyImages;
          break;
        case 'Disease Detected':
          _filteredImages = imageHistoryProvider.getImagesByStatus('Disease Detected');
          break;
        case 'Processing':
          _filteredImages = imageHistoryProvider.getImagesByStatus('Processing');
          break;
        default:
          _filteredImages = imageHistoryProvider.imageHistory;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, ImageHistoryProvider>(
      builder: (context, themeProvider, imageHistoryProvider, child) {
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
              'Image History',
              style: TextStyle(
                color: themeProvider.textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _isGridView ? Icons.list : Icons.grid_view,
                  color: themeProvider.textColor,
                ),
                onPressed: () => setState(() => _isGridView = !_isGridView),
              ),
              IconButton(
                icon: Icon(Icons.more_vert, color: themeProvider.textColor),
                onPressed: () => _showOptionsMenu(themeProvider),
              ),
            ],
          ),
          body: Column(
            children: [
              _buildTabBar(themeProvider),
              Expanded(
                child: _filteredImages.isEmpty
                    ? _buildEmptyState(themeProvider)
                    : _isGridView
                    ? _buildGridView(themeProvider)
                    : _buildListView(themeProvider),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabBar(ThemeProvider themeProvider) {
    final tabs = ['All', 'Healthy', 'Disease Detected'];

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: tabs.map((tab) {
          final isSelected = _selectedTab == tab;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedTab = tab);
                _updateFilteredImages();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.green
                      : themeProvider.backgroundColor,
                  border: Border.all(
                    color: isSelected
                        ? Colors.green
                        : themeProvider.borderColor,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  tab,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : themeProvider.textColor,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState(ThemeProvider themeProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 80,
            color: themeProvider.secondaryTextColor,
          ),
          const SizedBox(height: 20),
          Text(
            'No images found',
            style: TextStyle(
              color: themeProvider.textColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Take photos to analyze plant health',
            style: TextStyle(
              color: themeProvider.secondaryTextColor,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.camera_alt, color: Colors.white),
            label: const Text(
              'Take Photo',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView(ThemeProvider themeProvider) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: _filteredImages.length,
      itemBuilder: (context, index) {
        return _buildGridItem(_filteredImages[index], themeProvider);
      },
    );
  }

  Widget _buildListView(ThemeProvider themeProvider) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredImages.length,
      itemBuilder: (context, index) {
        return _buildListItem(_filteredImages[index], themeProvider);
      },
    );
  }

  Widget _buildGridItem(
    ImageHistoryItem item,
    ThemeProvider themeProvider,
  ) {
    return GestureDetector(
      onTap: () => _showImageDetail(item, themeProvider),
      child: Container(
        decoration: BoxDecoration(
          color: themeProvider.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: themeProvider.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: item.imageFile != null
                      ? Image.file(
                          item.imageFile!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.broken_image,
                              color: Colors.grey,
                              size: 32,
                            ),
                          ),
                        )
                      : Container(
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.image,
                            color: Colors.grey,
                            size: 32,
                          ),
                        ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${item.capturedAt.day}/${item.capturedAt.month}/${item.capturedAt.year}',
                      style: TextStyle(
                        color: themeProvider.textColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getStatusColor(item.status),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.status,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (item.confidence != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${item.confidence!.toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: themeProvider.secondaryTextColor,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListItem(
    ImageHistoryItem item,
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
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: item.imageFile != null
                  ? Image.file(
                      item.imageFile!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.broken_image,
                          color: Colors.grey,
                          size: 30,
                        ),
                      ),
                    )
                  : Container(
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.image,
                        color: Colors.grey,
                        size: 30,
                      ),
                    ),
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
                        item.disease ?? 'Healthy Plant',
                        style: TextStyle(
                          color: themeProvider.textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(item.status),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        item.status,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: themeProvider.secondaryTextColor,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${item.capturedAt.day}/${item.capturedAt.month}/${item.capturedAt.year} ${item.capturedAt.hour}:${item.capturedAt.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        color: themeProvider.secondaryTextColor,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                if (item.location != null) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: themeProvider.secondaryTextColor,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item.location!,
                          style: TextStyle(
                            color: themeProvider.secondaryTextColor,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
                Row(
                  children: [
                    if (item.confidence != null)
                      Text(
                        'Confidence: ${item.confidence!.toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => _showImageDetail(item, themeProvider),
                      icon: Icon(
                        Icons.visibility,
                        color: themeProvider.textColor,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'healthy':
        return Colors.green;
      case 'disease detected':
        return Colors.red;
      case 'processing':
        return Colors.orange;
      case 'analysis failed':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  void _showImageDetail(
    ImageHistoryItem item,
    ThemeProvider themeProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: themeProvider.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Image Detail',
                    style: TextStyle(
                      color: themeProvider.textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: themeProvider.textColor),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: item.imageFile != null
                      ? Image.file(
                          item.imageFile!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.broken_image,
                              color: Colors.grey,
                              size: 60,
                            ),
                          ),
                        )
                      : Container(
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.image,
                            color: Colors.grey,
                            size: 60,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              _buildDetailRow('Status', item.status, themeProvider),
              if (item.disease != null)
                _buildDetailRow('Disease', item.disease!, themeProvider),
              if (item.confidence != null)
                _buildDetailRow(
                  'Confidence',
                  '${item.confidence!.toStringAsFixed(1)}%',
                  themeProvider,
                ),
              _buildDetailRow(
                'Date',
                '${item.capturedAt.day}/${item.capturedAt.month}/${item.capturedAt.year}',
                themeProvider,
              ),
              _buildDetailRow(
                'Time',
                '${item.capturedAt.hour}:${item.capturedAt.minute.toString().padLeft(2, '0')}',
                themeProvider,
              ),
              if (item.location != null)
                _buildDetailRow('Location', item.location!, themeProvider),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _shareImage(item);
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.green),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Share',
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _deleteImage(item, themeProvider);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    ThemeProvider themeProvider,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                color: themeProvider.secondaryTextColor,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: themeProvider.textColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showOptionsMenu(ThemeProvider themeProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: themeProvider.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Options',
              style: TextStyle(
                color: themeProvider.textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.download, color: Colors.blue),
              title: Text(
                'Export All',
                style: TextStyle(color: themeProvider.textColor),
              ),
              onTap: () {
                Navigator.pop(context);
                _exportImages();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_sweep, color: Colors.red),
              title: Text(
                'Clear All',
                style: TextStyle(color: themeProvider.textColor),
              ),
              onTap: () {
                Navigator.pop(context);
                _clearAllImages(themeProvider);
              },
            ),
            ListTile(
              leading: const Icon(Icons.filter_list, color: Colors.orange),
              title: Text(
                'Filter Options',
                style: TextStyle(color: themeProvider.textColor),
              ),
              onTap: () {
                Navigator.pop(context);
                _showFilterOptions(themeProvider);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _shareImage(ImageHistoryItem item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing image: ${item.disease ?? 'Healthy Plant'}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _deleteImage(ImageHistoryItem item, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: themeProvider.cardColor,
        title: Text(
          'Delete Image',
          style: TextStyle(color: themeProvider.textColor),
        ),
        content: Text(
          'Are you sure you want to delete this image?',
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
              final imageHistoryProvider = Provider.of<ImageHistoryProvider>(
                context,
                listen: false,
              );
              imageHistoryProvider.deleteImage(item.id);
              Navigator.pop(context);
              _updateFilteredImages(); // Refresh the list
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Image deleted successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _exportImages() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exporting images...'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _clearAllImages(ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: themeProvider.cardColor,
        title: Text(
          'Clear All Images',
          style: TextStyle(color: themeProvider.textColor),
        ),
        content: Text(
          'Are you sure you want to delete all images? This action cannot be undone.',
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
              final imageHistoryProvider = Provider.of<ImageHistoryProvider>(
                context,
                listen: false,
              );
              imageHistoryProvider.clearHistory();
              Navigator.pop(context);
              _updateFilteredImages(); // Refresh the list
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All images cleared successfully'),
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

  void _showFilterOptions(ThemeProvider themeProvider) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Filter options would open here'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
