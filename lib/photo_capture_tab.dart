import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';
import 'dart:convert';
import 'package:archive/archive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';


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

  Future<String> _archiveData() async {
    // Get SharedPreferences data
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> prefsMap = prefs.getKeys().fold({}, (map, key) {
      map[key] = prefs.get(key);
      return map;
    });

			//sufix des fichier

		String suffixPhoto = DateTime.now().toLocal().toString().substring(0, 16).replaceAll(RegExp(r'[-: ]'), '');
    String prefsJson = json.encode(prefsMap);

    // Get the temporary directory
    final tempDir = await getTemporaryDirectory();
		final username =  (prefs.getString('userName') ?? '').replaceAll(RegExp(r'[\s\W]'), '_');
    
    // Create a tar file in the temporary directory
    final tarFile = File('${tempDir.path}/mesure_archive_${suffixPhoto}_${username}.tar');

    // Create a tar encoder
    final encoder = TarEncoder();
    final tarStream = OutputStream();
    encoder.start(tarStream);

		//TODO : aller chercher le username dans les prefs

    // Add JSON data as a file
    encoder.add(ArchiveFile('prefs.json', prefsJson.length, utf8.encode(prefsJson)));

	    // Add photos if available
    if (doorPhoto != null) {
      final doorPhotoBytes = doorPhoto!.readAsBytesSync();
      encoder.add(ArchiveFile('door_photo_${suffixPhoto}_${username}.jpg', doorPhotoBytes.length, doorPhotoBytes));
    }
    if (lasermeterPhoto != null) {
      final lasermeterPhotoBytes = lasermeterPhoto!.readAsBytesSync();
      encoder.add(ArchiveFile('lasermeter_photo_${suffixPhoto}.jpg', lasermeterPhotoBytes.length, lasermeterPhotoBytes));
    }

    // Complete the tar encoding process
    encoder.finish();
    tarFile.writeAsBytesSync(tarStream.getBytes());

    print('Archive created at: ${tarFile.path}');
		return tarFile.path;
  }



 Future<void> uploadFile() async {
  final String tarFilePath = await _archiveData();
   File file = File(tarFilePath);
   if (!file.existsSync()) {
     print('Erreur : Le fichier n\'existe pas.');
     return;
   }
	print('Taille du fichier : ${file.lengthSync()}');

  //final uri = Uri.parse('http://192.168.1.45:8080');
	final uri = Uri.parse('http://metrologie.greensoftware.solutions/upload.php');

  var request = http.MultipartRequest('POST', uri)
    ..files.add(await http.MultipartFile.fromPath(
      'file', tarFilePath,
			 filename: tarFilePath,
      contentType: MediaType('application', 'x-tar'),
    ));

  var response = await request.send();

  if (response.statusCode == 200) {
    print('Upload successful');
  } else {
    print('Upload failed with status: ${response.statusCode}');
  }
}



  Future<void> _archiveAndSendData() async {
    if (doorPhoto == null || lasermeterPhoto == null || currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez compléter toutes les étapes.')),
      );
      return;
    }
		SharedPreferences prefs = await SharedPreferences.getInstance();
	  String? histoMetreJson = prefs.getString('historiqMetre');
	  print("_loadConversionUnits:"+(histoMetreJson ?? '{}'));
		if (histoMetreJson != null) {
		  setState(() {
				  List<double> historiqMetre =  List<double>.from(json.decode(histoMetreJson));
					if (enteredMeasurement > 0)
						historiqMetre.add(enteredMeasurement);
						prefs.setString('curMeasuredDistance', enteredMeasurement.toStringAsFixed(2) ?? '0');
						prefs.setString('curMeasurementType', measurementType);
						prefs.setString('curLat', currentPosition!.latitude.toStringAsFixed(2) ?? '0'  );
						prefs.setString('curLon', currentPosition!.longitude.toStringAsFixed(2) ?? '0' );
						prefs.setString('historiqMetre', json.encode(historiqMetre));
					});//end state
		}



    // Archive and send logic here.
    print('Nom de l\'utilisateur: [Nom]');
    print('Fichier photo porte: ${doorPhoto!.path}');
    print('Fichier photo lasermètre: ${lasermeterPhoto!.path}');
    print('Mesure: $enteredMeasurement');
    print('Type de mesure: $measurementType');
    print('Coordonnées GPS: ${currentPosition!.latitude}, ${currentPosition!.longitude}');
    print('Description: $description');
		uploadFile();
  }
}
