import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Position? currentPosition;
  String? currentAddress;
  String? errorMessage;
  double? distanceInMeters; 

  // Titik tetap (_pnbLatitude, _pnbLongitude) misal kampus PNB
  final double _pnbLatitude = -8.2186;
  final double _pnbLongitude = 114.3669;

  // Fungsi izin dan ambil lokasi
  Future<void> getLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          errorMessage = "Layanan lokasi nonaktif. Aktifkan GPS.";
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            errorMessage = "Izin lokasi ditolak.";
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          errorMessage =
              "Izin lokasi ditolak permanen. Ubah izin di pengaturan HP.";
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() {
        currentPosition = position;
        errorMessage = null;

        
        distanceInMeters = Geolocator.distanceBetween(
          _pnbLatitude,
          _pnbLongitude,
          position.latitude,
          position.longitude,
        );
      });

      // Ambil alamat dari koordinat
      getAddressFromLatLng(position);
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    }
  }

  // Fungsi untuk mendapatkan alamat dari koordinat
  Future<void> getAddressFromLatLng(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      Placemark place = placemarks[0];
      setState(() {
        currentAddress =
            "${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}";
      });
    } catch (e) {
      setState(() {
        currentAddress = "Tidak dapat mengambil alamat: ${e.toString()}";
      });
    }
  }

  // UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tugas Geocoding + Jarak"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_on, size: 60, color: Colors.blue),
              const SizedBox(height: 16),

              // Pesan error
              if (errorMessage != null)
                Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                  textAlign: TextAlign.center,
                ),

              // Menampilkan Lat/Lng
              if (currentPosition != null) ...[
                Text(
                  "Latitude: ${currentPosition!.latitude}\nLongitude: ${currentPosition!.longitude}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],

              const SizedBox(height: 12),

              // Tampilkan alamat
              if (currentAddress != null)
                Text(
                  "Alamat:\n$currentAddress",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),

              const SizedBox(height: 12),

              
              if (distanceInMeters != null)
                Text(
                  "Jarak dari PNB: ${distanceInMeters!.toStringAsFixed(2)} meter",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),

              const SizedBox(height: 32),

              ElevatedButton.icon(
                onPressed: getLocation,
                icon: const Icon(Icons.my_location),
                label: const Text("Dapatkan Lokasi Sekarang"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: const Size(double.infinity, 45),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
