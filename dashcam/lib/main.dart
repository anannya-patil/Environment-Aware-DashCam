import 'package:flutter/material.dart';
import 'sensors/sensor_manager.dart';
import 'models/sensor_data.dart';
import 'recording/recording_controller.dart';
import 'recording/recording_page.dart';
import 'utils/emergency_service.dart';
import 'utils/storage_service.dart';
import 'models/contact.dart';
import 'ui/add_contact_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  String userName = "User";
  List<ContactModel> contacts = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    final user = await StorageService.getUser();
    final savedContacts = await StorageService.getContacts();

    setState(() {
      userName = user?.name ?? "User";
      contacts = savedContacts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const SizedBox(height: 10),

              Text(
                "Hi, $userName",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Emergency Contacts",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 10),

              contacts.isEmpty
                  ? const Text(
                      "No contacts added",
                      style: TextStyle(color: Colors.white38),
                    )
                  : Column(
                      children: contacts.asMap().entries.map<Widget>((entry) {

                        int index = entry.key;
                        ContactModel c = entry.value;

                        return ListTile(
                          title: Text(c.name, style: const TextStyle(color: Colors.white)),
                          subtitle: Text(c.phone, style: const TextStyle(color: Colors.white54)),

                          // ✏️ EDIT
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddContactPage(
                                  existingContact: c,
                                  index: index,
                                ),
                              ),
                            );

                            if (result == true) {
                              loadData();
                            }
                          },

                          // 🗑 DELETE
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {

                              List<ContactModel> contacts =
                                  await StorageService.getContacts();

                              contacts.removeAt(index);

                              await StorageService.saveContacts(contacts);

                              loadData();
                            },
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 10),

                    ElevatedButton(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddContactPage(),
                          ),
                        );

                        if (result == true) {
                          loadData();
                        }
                      },
                      child: const Text("Add Contact"),
                    ),

              const SizedBox(height: 30),

              _buildCard(
                context,
                title: "Start Dashcam",
                icon: Icons.videocam,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RecordingController(),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 20),

              _buildCard(
                context,
                title: "Saved Recordings",
                icon: Icons.video_library,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RecordingsPage(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              _buildCard(
                context,
                title: "Test Emergency",
                icon: Icons.warning,
                onTap: () {
                  EmergencyService.trigger(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context,
      {required String title,
      required IconData icon,
      required VoidCallback onTap}) {

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade800),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue, size: 30),
            const SizedBox(width: 20),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SensorTestPage extends StatefulWidget {
  const SensorTestPage({super.key});

  @override
  State<SensorTestPage> createState() {
    return _SensorTestPageState();
  }
}

class _SensorTestPageState extends State<SensorTestPage> {
  final SensorManager sensorManager = SensorManager();

  double speed = 0;
  double ax = 0;
  double ay = 0;
  double az = 0;

  @override
  void initState() {
    super.initState();

    sensorManager.onSensorData = (SensorData data) {
      setState(() {
        speed = data.speed;
        ax = data.accelX;
        ay = data.accelY;
        az = data.accelZ;
      });
    };

    sensorManager.startSensorCollection();
  }

  @override
  void dispose() {
    sensorManager.stopSensorCollection();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sensor Test"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Text(
              "Speed: ${speed.toStringAsFixed(2)} km/h",
              style: const TextStyle(fontSize: 20),
            ),

            const SizedBox(height: 20),

            Text("Accel X: ${ax.toStringAsFixed(2)}"),
            Text("Accel Y: ${ay.toStringAsFixed(2)}"),
            Text("Accel Z: ${az.toStringAsFixed(2)}"),

          ],
        ),
      ),
    );
  }
}