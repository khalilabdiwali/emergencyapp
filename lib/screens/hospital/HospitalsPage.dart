import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class HospitalsPage extends StatelessWidget {
  final List<Hospital> hospitals = [
    Hospital(
      name: 'Shaafi Hospital',
      logoUrl:
          'https://tse1.mm.bing.net/th?id=OIP.EBxI55wNVyFOKXwNkoxjTQHaHa&pid=Api&P=0&h=220',
      contactInfo: 'Phone: +(252) 612-877-778',
      description:
          'At Shaafi Hospital, we are proud to be a leading healthcare institution dedicated to serving our community with integrity, compassion, and excellence. With a rich history spanning over 7 years, our hospital has evolved into a trusted healthcare provider known for its commitment to delivering exceptional care and empowering individuals to live healthier, happier lives.',
      email: 'info@shaafihospital.so',
    ),
    Hospital(
      name: 'Kalkaal Hospital',
      logoUrl:
          'https://tse4.mm.bing.net/th?id=OIP.05cf7PrDzo0_HYrz04MsNwHaHa&pid=Api&P=0&h=220',
      contactInfo: 'Phone: (252) 617-633-661',
      description:
          'Located within the heart of Mogadishu along the Digfeer Road, Kalkaal Hospital remains one of the most easily and securely accessible private hospitals within the city. Its location within the KM4 area allows for quick and safe access by both the corporate class and the general public without compromising security and the quality of healthcare provided.Founded in 2015 during an era when Somalia badly needed a healthcare upgrade, as it rebuilt after the conflict, the hospital\'s mission is to provide high-quality yet affordable healthcare to the people living in Somalia. The foundation and the hospital are governed by the same Board of Trustees, comprised of local leaders committed to philanthropy and fulfilling the hospital\'s mission.',
      email: 'info@kalkaalhospital.so',
    ),
    Hospital(
      name: 'Banadir Hospital',
      logoUrl: 'https://moh.gov.so/en/wp-content/uploads/2022/04/banaadir.jpg',
      contactInfo: 'Phone: +(252) 615-555-111',
      description:
          'Banadir Hospital is a major public hospital in Mogadishu, specializing in maternal and child healthcare. It offers a wide range of medical services and has been a pillar of healthcare in Somalia for many years, providing critical care and support to the local population.',
      email: 'info@banadirhospital.so',
    ),
    Hospital(
      name: 'Digfer Hospital (Erdoğan Hospital)',
      logoUrl:
          'https://dosyahastane.saglik.gov.tr/WebFiles/logolar/logo-en.png',
      contactInfo: 'Phone: +(252) 617-777-888',
      description:
          'Renamed after Turkish President Recep Tayyip Erdoğan following its renovation, Digfer Hospital in Mogadishu is a significant healthcare facility. It provides a wide range of medical services, including specialized care and advanced medical treatments, serving as a critical healthcare hub in the region.',
      email: 'info@digferhospital.so',
    ),
    Hospital(
      name: 'Madina Hospital',
      logoUrl:
          'https://madinahosp.com/web/image/website/1/logo/Madina%20Hospital?unique=d4a44e3',
      contactInfo: 'Phone: +(252) 612-999-333',
      description:
          'Madina Hospital, located in Mogadishu, is well-known for its comprehensive medical services, including emergency care, surgery, and maternity services. It has been a cornerstone of healthcare in the region, providing essential services to the community for many years.',
      email: 'info@madinahospital.so',
    ),
    // Hospital(
    //   name: 'Martini Hospital',
    //   logoUrl:
    //       'https://tse1.mm.bing.net/th?id=OIP.5sDFmttrhL5jW7Xz7XSTyAHaHa&pid=Api&P=0&h=220',
    //   contactInfo: 'Phone: +(252) 613-444-555',
    //   description:
    //       'Martini Hospital, also known as De Martino Hospital, is another key healthcare facility in Mogadishu. It offers a variety of medical services, including surgery, internal medicine, pediatrics, and emergency care, playing a vital role in the healthcare system of Somalia.',
    //   email: 'info@martinihospital.so',
    // ),
    // Add more hospitals here
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hospitals'),
      ),
      body: ListView.builder(
        itemCount: hospitals.length,
        itemBuilder: (context, index) {
          final hospital = hospitals[index];
          return Card(
            margin: EdgeInsets.all(10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 5,
            child: ListTile(
              contentPadding: EdgeInsets.all(15),
              leading: CachedNetworkImage(
                imageUrl: hospital.logoUrl,
                placeholder: (context, url) => CircularProgressIndicator(),
                errorWidget: (context, url, error) => Icon(Icons.error),
                width: 50,
                height: 50,
              ),
              title: Text(
                hospital.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 5),
                  Text(hospital.contactInfo),
                  SizedBox(height: 5),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        HospitalDetailPage(hospital: hospital),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class Hospital {
  final String name;
  final String logoUrl;
  final String contactInfo;
  final String description;
  final String email;

  Hospital({
    required this.name,
    required this.logoUrl,
    required this.contactInfo,
    required this.description,
    required this.email,
  });
}

class HospitalDetailPage extends StatelessWidget {
  final Hospital hospital;

  HospitalDetailPage({required this.hospital});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(hospital.name),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CachedNetworkImage(
                  imageUrl: hospital.logoUrl,
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                  width: 100,
                  height: 100,
                ),
              ),
              SizedBox(height: 20),
              Text(
                hospital.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              SizedBox(height: 10),
              Text(
                hospital.description,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Contact Information:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 5),
              Text(
                hospital.contactInfo,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Email: ${hospital.email}',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
