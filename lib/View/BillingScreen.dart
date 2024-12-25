import 'dart:io';
import 'package:billing_app/Model/product.model.dart';
import 'package:billing_app/Provider/cart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class BillingScreen extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var cart = Provider.of<Cart>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Billing System'),
        centerTitle: true,
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            onPressed: () => _generateBill(cart), // Generate bill action
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Product',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            _buildTextField(nameController, 'Product Name'),
            _buildTextField(priceController, 'Price', isNumber: true),
            _buildTextField(quantityController, 'Quantity', isNumber: true),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                if (nameController.text.isNotEmpty &&
                    priceController.text.isNotEmpty &&
                    quantityController.text.isNotEmpty) {
                  final product = Product(
                    name: nameController.text,
                    price: double.parse(priceController.text),
                    quantity: int.parse(quantityController.text),
                  );
                  cart.addItem(product);
                  nameController.clear();
                  priceController.clear();
                  quantityController.clear();
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(10),
                ),
                width: double.infinity,
                alignment: Alignment.center,
                child: Text(
                  'Add Item',
                  style:
                      TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: cart.items.length,
                itemBuilder: (context, index) {
                  final item = cart.items[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title:
                          Text(item.name, style: TextStyle(fontSize: 18)),
                      subtitle:
                          Text('Price: \$${item.price} x ${item.quantity}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon:
                                Icon(Icons.edit, color: Colors.blue),
                            onPressed:
                                () => _editItem(context, index, item),
                          ),
                          IconButton(
                            icon:
                                Icon(Icons.delete, color: Colors.redAccent),
                            onPressed:
                                () => cart.removeItem(index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Divider(),
            _buildTotalSummary(cart),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool isNumber = false}) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(vertical:
          8.0),
      child:
          TextField(controller:
          controller,
            decoration:
            InputDecoration(labelText:
            label, border:
            OutlineInputBorder()),
            keyboardType:
            isNumber ? TextInputType.number : TextInputType.text,
          ),
    );
  }

  Widget _buildTotalSummary(Cart cart) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children:[
        Text('Total Amount',
            style:
            TextStyle(fontSize:
            22, fontWeight:
            FontWeight.bold)),
        SizedBox(height:
        10),
        Text('Total Price:\t\t\$${cart.total.toStringAsFixed(2)}'),
        Text('Discount:\t\t\$${cart.discount.toStringAsFixed(2)}'),
        Text('Tax:\t\t\$${cart.tax.toStringAsFixed(2)}'),
        Divider(),
        Text('Final Total:\t\t\$${cart.finalTotal.toStringAsFixed(2)}',
            style:
            TextStyle(fontSize:
            18, fontWeight:
            FontWeight.bold)),
      ],
    );
  }

  void _editItem(BuildContext context, int index, Product item) {
    final cart = Provider.of<Cart>(context, listen:false);

    final nameController =
    TextEditingController(text:item.name);
    final priceController =
    TextEditingController(text:item.price.toString());
    final quantityController =
    TextEditingController(text:item.quantity.toString());

    showDialog(
      context : context,
      builder : (context) {
        return AlertDialog(
          title :Text('Edit Item', style :
          TextStyle(fontWeight :
          FontWeight.bold)),
          content :Column(mainAxisSize :
          MainAxisSize.min,
            children:[
              _buildTextField(nameController,'Product Name'),
              _buildTextField(priceController,'Price',isNumber:true),
              _buildTextField(quantityController,'Quantity',isNumber:true)
            ],
          ),
          actions:[
            ElevatedButton(
              onPressed : () {
                final updatedProduct =
                Product(name:nameController.text,
                    price : double.parse(priceController.text), 
                    quantity : int.parse(quantityController.text));
                cart.updateItem(index, updatedProduct);
                Navigator.of(context).pop();
              },
              child :Text('Update'),
            )
          ],
        );
      },
    );
  }

  void _generateBill(Cart cart) async {
    final pdf = pw.Document();
    
    // Load custom font
    // final ByteData fontData = await rootBundle.load('Download/bill.ttf');
    // final ttf = pw.Font.ttf(fontData.buffer.asByteData());

    // Load logo image
    // final image = pw.MemoryImage((await rootBundle.load('assets/images/logo_text.png')).buffer.asUint8List());

    try {
      pdf.addPage(pw.Page(build:(pw.Context context) {
        return pw.Column(children:[
          // pw.Image(image, width: 120, fit: pw.BoxFit.contain),
          pw.SizedBox(height: 20),
          pw.Text('Supermarket Billing', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 20),
          
          // Table of items
          pw.Table.fromTextArray(context : context,data :<List<String>>[
            <String>['Product Name', 'Price', 'Quantity', 'Total'],
            ...cart.items.map((item) =>
                [item.name, '\$${item.price}', '${item.quantity}', '\$${item.price * item.quantity}']).toList(),
          ]),
          
          pw.SizedBox(height :20),
          pw.Text('Total Price:\t\t\$${cart.total.toStringAsFixed(2)}'),
          pw.Text('Discount:\t\t\$${cart.discount.toStringAsFixed(2)}'),
          pw.Text('Tax:\t\t\$${cart.tax.toStringAsFixed(2)}'),
          pw.Divider(),
          pw.Text('Final Total:\t\t\$${cart.finalTotal.toStringAsFixed(2)}',
              style :pw.TextStyle(fontSize :
              18,fontWeight :
              pw.FontWeight.bold)),
        ]);
      }));

      // Get the directory to save the PDF
      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = await getDownloadsDirectory();
      }

      if (directory == null) {
        // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Document directory not available")));
        return;
      }
      
      String path = directory.path;
      String myFile = '${path}/Supermarket_Bill.pdf';
      
      // Save the PDF file
      final file = File(myFile);
      await file.writeAsBytes(await pdf.save());
      
      // Open the PDF file
      OpenFile.open(myFile);
      
    } catch (e) {
      debugPrint("$e");
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error generating bill")));
    }
  }
}
