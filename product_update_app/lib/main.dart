import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

// ---------------- Firestore service ----------------
class ProductService {
  static final CollectionReference<Map<String, dynamic>> _products =
    FirebaseFirestore.instance.collection('products');

  // READ: find a product document by its name
  static Future<QueryDocumentSnapshot<Map<String, dynamic>>?> findByName(
    String name) async {
    final snap =
      await _products.where('name', isEqualTo: name).limit(1).get();
    return snap.docs.isEmpty ? null : snap.docs.first;
  }

  // READ: fetch a document again by its id
  static Future<DocumentSnapshot<Map<String, dynamic>>> getById(String id) {
    return _products.doc(id).get();
  }

  // UPDATE: change quantity and price of an existing document
  static Future<void> updateProduct(String id, int quantity, double price) {
    return _products.doc(id).update({'quantity': quantity, 'price': price});
  }
}

// ---------------- UI ----------------
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProductApp());
}

class ProductApp extends StatelessWidget {
  const ProductApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Update Product Details',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const ProductPage(),
    );
  }
}

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final _nameCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();

  String? _docId;                    // id of the product found by Search
  Map<String, dynamic>? _product;    // data of the product being shown
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _qtyCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  void _msg(String text) {
    ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(text)));
  }

  // Show a document's data and fill the edit fields with its values
  void _show(String id, Map<String, dynamic> data) {
    _docId = id;
    _product = data;
    _qtyCtrl.text = '${(data['quantity'] as num).toInt()}';
    _priceCtrl.text = '${(data['price'] as num).toDouble()}';
  }

  Future<void> _search() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      _msg('Enter a product name');
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    try {
      final doc = await ProductService.findByName(name);
      if (!mounted) return;
      if (doc == null) {
        setState(() {
            _docId = null;
            _product = null;
            _qtyCtrl.clear();
            _priceCtrl.clear();
          });
        _msg('Product not found');
      } else {
        setState(() => _show(doc.id, doc.data()));
      }
    } catch (e) {
      if (mounted) _msg('Error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _update() async {
    if (_docId == null) {
      _msg('Search for a product first');
      return;
    }
    final qty = int.tryParse(_qtyCtrl.text.trim());
    final price = double.tryParse(_priceCtrl.text.trim());
    if (qty == null || qty < 0 || price == null || price < 0) {
      _msg('Enter a valid quantity and price');
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    try {
      await ProductService.updateProduct(_docId!, qty, price);
      final fresh = await ProductService.getById(_docId!);   // re-read
      if (!mounted) return;
      setState(() => _show(fresh.id, fresh.data()!));
      _msg('Product updated successfully');
    } catch (e) {
      if (mounted) _msg('Error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _field(TextEditingController ctrl, String label,
    {TextInputType type = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16)),
          Text(value,
            style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Product Details'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _field(_nameCtrl, 'Product Name'),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton.icon(
                        onPressed: _loading ? null : _search,
                        icon: const Icon(Icons.search),
                        label: const Text('SEARCH'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _field(_qtyCtrl, 'New Quantity',
                      type: TextInputType.number),
                    _field(_priceCtrl, 'New Price',
                      type: const TextInputType.numberWithOptions(
                        decimal: true)),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton.icon(
                        onPressed: _loading ? null : _update,
                        icon: const Icon(Icons.save),
                        label: const Text('UPDATE'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_loading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
            if (_product != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Product Details',
                      style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                    const Divider(),
                    _detailRow('Name', '${_product!['name']}'),
                    _detailRow('Quantity',
                      '${(_product!['quantity'] as num).toInt()}'),
                    _detailRow('Price',
                      'Rs. ${(_product!['price'] as num).toDouble()}'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
