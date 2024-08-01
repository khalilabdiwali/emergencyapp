import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class SafetyGuide extends StatelessWidget {
  final List<Map<String, dynamic>> safetyGuides = [
    {
      'title': 'Earthquake'.tr(),
      'description':
          'Drop, Cover, and Hold On. Move as little as possible - most injuries during earthquakes occur because of people moving around, walking on glass, and falling.'
              .tr(),
      'image': 'assets/naturaldisasters/earthquake.png', // Placeholder image
      'detailedSteps': [
        'Drop to the ground.'.tr(),
        'Take cover under a sturdy piece of furniture.'.tr(),
        'Hold on until shaking stops.'.tr(),
        'After the shaking stops, evacuate to a safe area.'.tr(),
        'Check for injuries and provide first aid if necessary.'.tr(),
        'Stay updated on emergency alerts and follow instructions from authorities.'
            .tr(),
      ],
    },
    {
      'title': 'Heavy Rain/Flood'.tr(),
      'description':
          'Avoid flood waters and stay indoors. If you must go out, avoid walking or driving through flood waters, which may be electrically charged from underground or downed power lines.'
              .tr(),
      'image': 'assets/naturaldisasters/flood.png', // Placeholder image
      'detailedSteps': [
        'Stay indoors if possible.'.tr(),
        'Avoid driving through flooded areas.'.tr(),
        'If trapped in a flooded area, seek higher ground and call for help.'
            .tr(),
        'Listen to weather updates and evacuation orders.'.tr(),
        'After the flood, avoid returning to your home until authorities deem it safe.'
            .tr(),
      ],
    },
    {
      'title': 'Hurricane'.tr(),
      'description':
          'Prepare an emergency kit. Stay inside and away from windows, skylights, and glass doors. Find a safe area in your home (an interior room, a closet or bathroom on the lower level).'
              .tr(),
      'image': 'assets/naturaldisasters/hurricane.jpg', // Placeholder image
      'detailedSteps': [
        'Prepare an emergency kit with essentials like water, food, medications, and important documents.'
            .tr(),
        'Stay informed about the hurricane by monitoring weather updates and alerts.'
            .tr(),
        'Board up windows and secure outdoor items.'.tr(),
        'Stay inside during the storm and away from windows and doors.'.tr(),
        'After the storm, check for damage and avoid downed power lines and flooded areas.'
            .tr(),
      ],
    },
    // Add more disasters as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Safety Guide'),
        //backgroundColor: Colors.redAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: ListView.builder(
          itemCount: safetyGuides.length,
          itemBuilder: (context, index) {
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: AssetImage(safetyGuides[index]['image']),
                  radius: 30,
                ),
                title: Text(safetyGuides[index]['title'],
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(safetyGuides[index]['description']),
                onTap: () {
                  _showSafetyDetails(context, safetyGuides[index]);
                },
              ),
            );
          },
        ),
      ),
    );
  }

  void _showSafetyDetails(
      BuildContext context, Map<String, dynamic> safetyGuide) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SafetyDetailsPage(safetyGuide: safetyGuide),
      ),
    );
  }
}

class SafetyDetailsPage extends StatelessWidget {
  final Map<String, dynamic> safetyGuide;

  SafetyDetailsPage({required this.safetyGuide});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(safetyGuide['title']),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          Image.asset(
            safetyGuide['image'],
            height: 200,
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.cover,
          ),
          SizedBox(height: 16.0),
          Text(
            safetyGuide['description'],
            style: TextStyle(fontSize: 18.0),
          ),
          SizedBox(height: 16.0),
          Text(
            'Safety Steps:',
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _buildSafetySteps(safetyGuide['detailedSteps']),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSafetySteps(List<String> steps) {
    return steps
        .map((step) => ListTile(
              leading: Icon(Icons.check),
              title: Text(step),
            ))
        .toList();
  }
}

void main() {
  runApp(MaterialApp(
    home: SafetyGuide(),
  ));
}
