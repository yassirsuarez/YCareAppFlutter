import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ycareapp/AuthPage.dart';
import 'package:ycareapp/auth.dart';
import 'firebase_options.dart';
import 'screens/screen_home.dart';
import 'screens/screen_visite.dart';
import 'screens/screen_medicine.dart';
import 'services/medicine_services.dart';
import 'package:workmanager/workmanager.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Workmanager().initialize(callbackDispatcher);
  scheduleMidnightTask();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Y-care',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: StreamBuilder(
        stream: Auth().authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return const MainPage();
          } else {
            return const AuthPage();
          }
        },
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    VisiteScreen(),
    MedicineScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await Auth().signOut();
    } catch (e) {
      print('Errore durante il logout: $e');
    }
  }

  void _showAppInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Informazioni sull\'app'),
          content: const Text(
              'Y-care è un\'app progettata per per offrire assistenza e servizi personalizzati agli utenti nella gestione della loro cura e assunzione di farmaci.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Y-care'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showAppInfo(context),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _signOut(context),
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Appuntamenti',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services),
            label: 'Medicine',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepPurple,
        onTap: _onItemTapped,
      ),
    );
  }
}
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    print("Background task is running");

    final medicineService = MedicinaService();
    await medicineService.updateAllMedicineOrari();
    return Future.value(true);
  });
}
//worker
void scheduleMidnightTask() {
  final now = DateTime.now();
  final nextMidnight = DateTime(now.year, now.month, now.day + 1);
  final initialDelay = nextMidnight.difference(now);

  Workmanager().registerOneOffTask(
    "midnight_task",
    "midnightTask",
    initialDelay: initialDelay,
    constraints: Constraints(
      networkType: NetworkType.not_required,
      requiresCharging: false,
    ),
  );
}

