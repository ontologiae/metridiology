
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ConversionTab extends StatefulWidget {
  @override
  ConversionTabState createState() => ConversionTabState();
}

class ConversionTabState extends State<ConversionTab>/* with AutomaticKeepAliveClientMixin */{
  TextEditingController meterController = TextEditingController();
  double meterValue = 1.0;
  Map<String, double> conversionUnits = {};
  List<Map<String, double>> conversionHistory = [];

  @override
  void initState() {
    super.initState();
    _loadConversionUnits();
    _loadMeterValue(); 
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadConversionUnits();
	print("didChangeDependencies\n");
  }

  @override
  void didUpdateWidget(covariant ConversionTab oldWidget) {
	  super.didUpdateWidget(oldWidget);
	  _loadConversionUnits();
	print("didUpdateWidget\n");
  }



  void reloadConversionUnits() {
    _loadConversionUnits();
  }

  Future<void> _loadConversionUnits() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? unitsJson = prefs.getString('conversionUnits');
	print("_loadConversionUnits");
    if (unitsJson != null) {
      setState(() {
        conversionUnits = Map<String, double>.from(json.decode(unitsJson));
	print("setState conversionUnits");
      });
    }
  }




  Future<void> _loadMeterValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedValue = prefs.getString('meterValue');
    if (savedValue != null) {
      setState(() {
        meterController.text = savedValue;
        meterValue = double.tryParse(savedValue) ?? 0.0;
      });
    }
  }


  Future<void> _saveMeterValue(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('meterValue', value);
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
                meterValue = double.tryParse(value) ?? 0.0;
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _updateConversionHistory();
                });
              },
              child: Text('Convertir et Ajouter à l\'Historique'),
            ),
            SizedBox(height: 20),
            Text(
              'Historique des Conversions :',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: [
                      DataColumn(label: Text('Mètres')),
                      ...conversionUnits.keys
                          .map((unit) => DataColumn(label: Text(unit)))
                          .toList(),
                    ],
                    rows: conversionHistory.map((conversion) {
                      return DataRow(
                        cells: [
                          DataCell(Text(conversion['Mètres']?.toStringAsFixed(2) ?? '')),
                          ...conversionUnits.keys.map((unit) {
                            return DataCell(Text(conversion[unit]?.toStringAsFixed(2) ?? ''));
                          }).toList(),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateConversionHistory() {
    if (meterValue > 0.0) {
      Map<String, double> conversion = {'Mètres': meterValue};
      conversion.addAll(conversionUnits.map((unit, factor) => MapEntry(unit, meterValue * factor)));
      conversionHistory.add(conversion);
    }
  }


 // @override
 // bool get wantKeepAlive => true; // Indique que vous voulez conserver l'état
}

