import 'package:flutter/material.dart';
import 'configuration_tab.dart';
import 'conversion_tab.dart';
import 'photo_capture_tab.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Application de Métrologie',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  GlobalKey<ConversionTabState> _conversionTabKey = GlobalKey<ConversionTabState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
     // Ajouter un écouteur pour détecter le changement d'onglet
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        // Détecte changement d'onglet
	print("changement d'onglet");
        if (_tabController.index == 0) { // Si l'onglet de conversion est sélectionné
	print("changement d'onglet => Conversion");
	_conversionTabKey.currentState?.reloadConversionUnits();
          // Actualisez votre onglet Conversion ici
          // Cela peut être fait en utilisant un callback ou une méthode directe
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Application de Métrologie'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Conversion'),
            Tab(text: 'Photo'),
            Tab(text: 'Configuration'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ConversionTab(),
          PhotoCaptureTab(),
          ConfigurationTab(),
        ],
      ),
    );
  }
}


