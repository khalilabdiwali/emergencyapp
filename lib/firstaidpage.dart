import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sms/customPadding.dart';

class FirstAidPage extends StatelessWidget {
  final List<String> firstAidItems = [
    'CPR (Cardiopulmonary Resuscitation)',
    'Stop Bleeding',
    'Treat for Shock',
    'Burns',
    'Choking',
    'Fractures',
    'Head Injuries',
    'Seizures',
    'Allergic Reactions',
    'Poisoning',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('First Aid').tr(),
      ),
      body: customPadding(
        child: ListView.builder(
          itemCount: firstAidItems.length,
          itemBuilder: (context, index) {
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0), // Rounded corners
              ),
              elevation: 5, // Shadow for a more professional look
              //color: Color(0xffe6e7e9), // Background color of the card
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(
                    vertical: 10.0,
                    horizontal: 15.0), // Padding inside the ListTile
                title: Text(
                  firstAidItems[index].tr(),
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    // color: Colors
                    //     .white, // Changed text color to black for better contrast
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  // color: Colors
                  //     .white
                ), // Added an arrow icon to indicate navigation
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FirstAidDetailPage(
                        itemIndex: index,
                        firstAidItems: firstAidItems,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class FirstAidDetailPage extends StatelessWidget {
  final int itemIndex;
  final List<String> firstAidItems;

  FirstAidDetailPage({
    required this.itemIndex,
    required this.firstAidItems,
  });

  final List<String> details = [
    // Details corresponding to each first aid item
    'Check responsiveness: Tap and shout to see if the person responds. \nCall for help: Dial emergency services. \nAirway: Open the persons airway by tilting the head back and lifting the chin. \nBreathing: Check for breathing; if there is none, begin CPR.Compressions: Perform chest compressions, pushing hard and fast in the center of the chest (100-120 compressions per minute). \nAir: Give rescue breaths if trained; otherwise, continue compressions only.'
        .tr(),
    'Protect yourself: Wear gloves if possible. \nApply pressure: Use a clean cloth or bandage to apply firm pressure to the bleeding site. \nElevate: If possible, raise the bleeding body part above the level of the heart.\nSecure bandage: Once bleeding is controlled, secure the cloth with bandage tape.\nMonitor: Watch for signs of shock and continue to apply pressure until medical help arrives.'
        .tr(),
    'Lay the person down: Keep them on their back and elevate their feet slightly, unless this causes pain. \nKeep them comfortable: Loosen tight clothing and cover them with a blanket to maintain body temperature.\nDo not give fluids: Even if the person is thirsty, avoid giving them anything to drink.\nCall for help: Monitor their condition closely until emergency responders arrive.'
        .tr(),
    'Cool the burn: Run cool (not cold) water over the burn for several minutes or cover with cool, wet cloths.\nCover the burn: Use a sterile, non-adhesive bandage or clean cloth.\nProtect the area: Do not burst blisters.\nAvoid ointments: Do not apply butter, oils, or ointments to the burn.\nSeek medical help: For serious burns, get medical attention immediately.'
        .tr(),
    'Encourage coughing: If the person can cough or speak, encourage them to continue to clear the object.\nFive back blows: If coughing does not work, deliver five back blows between the persons shoulder blades with the heel of your hand.\nFive abdominal thrusts: If back blows don\'t work, perform the Heimlich maneuver. \nRepeat: Continue cycles of back blows and abdominal thrusts until the object is expelled or the person becomes unresponsive.'
        .tr(),
    'Immobilize the area: Do not try to realign the bone. \nSupport the limb: Use a splint or cushioning around the injured area. \nApply ice packs: To reduce swelling, apply ice wrapped in a cloth. \nAvoid moving: Limit movement and seek medical help immediately.',
    'Keep the person still: Encourage them to lie down without moving their head.\nControl bleeding: Apply gentle pressure with a cloth, avoiding direct pressure on the wound if you suspect a skull fracture.\nMonitor: Look for signs of confusion, difficulty with consciousness, or changes in behavior.\nSeek immediate help: Head injuries can be serious and require professional evaluation.'
        .tr(),
    'Prevent injury: Clear the area around the person to prevent injury.\nDo not restrain: Allow the seizure to occur without restraining the person.Place something soft under the head: Protect their head with something soft if they are on a hard surface.\nTurn them on their side: To help keep their airway clear.\nMonitor time: If the seizure lasts more than 5 minutes, call for emergency help.'
        .tr(),
    'Identify and remove the allergen: If known, quickly remove the allergen.\nMonitor for anaphylaxis: Look for trouble breathing, hives, swelling, or a drop in blood pressure.\nAdminister epinephrine: If the person has an epinephrine auto-injector and is having a severe reaction, administer it.\nCall for emergency help: Always get medical help after using an epinephrine auto-injector.'
        .tr(),
    'Identify the poison: Ask the person what they took, how much, and when.\nCall poison control: Contact a poison control center for specific advice.'
        .tr(),
  ];

  final List<String> imagePaths = [
    'assets/firstaid/stopheart.png', // CPR Image
    'assets/firstaid/bleeding.png', // Stop Bleeding Image
    'assets/stop.png', // Stop Bleeding Image
    'assets/firstaid/burn.png', // CPR Image
    'assets/firstaid/crocking.png', // CPR Image
    'assets/firstaid/brokenbone.png', // CPR Image
    'assets/firstaid/headinjury.jpg', // CPR Image
    'assets/stop.png', // Stop Bleeding Image
    'assets/firstaid/allergic.jpeg', // CPR Image
    'assets/firstaid/poisoning.jpg', // CPR Image
    // 'assets/shock.jpg', // Treat for Shock Image
    // 'assets/burns.jpg', // Burns Image
    // 'assets/choking.jpg', // Choking Image
    // 'assets/fractures.jpg', // Fractures Image
    // 'assets/head_injuries.jpg', // Head Injuries Image
    // 'assets/seizures.jpg', // Seizures Image
    // 'assets/allergic_reactions.jpg', // Allergic Reactions Image
    // 'assets/poisoning.jpg', // Poisoning Image
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          firstAidItems[itemIndex].tr(),
        ),
      ),
      body: SingleChildScrollView(
        child: customPadding(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Text(
              //   firstAidItems[itemIndex].tr(),
              //   style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
              // ),
              SizedBox(height: 8.0),
              customPadding(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                      8), // Adjust the value to get the desired roundness
                  child: Image.asset(
                    imagePaths[itemIndex],
                    height: 300,
                    width: 400,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 8.0),
              customPadding(
                child: Text(
                  details[itemIndex].tr(),
                  style: GoogleFonts.openSans(fontSize: 20.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
