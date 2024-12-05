
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
	  String? histoMetreJson = prefs.getString('historiqMetre');
	  print("_loadConversionUnits:"+(histoMetreJson ?? '{}')+";"+(unitsJson ?? '{}'));
	  if (unitsJson != null) {
		  setState(() {
				  conversionUnits = Map<String, double>.from(json.decode(unitsJson));
					conversionUnits['Mètres'] = 1; // Pour avoir la colonne mètre
				  });
	  }
	  if (histoMetreJson != null) {
		  setState(() {
				  List<double> historiqMetre =  List<double>.from(json.decode(histoMetreJson));
					Map<String, double> conversion = new Map<String, double>();// {'Mètres': meterValue};
					conversionHistory = [];
					print(historiqMetre);
          historiqMetre.forEach( (metre) {
								conversion.addAll(conversionUnits.map((unit, factor) => MapEntry(unit, metre * factor)));
								conversionHistory.add(Map.from(conversion)); // Map.from( pour forcer le clone, sinon on copie le pointeur, et donc on a n fois le dernier...
								print(metre);print(conversion);print(conversionHistory);
						});
							print("conversionHistory:");
							print( conversionHistory);
					});//end state
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

  	// Ici on map la liste des mètres de l'historique et on la stocke
		List<double> historiqMetre = conversionHistory.map((conversion) { return conversion['Mètres'] ?? 1.0; }).toList();
		await prefs.setString('historiqMetre', json.encode(historiqMetre));
  }
  



@override
  Widget build(BuildContext context) {
    return Scaffold(
  appBar: AppBar(
    title: Text('Conversion de Mesures'),
  ),
  body: SingleChildScrollView(
    child: Padding(
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
          ElevatedButton(
            onPressed: () {
              setState(() {
                deleteConversionHistory();
              });
            },
            child: Text('Supprimer l\'Historique'),
          ),
          SizedBox(height: 20),
          Text(
            'Historique des Conversions :',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SingleChildScrollView(
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
        ],
      ),
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
		_saveMeterValue(meterValue?.toStringAsFixed(2) ?? '1.0');
  }

	void deleteConversionHistory() {
		conversionHistory.clear();
	}


 // @override
 // bool get wantKeepAlive => true; // Indique que vous voulez conserver l'état
}

