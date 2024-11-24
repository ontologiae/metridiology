import 'package:flutter/material.dart';

class ConfigurationTab extends StatefulWidget {
  @override
  _ConfigurationTabState createState() => _ConfigurationTabState();
}

class _ConfigurationTabState extends State<ConfigurationTab> {
  String userName = '';
  String laserMeterModel = '';
  Map<String, double> conversionUnits = {
    'Coudée': 0.5,
    'Pied': 0.3048,
    // Ajoutez d'autres unités par défaut ici
  };

  TextEditingController unitNameController = TextEditingController();
  TextEditingController unitValueController = TextEditingController();

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
              decoration: InputDecoration(labelText: 'Nom de l\'auteur'),
              onChanged: (value) {
                setState(() {
                  userName = value;
                });
              },
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Modèle de lasermètre'),
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
                      conversionUnits[unitNameController.text] = double.tryParse(unitValueController.text) ?? 0.0;
                      unitNameController.clear();
                      unitValueController.clear();
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

