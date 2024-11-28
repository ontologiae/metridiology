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
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkPermissionAndGetLocation();
  }

  Future<void> _checkPermissionAndGetLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Vérifiez si les services de localisation sont activés.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Les services de localisation ne sont pas activés. Ne continuez pas.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez activer les services de localisation.')),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Les permissions sont niées, ne continuez pas.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Permissions de localisation refusées.')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Les permissions sont refusées de façon permanente.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permissions de localisation refusées de façon permanente.')),
      );
      return;
    }

    // Si les permissions sont accordées, obtenez la position.
    await _getCurrentPosition();
  }

  Future<void> _getCurrentPosition() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best, // Utiliser la meilleure précision
        timeLimit: Duration(seconds: 60), // Temps limite plus long
      );
      setState(() {
        currentPosition = position;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossible d\'obtenir la position GPS.')),
      );
    }
  }

  Future<void> _capturePhoto(String type) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        if (type == 'door') {
          doorPhoto = File(pickedFile.path);
        } else if (type == 'lasermeter') {
          lasermeterPhoto = File(pickedFile.path);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Chargement GPS...'),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Capture de Photos et Mesures'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ElevatedButton(
                onPressed: () => _capturePhoto('door'),
                child: Text('Prendre Photo de la Porte'),
              ),
              if (doorPhoto != null)
                Image.file(
                  doorPhoto!,
                  width: 100,
                  height: 100,
                ),
              ElevatedButton(
                onPressed: () => _capturePhoto('lasermeter'),
                child: Text('Prendre Photo du Lasermètre'),
              ),
              if (lasermeterPhoto != null)
                Image.file(
                  lasermeterPhoto!,
                  width: 100,
                  height: 100,
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
              if (currentPosition != null)
                Text(
                  'Position GPS: Lat ${currentPosition!.latitude}, Long ${currentPosition!.longitude}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _archiveAndSendData,
                child: Text('Archiver et Envoyer'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _archiveAndSendData() async {
    if (doorPhoto == null || lasermeterPhoto == null || currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez compléter toutes les étapes.')),
      );
      return;
    }

    // Archive and send logic here.
    print('Nom de l\'utilisateur: [Nom]');
    print('Fichier photo porte: ${doorPhoto!.path}');
    print('Fichier photo lasermètre: ${lasermeterPhoto!.path}');
    print('Mesure: $enteredMeasurement');
    print('Type de mesure: $measurementType');
    print('Coordonnées GPS: ${currentPosition!.latitude}, ${currentPosition!.longitude}');
    print('Description: $description');
  }
}
