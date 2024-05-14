import 'package:departures/api_service.dart';
import 'package:departures/departure_widget.dart';
import 'package:departures/station.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';

void main() async {
  await ApiService.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Departures',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.black,
        primaryColor: Colors.orange,
        focusColor: Colors.orange,
        textTheme: Theme.of(context)
            .textTheme
            .copyWith(
              titleSmall: Theme.of(context).textTheme.titleSmall?.copyWith(fontSize: 12),
            )
            .apply(
              bodyColor: Colors.orange,
              displayColor: Colors.orange,
            ),
        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateProperty.all(Colors.orange),
        ),
        listTileTheme: const ListTileThemeData(iconColor: Colors.orange),
      ),
      home: const MyHomePage(title: 'Departures'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Station selectedStation = stations[0];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: Column(
          children: [
            SizedBox(
              height: 300,
              child: DepartureWidget(stopPointRef: selectedStation.id),
            ),
            DropdownSearch<Station>(
              popupProps: const PopupProps.menu(
                  showSearchBox: true,
                  menuProps: MenuProps(
                    backgroundColor: Color.fromARGB(255, 107, 107, 107),
                  )),
              asyncItems: (filter) => getStations(filter),
              itemAsString: (Station u) => u.name,
              dropdownDecoratorProps: const DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                    labelText: "Station",
                    hintText: "Station",
                    labelStyle: TextStyle(color: Colors.orange),
                    hintStyle: TextStyle(color: Colors.orange),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.orange, width: 1.0)),
                    focusedBorder:
                        OutlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 1.0)),
                    focusColor: Colors.orange),
              ),
              onChanged: (Station? station) {
                if (station != null) {
                  setState(() {
                    selectedStation = station;
                  });
                }
              },
              selectedItem: selectedStation,
            ),
          ],
        ),
      ),
    );
  }

  Future<List<Station>> getStations(String filter) async {
    debugPrint('running filter: $filter');
    List<Station> filteredStations =
        stations.where((s) => s.name.toLowerCase().contains(filter.toLowerCase())).toList();
    return filteredStations;
  }
}
