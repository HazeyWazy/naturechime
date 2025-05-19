import 'package:flutter/material.dart';
import 'package:naturechime/widgets/custom_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:naturechime/widgets/screen_wrapper.dart';
import 'package:naturechime/utils/theme.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;

    return ScreenWrapper(
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // App Logo
                    Image.asset(NatureChimeAssets.logo(context), height: 80),
                    const SizedBox(height: 16),
                    // App Title
                    Text(
                      'NatureChime',
                      style: TextStyle(
                        fontSize: screenWidth < 360 ? 28 : 36,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Tagline
                    Text(
                      'Capture the world, one sound at a time',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: screenWidth < 360 ? 16 : 18,
                        color: colorScheme.secondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Responsive Feature Grid
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final crossAxisCount =
                            constraints.maxWidth > 320 ? 2 : 1;

                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: 4,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 1.2,
                              ),
                          itemBuilder: (context, index) {
                            final features = [
                              {
                                'icon': CupertinoIcons.mic_fill,
                                'label': 'Record Anywhere',
                              },
                              {
                                'icon': CupertinoIcons.location_solid,
                                'label': 'Location Tagging',
                              },
                              {
                                'icon': CupertinoIcons.waveform,
                                'label': 'Discover Unique\nSoundscapes',
                              },
                              {
                                'icon': CupertinoIcons.folder_fill,
                                'label': 'Organise Your Sounds',
                              },
                            ];
                            return _featureBox(
                              context,
                              icon: features[index]['icon'] as IconData,
                              label: features[index]['label'] as String,
                              fontSize: screenWidth < 360 ? 12 : 14,
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                    // Buttons
                    CustomButton(text: 'Create Account', onPressed: () {}),
                    const SizedBox(height: 16),
                    CustomButton(
                      text: 'Log In',
                      isPrimary: false,
                      onPressed: () {},
                    ),
                    const SizedBox(height: 24),
                    // Explore Without Account Text
                    GestureDetector(
                      onTap: () {},
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Explore Without Account',
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            CupertinoIcons.chevron_right,
                            color: colorScheme.primary,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _featureBox(
    BuildContext context, {
    required IconData icon,
    required String label,
    double fontSize = 14,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.primary, width: 1.5),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 36, color: colorScheme.primary),
          const SizedBox(height: 12),
          Flexible(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: fontSize,
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
