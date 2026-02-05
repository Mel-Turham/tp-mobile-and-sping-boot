import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:techconnect/theme/app_theme.dart';
import 'package:techconnect/widgets/custom_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPageData> _pages = [
    OnboardingPageData(
      title: 'Trouvez un expert',
      description: 'Plombiers, électriciens, informaticiens... Trouvez le professionnel qu\'il vous faut en quelques clics.',
      icon: Icons.search,
    ),
    OnboardingPageData(
      title: 'Contactez facilement',
      description: 'Envoyez un message directement via l\'application et recevez une réponse rapide.',
      icon: Icons.message,
    ),
    OnboardingPageData(
      title: 'Service de qualité',
      description: 'Consultez les avis et notes des autres clients pour choisir le meilleur technicien.',
      icon: Icons.star,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return OnboardingPage(page: _pages[index]);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                          (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppColors.primary
                              : AppColors.primaryVeryLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  CustomButton(
                    text: _currentPage == _pages.length - 1
                        ? 'Commencer'
                        : 'Suivant',
                    onPressed: () {
                      if (_currentPage == _pages.length - 1) {
                        context.go('/login');
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  if (_currentPage < _pages.length - 1)
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: const Text(
                        'Passer',
                        style: TextStyle(color: AppColors.textLight),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final OnboardingPageData page;

  const OnboardingPage({super.key, required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.primaryVeryLight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              page.icon,
              size: 100,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 48),
          Text(
            page.title,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              color: AppColors.primary,
              fontSize: 28,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            page.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class OnboardingPageData {
  final String title;
  final String description;
  final IconData icon;

  OnboardingPageData({
    required this.title,
    required this.description,
    required this.icon,
  });
}