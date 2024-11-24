import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';

class PhotoCaptureTab extends StatefulWidget {
  @override
  _PhotoCaptureTabState createState() => _PhotoCaptureTabState();
}

class _PhotoCaptureTabState extends State<PhotoCaptureTab> {
  final ImagePicker _picker = ImagePicker();
  File? doorPhoto;
  File? lasermeterPhoto;
  double enteredMeasurement = 0.0;
  String measurementType = 'largeur';
  Position? currentPosition;
  String description = '';

  Future<void> _capturePhoto(String type) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        if (type == 'door') {
          doorPhoto = File(pickedFile.path);
        } else if (type == 'lasermeter') {
          lasermeterPhoto = File(pickedFile.path);
        }
        _getCurrentPosition();
      });
    }
  }

  Future<void> _getCurrentPosition() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      currentPosition = position;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Capture de Photos et Mesures'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: () => _capturePhoto('door'),
              child: Text('Prendre Photo de la Porte'),
            ),
            ElevatedButton(
              onPressed: () => _capturePhoto('lasermeter'),
              child: Text('Prendre Photo du Lasermètre'),
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Mesure (en mètres)'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  enteredMeasurement = double.tryParse(value) ?? 0.0;
                });
              },
            ),
            DropdownButton<String>(
              value: measurementType,
              items: <String>['largeur', 'hauteur'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  measurementType = value!;
                });
              },
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Description'),
              onChanged: (value) {
                setState(() {
                  description = value;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _archiveAndSendData,
              child: Text('Archiver et Envoyer'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _archiveAndSendData() async {
    if (doorPhoto == null || lasermeterPhoto == null || currentPosition == null) {
      // Handle missing data
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez compléter toutes les étapes.')),
      );
      return;
    }

    // Archive and send logic here. This is where you would create a tar.gz archive
    // and send it via a network request.
    // For now, we'll just print the data to the console.
    print('Nom de l\'utilisateur: [Nom]');
    print('Fichier photo porte: ${doorPhoto!.path}');
    print('Fichier photo lasermètre: ${lasermeterPhoto!.path}');
    print('Mesure: $enteredMeasurement');
    print('Type de mesure: $measurementType');
    print('Coordonnées GPS: ${currentPosition!.latitude}, ${currentPosition!.longitude}');
    print('Description: $description');
  }
}
