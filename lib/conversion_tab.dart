
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ConversionTab extends StatefulWidget {
  @override
  _ConversionTabState createState() => _ConversionTabState();
}

class _ConversionTabState extends State<ConversionTab> {
  TextEditingController meterController = TextEditingController();
  double meterValue = 0.0;
  Map<String, double> conversionUnits = {};

  @override
  void initState() {
    super.initState();
    _loadConversionUnits();
  }

  Future<void> _loadConversionUnits() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? unitsJson = prefs.getString('conversionUnits');
    if (unitsJson != null) {
      setState(() {
        conversionUnits = Map<String, double>.from(json.decode(unitsJson));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Conversion de Mesures'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: meterController,
              decoration: InputDecoration(labelText: 'Entrez la mesure en mètres'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  meterValue = double.tryParse(value) ?? 0.0;
                });
              },
            ),
            SizedBox(height: 20),
            Text(
              'Conversions :',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: conversionUnits.keys.length,
                itemBuilder: (context, index) {
                  String unitName = conversionUnits.keys.elementAt(index);
                  double conversionFactor = conversionUnits[unitName]!;
                  double convertedValue = meterValue * conversionFactor;
                  return ListTile(
                    title: Text('$unitName: $convertedValue'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

