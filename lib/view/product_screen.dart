import 'package:flutter/material.dart';
import 'package:timbu/view/product_tile.dart';
import '../app_repository/app_repo.dart';
import '../models/products.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final TimbuApiService _apiService = TimbuApiService();
  List<Product> _products = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  int _currentPage = 1;
  final int _pageSize = 10;
  bool _hasMoreProducts = true;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      if (!_isLoadingMore && _hasMoreProducts) {
        _loadMoreProducts();
      }
    }
  }

  String _getImageUrl(String imageId) {
    return 'https://api.timbu.cloud/images/';
  }

  Future<void> _loadProducts() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final products = await _apiService.fetchProducts(page: _currentPage, size: _pageSize);
      print('Loaded ${products.length} products');
      if (products.isNotEmpty) {
        print('First product: ${products[0].name}, Image IDs: ${products[0].productImageIds}');
        if (products[0].productImageIds.isNotEmpty) {
          print('First image URL: ${_getImageUrl(products[0].productImageIds[0])}');
        }
      }
      setState(() {
        _products = products;
        _isLoading = false;
        _hasMoreProducts = products.length == _pageSize;
      });
    } catch (e) {
      print('Error fetching products: $e');
      setState(() {
        _error = 'Failed to load products: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreProducts() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final moreProducts = await _apiService.fetchProducts(page: _currentPage + 1, size: _pageSize);
      setState(() {
        _products.addAll(moreProducts);
        _currentPage++;
        _isLoadingMore = false;
        _hasMoreProducts = moreProducts.length == _pageSize;
      });
    } catch (e) {
      print('Error fetching more products: $e');
      setState(() {
        _error = 'Failed to load more products: $e';
        _isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timbu Products'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadProducts,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    } else if (_products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('No products found.', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadProducts,
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    } else {
      return RefreshIndicator(
        onRefresh: () async {
          _currentPage = 1;
          await _loadProducts();
        },
        child: ListView.builder(
          controller: _scrollController,
          itemCount: _products.length + (_isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index < _products.length) {
              final product = _products[index];
              final imageUrl = product.productImageIds.isNotEmpty
                  ? _getImageUrl(product.productImageIds[0])
                  : null;
              return ProductListItem(product: product, imageUrl: imageUrl);
            } else {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }
          },
        ),
      );
    }
  }
}