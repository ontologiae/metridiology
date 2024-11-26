import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ConfigurationTab extends StatefulWidget {
  @override
  _ConfigurationTabState createState() => _ConfigurationTabState();
}

class _ConfigurationTabState extends State<ConfigurationTab> /*with AutomaticKeepAliveClientMixin*/  {
  TextEditingController userNameController = TextEditingController();
  TextEditingController laserMeterModelController = TextEditingController();
  
  String userName = '';
  String laserMeterModel = '';
  Map<String, double> conversionUnits = {
    'Coudée GP': 0.5236,
    '[Quine]Pied': 0.3236,
    // Ajoutez d'autres unités par défaut ici
  };

  TextEditingController unitNameController = TextEditingController();
  TextEditingController unitValueController = TextEditingController();

 @override
  void initState() {
    super.initState();
    _loadUserLasermetre();

  }


  Future<void> _loadUserLasermetre() async {
	await _loadConfiguration();
	setState(() {
			print("_loadUserLasermetre:"+userName);
			userNameController.text = userName;
			laserMeterModelController.text = laserMeterModel;
			print(laserMeterModelController.text);
	});
  }

  Future<void> _saveConfiguration() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('userName', userName);
    prefs.setString('laserMeterModel', laserMeterModel);
    prefs.setString('conversionUnits', json.encode(conversionUnits));
  }


  Future<void> _loadConfiguration() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userName') ?? 'Unknown';
      laserMeterModel = prefs.getString('laserMeterModel') ?? 'Unknown';
      String? unitsJson = prefs.getString('conversionUnits');
	print(userName);
      if (unitsJson != null) {
        conversionUnits = Map<String, double>.from(json.decode(unitsJson));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configuration'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Informations Utilisateur', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextField(
              controller: userNameController,
              decoration: InputDecoration(labelText: 'Nom de l\'auteur'),
              onChanged: (value) {
                setState(() {
                  userName = value;
                });
              },
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Modèle de lasermètre'),
	      controller: laserMeterModelController,
              onChanged: (value) {
                setState(() {
                  laserMeterModel = value;
                });
              },
            ),
            SizedBox(height: 20),
            Text('Gestion des Unités', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: unitNameController,
                    decoration: InputDecoration(labelText: 'Nom de l\'unité'),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: unitValueController,
                    decoration: InputDecoration(labelText: 'Valeur en mètres'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    setState(() {
			// On vérifie que le nom et la valeur ont bien été renseigné
			double parsedConversionValue = double.tryParse(unitValueController.text) ?? 0.0;
			if (unitNameController.text.length > 0 && parsedConversionValue > 0) {
                      		conversionUnits[unitNameController.text] = parsedConversionValue;
			}
                      unitNameController.clear();
                      unitValueController.clear();
			_saveConfiguration();
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: conversionUnits.keys.length,
                itemBuilder: (context, index) {
                  String unitName = conversionUnits.keys.elementAt(index);
                  double unitValue = conversionUnits[unitName]!;
                  return ListTile(
                    title: Text('$unitName: $unitValue m'),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          conversionUnits.remove(unitName);
			  _saveConfiguration();
                        });
                      },
                    ),
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

