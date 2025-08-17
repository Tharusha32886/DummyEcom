import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with logo
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/icon2.png', // Replace with your logo
                    height: 100,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Lunexa',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Our Story Section
            _buildSection(
              context,
              title: 'Our Story',
              content:
                  'Founded in 2025, we started as a small team passionate about bringing quality products to your doorstep. Today, we\'ve grown into a trusted e-commerce platform serving thousands of happy customers nationwide. Our journey has been fueled by your support and our commitment to excellence.',
              icon: Icons.history,
            ),

            // Our Mission Section
            _buildSection(
              context,
              title: 'Our Mission',
              content:
                  'To revolutionize online shopping by providing an effortless, secure, and enjoyable experience. We carefully curate our product selection to ensure quality and value, while our customer-first approach guarantees satisfaction at every step of your shopping journey.',
              icon: Icons.flag,
            ),

            // Why Choose Us Section
            _buildSection(
              context,
              title: 'Why Choose Us',
              content: '',
              icon: Icons.star,
              children: [
                _buildFeatureItem('🎯 100% Authentic Products'),
                _buildFeatureItem('🚚 Fast & Reliable Delivery'),
                _buildFeatureItem('🔒 Secure Payment Options'),
                _buildFeatureItem('🔄 Easy Returns & Refunds'),
                _buildFeatureItem('📞 24/7 Customer Support'),
              ],
            ),

            const SizedBox(height: 30),

            // Team Section
            Text(
              'Meet The Team',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 15),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTeamMember(
                    'assets/images/avatar.avif', // Replace with your team images
                    'John Doe',
                    'Founder & CEO',
                  ),
                  _buildTeamMember(
                    'assets/images/avatar.avif',
                    'Jane Smith',
                    'Head of Operations',
                  ),
                  _buildTeamMember(
                    'assets/images/avatar.avif',
                    'Mike Johnson',
                    'Tech Lead',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Contact Section
            _buildSection(
              context,
              title: 'Get In Touch',
              content: 'We\'d love to hear from you!',
              icon: Icons.mail,
              children: [
                const SizedBox(height: 10),
                _buildContactOption(Icons.email, 'lunexa@gmail.com'),
                _buildContactOption(Icons.phone, '+94 71 466 2396'),
                _buildContactOption(Icons.location_on, '262, Peradeniya Rd, Kandy'),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSocialIcon(Icons.facebook, () {
                      _launchURL('https://facebook.com/yourapp');
                    }),
                    _buildSocialIcon(Icons.camera_alt, () {
                      _launchURL('https://instagram.com/yourapp');
                    _buildSocialIcon(FontAwesomeIcons.twitter, () {
                      _launchURL('https://twitter.com/yourapp');
                    });
                    }),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required String content,
    required IconData icon,
    List<Widget> children = const [],
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.blue[700]),
            const SizedBox(width: 10),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (content.isNotEmpty)
          Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ...children,
        const SizedBox(height: 25),
      ],
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const SizedBox(width: 30),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _buildTeamMember(String image, String name, String position) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 15),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage(image),
          ),
          const SizedBox(height: 10),
          Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            position,
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildContactOption(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue[700]),
          const SizedBox(width: 10),
          Text(text),
        ],
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.blue[700]),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }
}