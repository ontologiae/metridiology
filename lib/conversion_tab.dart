
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
                setState(() {
                  meterValue = double.tryParse(value) ?? 0.0;
                });
		_saveMeterValue(value); 
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

 // @override
 // bool get wantKeepAlive => true; // Indique que vous voulez conserver l'état
}

