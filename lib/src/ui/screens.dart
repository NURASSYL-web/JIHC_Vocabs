import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app.dart';
import '../data/demo_content.dart';
import '../models/models.dart';
import '../services/tts_service.dart';
import '../state/app_controller.dart';
import 'theme.dart';

String tr(BuildContext context, String key) {
  return AppScope.of(context).controller.t(key);
}

String tx(
  BuildContext context, {
  required String ru,
  required String kz,
  required String en,
}) {
  switch (AppScope.of(context).controller.language) {
    case AppLanguage.ru:
      return ru;
    case AppLanguage.kz:
      return kz;
    case AppLanguage.en:
      return en;
  }
}

class RootFlow extends StatelessWidget {
  const RootFlow({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context).controller;
    return controller.isAuthorized
        ? const MainShell()
        : const OnboardingScreen();
  }
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController pageController = PageController();
  int page = 0;

  final List<_SplashSlide> slides = const [
    _SplashSlide(
      titleKey: 'splash_1_title',
      descKey: 'splash_1_desc',
      icon: Icons.calendar_month_outlined,
      imageAsset: 'assets/onboarding/slide_1.png',
    ),
    _SplashSlide(
      titleKey: 'splash_2_title',
      descKey: 'splash_2_desc',
      icon: Icons.layers_outlined,
      imageAsset: 'assets/onboarding/slide_2.png',
    ),
    _SplashSlide(
      titleKey: 'splash_3_title',
      descKey: 'splash_3_desc',
      icon: Icons.psychology_alt_outlined,
      imageAsset: 'assets/onboarding/slide_3.png',
    ),
    _SplashSlide(
      titleKey: 'splash_4_title',
      descKey: 'splash_4_desc',
      icon: Icons.sports_esports_outlined,
      imageAsset: 'assets/onboarding/slide_4.png',
    ),
    _SplashSlide(
      titleKey: 'splash_5_title',
      descKey: 'splash_5_desc',
      icon: Icons.groups_outlined,
      imageAsset: 'assets/onboarding/slide_5.png',
    ),
  ];

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = page == slides.length - 1;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, AppTheme.skyBlue.withValues(alpha: 0.35)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      tr(context, 'app_name'),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Spacer(),
                    PopupMenuButton<AppLanguage>(
                      tooltip: tr(context, 'language'),
                      onSelected: AppScope.of(context).controller.setLanguage,
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: AppLanguage.ru,
                          child: Text(tr(context, 'lang_ru')),
                        ),
                        PopupMenuItem(
                          value: AppLanguage.kz,
                          child: Text(tr(context, 'lang_kz')),
                        ),
                        PopupMenuItem(
                          value: AppLanguage.en,
                          child: Text(tr(context, 'lang_en')),
                        ),
                      ],
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Icon(Icons.language),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        );
                      },
                      child: Text(tr(context, 'skip')),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: PageView.builder(
                    controller: pageController,
                    itemCount: slides.length,
                    onPageChanged: (value) => setState(() => page = value),
                    itemBuilder: (context, index) {
                      final s = slides[index];
                      return _SplashCard(
                        title: tr(context, s.titleKey),
                        description: tr(context, s.descKey),
                        icon: s.icon,
                        imageAsset: s.imageAsset,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    slides.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: page == index ? 20 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: page == index
                            ? AppTheme.deepSky
                            : const Color(0xFFBEDDF8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (!isLast)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        pageController.nextPage(
                          duration: const Duration(milliseconds: 260),
                          curve: Curves.easeOut,
                        );
                      },
                      child: Text(tr(context, 'next')),
                    ),
                  ),
                if (isLast) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const RegisterWizardScreen(),
                          ),
                        );
                      },
                      child: Text(tr(context, 'start_learning')),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        );
                      },
                      child: Text(tr(context, 'login')),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SplashSlide {
  const _SplashSlide({
    required this.titleKey,
    required this.descKey,
    required this.icon,
    required this.imageAsset,
  });

  final String titleKey;
  final String descKey;
  final IconData icon;
  final String imageAsset;
}

class _SplashCard extends StatelessWidget {
  const _SplashCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.imageAsset,
  });

  final String title;
  final String description;
  final IconData icon;
  final String imageAsset;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 230,
                    height: 230,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFEAF6FF),
                      border: Border.all(color: const Color(0xFFD1EBFF)),
                    ),
                  ),
                  Image.asset(
                    imageAsset,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppTheme.skyBlue.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Icon(icon, size: 56, color: AppTheme.deepSky),
                      );
                    },
                  ),
                ],
              ),
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0D4B83),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF4D7097),
                height: 1.35,
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr(context, 'login'))),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              tr(context, 'auth_demo_hint'),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: tr(context, 'email'),
                prefixIcon: const Icon(Icons.mail_outline),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: tr(context, 'password'),
                prefixIcon: const Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final controller = AppScope.of(context).controller;
                  final error = controller.login(
                    email: emailController.text,
                    password: passwordController.text,
                  );
                  if (error != null) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(error)));
                    return;
                  }
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const RootFlow()),
                    (route) => false,
                  );
                },
                child: Text(tr(context, 'login')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RegisterWizardScreen extends StatefulWidget {
  const RegisterWizardScreen({super.key});

  @override
  State<RegisterWizardScreen> createState() => _RegisterWizardScreenState();
}

enum _RegisterThemeMode { minimal, dark, gamification }

class _RegisterWizardScreenState extends State<RegisterWizardScreen> {
  int step = 0;
  final nameController = TextEditingController();
  final surnameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  UserRole selectedRole = UserRole.student;
  String selectedGroup = kGroups.first;
  String selectedBook = 'solutions_elementary';
  _RegisterThemeMode mode = _RegisterThemeMode.minimal;

  @override
  void dispose() {
    nameController.dispose();
    surnameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context).controller;
    final palette = _paletteForMode(mode);

    return Scaffold(
      appBar: AppBar(
        title: Text(tr(context, 'registration')),
        backgroundColor: palette.pageBackground,
      ),
      backgroundColor: palette.pageBackground,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
        child: Column(
          children: [
            _buildModeSwitcher(palette),
            const SizedBox(height: 12),
            _buildStepHeader(palette),
            const SizedBox(height: 12),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [palette.cardTop, palette.cardBottom],
                  ),
                  border: Border.all(color: palette.cardBorder),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.07),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Text(
                      'Vocabulary JIHC',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: palette.titleColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Изучай новые слова из книг Solutions каждый день',
                      style: TextStyle(color: palette.subtitleColor),
                    ),
                    const SizedBox(height: 8),
                    _buildTopVisual(palette),
                    const SizedBox(height: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(14, 2, 14, 12),
                        child: IndexedStack(
                          index: step,
                          children: [
                            _buildNameStep(palette),
                            _buildGroupStep(palette),
                            _buildBookStep(controller, palette),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (step > 0)
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: palette.buttonText,
                        side: BorderSide(color: palette.buttonMain),
                      ),
                      onPressed: () => setState(() => step -= 1),
                      child: const Text('Назад'),
                    ),
                  ),
                if (step > 0) const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: palette.buttonMain,
                      foregroundColor: palette.buttonText,
                    ),
                    onPressed: () {
                      if (step < 2) {
                        setState(() => step += 1);
                        return;
                      }

                      final error = controller.register(
                        email: emailController.text,
                        password: passwordController.text,
                        firstName: nameController.text.trim().isEmpty
                            ? 'Студент'
                            : nameController.text.trim(),
                        lastName: surnameController.text.trim().isEmpty
                            ? 'Solutions'
                            : surnameController.text.trim(),
                        role: selectedRole,
                        groupCode: selectedGroup,
                        bookId: selectedBook,
                      );
                      if (error != null) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(error)));
                        return;
                      }

                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const RootFlow()),
                        (route) => false,
                      );
                    },
                    child: Text(step == 2 ? 'Завершить' : 'Далее'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeSwitcher(_RegisterPalette palette) {
    return Row(
      children: [
        _themePill(
          'Минимал',
          mode == _RegisterThemeMode.minimal,
          () {
            setState(() => mode = _RegisterThemeMode.minimal);
          },
          const Color(0xFFEEF3FF),
          const Color(0xFF475569),
        ),
        const SizedBox(width: 8),
        _themePill(
          'Тёмный',
          mode == _RegisterThemeMode.dark,
          () {
            setState(() => mode = _RegisterThemeMode.dark);
          },
          const Color(0xFF252A45),
          Colors.white,
        ),
        const SizedBox(width: 8),
        _themePill(
          'Геймифика',
          mode == _RegisterThemeMode.gamification,
          () {
            setState(() => mode = _RegisterThemeMode.gamification);
          },
          const Color(0xFFFFC52D),
          const Color(0xFF7A2A00),
        ),
      ],
    );
  }

  Expanded _themePill(
    String text,
    bool selected,
    VoidCallback onTap,
    Color selectedColor,
    Color selectedText,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? selectedColor : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFD6E5F7)),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: selected ? selectedText : const Color(0xFF8D98AA),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepHeader(_RegisterPalette palette) {
    const steps = ['Аккаунт', 'Выбор группы', 'Выбор книги'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD8E8FF)),
      ),
      child: Row(
        children: List.generate(steps.length, (index) {
          final active = step == index;
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: active ? palette.buttonMain : const Color(0xFFF5F8FD),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                steps[index],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: active ? palette.buttonText : const Color(0xFF6D7A8F),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTopVisual(_RegisterPalette palette) {
    final asset = switch (mode) {
      _RegisterThemeMode.minimal => 'assets/onboarding/slide_1.png',
      _RegisterThemeMode.dark => 'assets/onboarding/slide_3.png',
      _RegisterThemeMode.gamification => 'assets/onboarding/slide_5.png',
    };
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 14),
        height: 120,
        color: palette.bannerBg,
        child: Image.asset(
          asset,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Center(
            child: Icon(
              Icons.school_rounded,
              color: palette.buttonMain,
              size: 42,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNameStep(_RegisterPalette palette) {
    return Column(
      children: [
        TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          style: TextStyle(color: palette.fieldText),
          decoration: _fieldDecoration('Email', palette),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: passwordController,
          obscureText: true,
          style: TextStyle(color: palette.fieldText),
          decoration: _fieldDecoration('Құпиясөз', palette),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: nameController,
          style: TextStyle(color: palette.fieldText),
          decoration: _fieldDecoration('Имя', palette),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: surnameController,
          style: TextStyle(color: palette.fieldText),
          decoration: _fieldDecoration('Фамилия', palette),
        ),
        const SizedBox(height: 14),
        SegmentedButton<UserRole>(
          segments: const [
            ButtonSegment(
              value: UserRole.student,
              icon: Icon(Icons.school_outlined),
              label: Text('Студент'),
            ),
            ButtonSegment(
              value: UserRole.teacher,
              icon: Icon(Icons.badge_outlined),
              label: Text('Учитель'),
            ),
          ],
          selected: {selectedRole},
          onSelectionChanged: (selection) {
            setState(() => selectedRole = selection.first);
          },
        ),
      ],
    );
  }

  Widget _buildGroupStep(_RegisterPalette palette) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Выбор группы',
            style: TextStyle(
              color: palette.titleColor,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: kGroups
              .map(
                (g) => ChoiceChip(
                  label: Text(g),
                  selected: selectedGroup == g,
                  onSelected: (_) => setState(() => selectedGroup = g),
                  selectedColor: palette.buttonMain.withValues(alpha: 0.25),
                  side: BorderSide(color: palette.cardBorder),
                  labelStyle: TextStyle(
                    color: selectedGroup == g
                        ? palette.titleColor
                        : palette.subtitleColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildBookStep(AppController controller, _RegisterPalette palette) {
    return Column(
      children: controller.books
          .map(
            (book) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: () => setState(() => selectedBook = book.id),
                borderRadius: BorderRadius.circular(16),
                child: Ink(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: selectedBook == book.id
                        ? palette.buttonMain.withValues(alpha: 0.18)
                        : Colors.white.withValues(alpha: 0.55),
                    border: Border.all(
                      color: selectedBook == book.id
                          ? palette.buttonMain
                          : palette.cardBorder,
                      width: selectedBook == book.id ? 1.8 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 58,
                        height: 76,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: LinearGradient(
                            colors: [
                              palette.buttonMain.withValues(alpha: 0.9),
                              palette.buttonMain,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Icon(
                          Icons.menu_book_rounded,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          book.title,
                          style: TextStyle(
                            color: palette.titleColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  InputDecoration _fieldDecoration(String label, _RegisterPalette palette) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: palette.subtitleColor),
      fillColor: palette.fieldFill,
      filled: true,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: palette.cardBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: palette.buttonMain, width: 1.5),
      ),
    );
  }

  _RegisterPalette _paletteForMode(_RegisterThemeMode mode) {
    switch (mode) {
      case _RegisterThemeMode.minimal:
        return const _RegisterPalette(
          pageBackground: Color(0xFFF3F6FC),
          cardTop: Color(0xFFFFFFFF),
          cardBottom: Color(0xFFF6FAFF),
          cardBorder: Color(0xFFD9E7FA),
          bannerBg: Color(0xFFE8F3FF),
          titleColor: Color(0xFF1F2B3A),
          subtitleColor: Color(0xFF5E718C),
          buttonMain: Color(0xFF2D8CFF),
          buttonText: Colors.white,
          fieldFill: Colors.white,
          fieldText: Color(0xFF1F2B3A),
        );
      case _RegisterThemeMode.dark:
        return const _RegisterPalette(
          pageBackground: Color(0xFF151930),
          cardTop: Color(0xFF1E2340),
          cardBottom: Color(0xFF141830),
          cardBorder: Color(0xFF323A67),
          bannerBg: Color(0xFF252D52),
          titleColor: Color(0xFFE8ECFF),
          subtitleColor: Color(0xFFB4C0F0),
          buttonMain: Color(0xFF7A5CFF),
          buttonText: Colors.white,
          fieldFill: Color(0xFF252D52),
          fieldText: Color(0xFFE8ECFF),
        );
      case _RegisterThemeMode.gamification:
        return const _RegisterPalette(
          pageBackground: Color(0xFFFFF7DA),
          cardTop: Color(0xFFFFEA8A),
          cardBottom: Color(0xFFFFBF4D),
          cardBorder: Color(0xFFFFCE59),
          bannerBg: Color(0xFFFFD974),
          titleColor: Color(0xFF733300),
          subtitleColor: Color(0xFF8E4B00),
          buttonMain: Color(0xFFFF3B57),
          buttonText: Colors.white,
          fieldFill: Colors.white,
          fieldText: Color(0xFF5A2D00),
        );
    }
  }
}

class _RegisterPalette {
  const _RegisterPalette({
    required this.pageBackground,
    required this.cardTop,
    required this.cardBottom,
    required this.cardBorder,
    required this.bannerBg,
    required this.titleColor,
    required this.subtitleColor,
    required this.buttonMain,
    required this.buttonText,
    required this.fieldFill,
    required this.fieldText,
  });

  final Color pageBackground;
  final Color cardTop;
  final Color cardBottom;
  final Color cardBorder;
  final Color bannerBg;
  final Color titleColor;
  final Color subtitleColor;
  final Color buttonMain;
  final Color buttonText;
  final Color fieldFill;
  final Color fieldText;
}

class MainShell extends StatelessWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context).controller;
    final tabs = const [HomeTab(), UnitsTab(), DiscoveryTab(), ProfileTab()];
    return Scaffold(
      body: IndexedStack(index: controller.currentTab, children: tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: controller.currentTab,
        onDestinationSelected: (index) => controller.currentTab = index,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            label: tr(context, 'tab_home'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.grid_view_rounded),
            label: tr(context, 'tab_units'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.explore_outlined),
            label: tr(context, 'tab_discovery'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            label: tr(context, 'tab_profile'),
          ),
        ],
      ),
    );
  }
}

enum _HomeThemeMode { minimal, dark, gamification }

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context).controller;
    final appScope = AppScope.of(context);
    final user = controller.user!;
    final nextUnit = controller.recommendedUnit;
    final assignedUnit = controller.currentGroupAssignment;
    final todayPercent = (controller.dailyGoalProgress * 100).toStringAsFixed(
      0,
    );
    final mode = switch (appScope.visualMode) {
      AppVisualMode.light => _HomeThemeMode.minimal,
      AppVisualMode.dark => _HomeThemeMode.dark,
      AppVisualMode.gamification => _HomeThemeMode.gamification,
    };

    final palette = _paletteForMode(mode);

    return Scaffold(
      appBar: AppBar(
        title: Text(tr(context, 'home_title')),
        backgroundColor: palette.pageBackground,
        actions: [
          IconButton(
            onPressed: () {
              final nextMode = switch (appScope.visualMode) {
                AppVisualMode.light => AppVisualMode.dark,
                AppVisualMode.dark => AppVisualMode.gamification,
                AppVisualMode.gamification => AppVisualMode.light,
              };
              appScope.setVisualMode(nextMode);
            },
            icon: const Icon(Icons.brightness_6_outlined),
          ),
        ],
      ),
      backgroundColor: palette.pageBackground,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              _modeChip(
                'Минимал',
                mode == _HomeThemeMode.minimal,
                () {
                  appScope.setVisualMode(AppVisualMode.light);
                },
                const Color(0xFFFFFFFF),
                const Color(0xFF4A5669),
              ),
              const SizedBox(width: 8),
              _modeChip(
                'Тёмный',
                mode == _HomeThemeMode.dark,
                () {
                  appScope.setVisualMode(AppVisualMode.dark);
                },
                const Color(0xFF252A45),
                Colors.white,
              ),
              const SizedBox(width: 8),
              _modeChip(
                'Геймифика',
                mode == _HomeThemeMode.gamification,
                () {
                  appScope.setVisualMode(AppVisualMode.gamification);
                },
                const Color(0xFFFFBF2E),
                const Color(0xFF6B2E00),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [palette.cardTop, palette.cardBottom],
              ),
              border: Border.all(color: palette.cardBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tx(
                      context,
                      ru: 'Привет, ${user.firstName}',
                      kz: 'Сәлем, ${user.firstName}',
                      en: 'Hello, ${user.firstName}',
                    ),
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tx(
                      context,
                      ru:
                          'Приложение для студентов JIHC: учить слова из Solutions, проходить мини-тесты и вести собственный словарь.',
                      kz:
                          'JIHC студенттеріне арналған қосымша: Solutions сөздерін оқу, мини-тест тапсыру және жеке сөздік жүргізу.',
                      en:
                          'An app for JIHC students to learn Solutions vocabulary, take mini tests, and keep a personal notebook.',
                    ),
                    style: TextStyle(color: palette.textSecondary, height: 1.35),
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      height: 104,
                      width: double.infinity,
                      color: palette.bannerBg,
                      child: Image.asset(
                        'assets/onboarding/slide_2.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Center(
                          child: Icon(
                            Icons.groups_2_rounded,
                            color: palette.buttonMain,
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${(controller.overallProgress * 100).toStringAsFixed(0)}% курса',
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      value: controller.overallProgress,
                      minHeight: 10,
                      color: palette.buttonMain,
                      backgroundColor: palette.progressBg,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: palette.rowBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.workspace_premium_rounded,
                          color: palette.rowIcon,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${controller.learnedWords} слов изучено',
                            style: TextStyle(
                              color: palette.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: palette.textSecondary,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: palette.buttonMain,
                        foregroundColor: palette.buttonText,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => UnitWordsScreen(unit: nextUnit),
                          ),
                        );
                      },
                      child: Text(tr(context, 'continue_learning')),
                    ),
                  ),
                  if (!controller.isTeacher) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: palette.cardBorder),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.assignment_turned_in_rounded,
                            color: palette.buttonMain,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tx(
                                    context,
                                    ru: 'Задание от преподавателя',
                                    kz: 'Оқытушы тапсырмасы',
                                    en: 'Teacher assignment',
                                  ),
                                  style: TextStyle(
                                    color: palette.textPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                if (assignedUnit != null) ...[
                                  Text(
                                    tx(
                                      context,
                                      ru: 'Группа ${user.groupCode}',
                                      kz: '${user.groupCode} тобы',
                                      en: 'Group ${user.groupCode}',
                                    ),
                                    style: TextStyle(
                                      color: palette.textSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    assignedUnit.unitTitle,
                                    style: TextStyle(
                                      color: palette.textPrimary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    tx(
                                      context,
                                      ru:
                                          'Дедлайн: ${assignedUnit.deadline}\nНазначил: ${assignedUnit.assignedBy}',
                                      kz:
                                          'Соңғы күн: ${assignedUnit.deadline}\nТағайындаған: ${assignedUnit.assignedBy}',
                                      en:
                                          'Deadline: ${assignedUnit.deadline}\nAssigned by: ${assignedUnit.assignedBy}',
                                    ),
                                    style: TextStyle(
                                      color: palette.textSecondary,
                                    ),
                                  ),
                                ] else
                                  Text(
                                    tx(
                                      context,
                                      ru:
                                          'Пока нет активного задания для группы ${user.groupCode}. После назначения unit он появится здесь.',
                                      kz:
                                          '${user.groupCode} тобы үшін әзірше белсенді тапсырма жоқ. Unit тағайындалғаннан кейін осы жерде көрінеді.',
                                      en:
                                          'There is no active assignment for group ${user.groupCode} yet. It will appear here after the teacher assigns a unit.',
                                    ),
                                    style: TextStyle(
                                      color: palette.textSecondary,
                                      height: 1.35,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  _homeLine(
                    palette,
                    icon: Icons.check_box_outlined,
                    color: const Color(0xFF4DAAF8),
                    title: tr(context, 'today_words'),
                    trailing: '${user.dailyGoal} слов',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const TodayWordsScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  _homeLine(
                    palette,
                    icon: Icons.refresh_rounded,
                    color: const Color(0xFF2FBF71),
                    title: tr(context, 'review'),
                    trailing:
                        '${controller.smartReviewQueue(limit: 20).length} слов',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ReviewSessionScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  _homeLine(
                    palette,
                    icon: Icons.edit_note_rounded,
                    color: const Color(0xFF8B5CF6),
                    title: 'My Vocabulary',
                    trailing: '${controller.customWords.length} words',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const MyVocabularyScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  _homeLine(
                    palette,
                    icon: Icons.emoji_events_outlined,
                    color: const Color(0xFFF59E0B),
                    title: tr(context, 'achievements'),
                    trailing: 'XP ${controller.xp}',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const AchievementsScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _InfoChip(
                        icon: Icons.local_fire_department_outlined,
                        text: 'Streak ${controller.streak}',
                      ),
                      _InfoChip(
                        icon: Icons.flag_outlined,
                        text: 'Цель $todayPercent%',
                      ),
                      _InfoChip(
                        icon: Icons.menu_book_outlined,
                        text:
                            '${controller.learnedWords}/${controller.totalWords}',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Быстрый доступ к unit',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ...controller.units
              .take(4)
              .map(
                (unit) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(unit.title),
                  subtitle: Text(
                    '${controller.masteredWordsInUnit(unit)}/${unit.words.length} слов освоено',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => UnitWordsScreen(unit: unit),
                      ),
                    );
                  },
                ),
              ),
        ],
      ),
    );
  }

  Widget _homeLine(
    _HomePalette palette, {
    required IconData icon,
    required Color color,
    required String title,
    required String trailing,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: palette.rowBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 11,
                backgroundColor: color.withValues(alpha: 0.18),
                child: Icon(icon, size: 14, color: color),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(trailing, style: TextStyle(color: palette.textSecondary)),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right_rounded, color: palette.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  Expanded _modeChip(
    String label,
    bool selected,
    VoidCallback onTap,
    Color activeColor,
    Color activeText,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? activeColor : const Color(0xFFF5F8FD),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFD9E5F5)),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? activeText : const Color(0xFF7B8798),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  _HomePalette _paletteForMode(_HomeThemeMode value) {
    switch (value) {
      case _HomeThemeMode.minimal:
        return const _HomePalette(
          pageBackground: Color(0xFFF3F6FC),
          cardTop: Color(0xFFFFFFFF),
          cardBottom: Color(0xFFF6FAFF),
          cardBorder: Color(0xFFD6E5F8),
          bannerBg: Color(0xFFE8F3FF),
          textPrimary: Color(0xFF1F2B3A),
          textSecondary: Color(0xFF5D6E88),
          buttonMain: Color(0xFF2D8CFF),
          buttonText: Colors.white,
          progressBg: Color(0xFFDDE9F8),
          rowBg: Color(0xFFF9FBFF),
          rowIcon: Color(0xFFF6B321),
        );
      case _HomeThemeMode.dark:
        return const _HomePalette(
          pageBackground: Color(0xFF151930),
          cardTop: Color(0xFF1D2140),
          cardBottom: Color(0xFF13172C),
          cardBorder: Color(0xFF343B69),
          bannerBg: Color(0xFF262D52),
          textPrimary: Color(0xFFE6EBFF),
          textSecondary: Color(0xFFB2BCE1),
          buttonMain: Color(0xFF7A5CFF),
          buttonText: Colors.white,
          progressBg: Color(0xFF2D3358),
          rowBg: Color(0xFF1D2342),
          rowIcon: Color(0xFFFFCD3D),
        );
      case _HomeThemeMode.gamification:
        return const _HomePalette(
          pageBackground: Color(0xFFFFF8D8),
          cardTop: Color(0xFFFFE98A),
          cardBottom: Color(0xFFFFC84E),
          cardBorder: Color(0xFFFFCE59),
          bannerBg: Color(0xFFFFDF74),
          textPrimary: Color(0xFF6F3300),
          textSecondary: Color(0xFF8F4C00),
          buttonMain: Color(0xFFFF3B57),
          buttonText: Colors.white,
          progressBg: Color(0xFFFFE8B3),
          rowBg: Color(0xFFFFF2CC),
          rowIcon: Color(0xFFFFA019),
        );
    }
  }
}

class _HomePalette {
  const _HomePalette({
    required this.pageBackground,
    required this.cardTop,
    required this.cardBottom,
    required this.cardBorder,
    required this.bannerBg,
    required this.textPrimary,
    required this.textSecondary,
    required this.buttonMain,
    required this.buttonText,
    required this.progressBg,
    required this.rowBg,
    required this.rowIcon,
  });

  final Color pageBackground;
  final Color cardTop;
  final Color cardBottom;
  final Color cardBorder;
  final Color bannerBg;
  final Color textPrimary;
  final Color textSecondary;
  final Color buttonMain;
  final Color buttonText;
  final Color progressBg;
  final Color rowBg;
  final Color rowIcon;
}

class _BlockCard extends StatelessWidget {
  const _BlockCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class _SkyHeaderCard extends StatelessWidget {
  const _SkyHeaderCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFDFEFF), Color(0xFFDFF1FF)],
        ),
        border: Border.all(color: const Color(0xFFCDE8FF)),
      ),
      child: child,
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD6ECFF)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.deepSky),
          const SizedBox(width: 6),
          Text(text),
        ],
      ),
    );
  }
}

class UnitsTab extends StatefulWidget {
  const UnitsTab({super.key});

  @override
  State<UnitsTab> createState() => _UnitsTabState();
}

class _UnitsTabState extends State<UnitsTab> {
  final TextEditingController searchController = TextEditingController();
  UnitStatus? filterStatus;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context).controller;
    final query = searchController.text.trim().toLowerCase();
    final filtered = controller.units.where((unit) {
      final status = controller
          .unitProgress(unit.id)
          .statusForTotal(unit.words.length);
      final byStatus = filterStatus == null || status == filterStatus;
      final byQuery =
          query.isEmpty ||
          unit.title.toLowerCase().contains(query) ||
          unit.id.toLowerCase().contains(query);
      return byStatus && byQuery;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: Text(tr(context, 'units'))),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Column(
              children: [
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: tr(context, 'search_unit'),
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: searchController.text.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              searchController.clear();
                              setState(() {});
                            },
                            icon: const Icon(Icons.clear),
                          ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ChoiceChip(
                        label: const Text('Все'),
                        selected: filterStatus == null,
                        onSelected: (_) => setState(() => filterStatus = null),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('Не начат'),
                        selected: filterStatus == UnitStatus.notStarted,
                        onSelected: (_) => setState(
                          () => filterStatus = UnitStatus.notStarted,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('В процессе'),
                        selected: filterStatus == UnitStatus.inProgress,
                        onSelected: (_) => setState(
                          () => filterStatus = UnitStatus.inProgress,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('Завершён'),
                        selected: filterStatus == UnitStatus.completed,
                        onSelected: (_) =>
                            setState(() => filterStatus = UnitStatus.completed),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: filtered.length,
              separatorBuilder: (_, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final unit = filtered[index];
                final progress = controller.unitProgress(unit.id);
                final status = progress.statusForTotal(unit.words.length);
                final ratio = progress.ratioForTotal(unit.words.length);

                return Card(
                  child: ListTile(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => UnitWordsScreen(unit: unit),
                        ),
                      );
                    },
                    title: Text(unit.title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${unit.words.length} слов • ${_statusLabel(status)}',
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(value: ratio, minHeight: 8),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _statusLabel(UnitStatus status) {
    switch (status) {
      case UnitStatus.notStarted:
        return 'не начат';
      case UnitStatus.inProgress:
        return 'в процессе';
      case UnitStatus.completed:
        return 'завершен';
    }
  }
}

class UnitWordsScreen extends StatefulWidget {
  const UnitWordsScreen({super.key, required this.unit});

  final StudyUnit unit;

  @override
  State<UnitWordsScreen> createState() => _UnitWordsScreenState();
}

class _UnitWordsScreenState extends State<UnitWordsScreen> {
  final TextEditingController searchController = TextEditingController();
  int segment = 0; // 0 all, 1 favorites, 2 weak

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context).controller;
    final query = searchController.text.trim().toLowerCase();
    final words = widget.unit.words.where((word) {
      final progress = controller.wordProgress(word.id);
      final bySearch =
          query.isEmpty ||
          word.en.toLowerCase().contains(query) ||
          word.ru.toLowerCase().contains(query) ||
          word.kz.toLowerCase().contains(query);
      final bySegment = switch (segment) {
        1 => progress.isFavorite,
        2 => progress.wrongCount > 0,
        _ => true,
      };
      return bySearch && bySegment;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: Text('${widget.unit.title}: слова')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: tr(context, 'search_word'),
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchController.text.isEmpty
                  ? null
                  : IconButton(
                      onPressed: () {
                        searchController.clear();
                        setState(() {});
                      },
                      icon: const Icon(Icons.clear),
                    ),
            ),
          ),
          const SizedBox(height: 10),
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 0, label: Text('Все')),
              ButtonSegment(value: 1, label: Text('Избранные')),
              ButtonSegment(value: 2, label: Text('Сложные')),
            ],
            selected: {segment},
            onSelectionChanged: (set) => setState(() => segment = set.first),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => FlashcardsScreen(unit: widget.unit),
                      ),
                    );
                  },
                  icon: const Icon(Icons.style_outlined),
                  label: const Text('Flashcards'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => QuizScreen(unit: widget.unit),
                      ),
                    );
                  },
                  icon: const Icon(Icons.quiz_outlined),
                  label: const Text('Мини-тест'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (words.isEmpty)
            Card(
              child: Padding(
                padding: EdgeInsets.all(14),
                child: Text(tr(context, 'empty_result')),
              ),
            )
          else
            ...words.map((word) {
              final progress = controller.wordProgress(word.id);
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              word.en,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          IconButton(
                            onPressed: () => controller.toggleFavorite(word.id),
                            icon: Icon(
                              progress.isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: progress.isFavorite ? Colors.red : null,
                            ),
                          ),
                        ],
                      ),
                      Text('RU: ${word.ru}'),
                      Text('KZ: ${word.kz}'),
                      const SizedBox(height: 6),
                      Text('Definition: ${word.definitionA1}'),
                      Text('Example: ${word.example}'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => _speakWord(word.en),
                            icon: const Icon(Icons.volume_up_outlined),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () {
                              controller.markWord(
                                widget.unit.id,
                                word.id,
                                known: false,
                              );
                            },
                            child: const Text('Не знаю'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              controller.markWord(
                                widget.unit.id,
                                word.id,
                                known: true,
                              );
                            },
                            child: const Text('Знаю'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Future<void> _speakWord(String word) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await TtsService.speakWord(word);
    } on PlatformException catch (error) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(error.message ?? 'Не удалось озвучить слово')),
      );
    }
  }
}

class FlashcardsScreen extends StatefulWidget {
  const FlashcardsScreen({super.key, required this.unit});

  final StudyUnit unit;

  @override
  State<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends State<FlashcardsScreen> {
  int index = 0;
  bool showBack = false;

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context).controller;
    final word = widget.unit.words[index];

    return Scaffold(
      appBar: AppBar(title: Text('Flashcards • ${widget.unit.title}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Карточка ${index + 1} / ${widget.unit.words.length}'),
            const SizedBox(height: 14),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => showBack = !showBack),
                child: Card(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: showBack
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  word.en,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineSmall,
                                ),
                                const SizedBox(height: 14),
                                Text('RU: ${word.ru}'),
                                Text('KZ: ${word.kz}'),
                                const SizedBox(height: 10),
                                Text(
                                  word.definitionA1,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 6),
                                Text(word.example, textAlign: TextAlign.center),
                              ],
                            )
                          : Text(
                              word.en,
                              style: Theme.of(context).textTheme.displaySmall,
                              textAlign: TextAlign.center,
                            ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _next(controller, FlashcardResult.later),
                    child: const Text('Повторить позже'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _next(controller, FlashcardResult.hard),
                    child: const Text('Сложно'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _next(controller, FlashcardResult.know),
                    child: const Text('Знаю'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _next(AppController controller, FlashcardResult result) {
    final word = widget.unit.words[index];
    controller.applyFlashcard(widget.unit.id, word.id, result);

    if (index >= widget.unit.words.length - 1) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      index += 1;
      showBack = false;
    });
  }
}

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key, required this.unit});

  final StudyUnit unit;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  static const int _maxQuestions = 10;

  final Random _random = Random();
  late final List<_UnitQuizQuestion> questions = _buildQuestions();
  int qIndex = 0;
  int correct = 0;
  final List<String> wrongWordIds = [];
  int? selectedIndex;
  bool isAnswered = false;

  @override
  void dispose() {
    TtsService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(tx(context, ru: 'Мини-тест', kz: 'Мини-тест', en: 'Mini test'))),
        body: Center(
          child: Text(
            tx(
              context,
              ru: 'Недостаточно слов для теста.',
              kz: 'Тестке сөз жеткіліксіз.',
              en: 'Not enough words for the test.',
            ),
          ),
        ),
      );
    }

    final question = questions[qIndex];
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          tx(
            context,
            ru: 'Тест ${qIndex + 1}/${questions.length}',
            kz: 'Тест ${qIndex + 1}/${questions.length}',
            en: 'Test ${qIndex + 1}/${questions.length}',
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        '${qIndex + 1}/${questions.length}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        tx(
                          context,
                          ru: 'Счёт: $correct',
                          kz: 'Ұпай: $correct',
                          en: 'Score: $correct',
                        ),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: LinearProgressIndicator(
                      value: (qIndex + 1) / questions.length,
                      minHeight: 10,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tx(
                      context,
                      ru: 'Выберите правильный перевод',
                      kz: 'Дұрыс аударманы таңдаңыз',
                      en: 'Choose the correct translation',
                    ),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    question.word.en,
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            ...List.generate(
              question.options.length,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildQuizOption(question, index),
              ),
            ),
            if (isAnswered && selectedIndex != question.correctIndex)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFFCA5A5)),
                ),
                child: Text(
                  tx(
                    context,
                    ru:
                        'Правильный ответ: ${question.options[question.correctIndex]}',
                    kz:
                        'Дұрыс жауап: ${question.options[question.correctIndex]}',
                    en:
                        'Correct answer: ${question.options[question.correctIndex]}',
                  ),
                  style: const TextStyle(
                    color: Color(0xFFB91C1C),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizOption(_UnitQuizQuestion question, int index) {
    final isSelected = selectedIndex == index;
    final isCorrect = index == question.correctIndex;

    Color borderColor = const Color(0xFFD8E1EE);
    Color fillColor = Colors.white;
    Color textColor = const Color(0xFF0F172A);

    if (isAnswered) {
      if (isCorrect) {
        borderColor = const Color(0xFF22C55E);
        fillColor = const Color(0xFFECFDF3);
        textColor = const Color(0xFF166534);
      } else if (isSelected) {
        borderColor = const Color(0xFFEF4444);
        fillColor = const Color(0xFFFEF2F2);
        textColor = const Color(0xFFB91C1C);
      }
    }

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: isAnswered ? null : () => _submitAnswer(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: BoxDecoration(
          color: fillColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 1.6),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                question.options[index],
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
            if (isAnswered && isCorrect)
              const Icon(Icons.check_circle_rounded, color: Color(0xFF22C55E))
            else if (isAnswered && isSelected && !isCorrect)
              const Icon(Icons.cancel_rounded, color: Color(0xFFEF4444)),
          ],
        ),
      ),
    );
  }

  Future<void> _submitAnswer(int index) async {
    final controller = AppScope.of(context).controller;
    final question = questions[qIndex];
    final isCorrect = index == question.correctIndex;

    setState(() {
      selectedIndex = index;
      isAnswered = true;
      if (isCorrect) {
        correct += 1;
      } else {
        wrongWordIds.add(question.word.id);
      }
    });

    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    if (qIndex == questions.length - 1) {
      final score = (correct / questions.length * 100).round();
      controller.saveQuizResult(widget.unit.id, score, wrongWordIds);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => QuizResultScreen(
            unit: widget.unit,
            scorePercent: score,
            mistakes: wrongWordIds,
          ),
        ),
      );
      return;
    }

    setState(() {
      qIndex += 1;
      selectedIndex = null;
      isAnswered = false;
    });
  }

  List<_UnitQuizQuestion> _buildQuestions() {
    final words = widget.unit.words.toList()..shuffle(_random);
    final selectedWords = words.take(min(_maxQuestions, words.length)).toList();
    final allTranslations = widget.unit.words.map((word) => word.ru).toList();

    return selectedWords.map((word) {
      final wrongOptions = allTranslations
          .where((translation) => translation != word.ru)
          .toSet()
          .toList()
        ..shuffle(_random);
      final options = <String>[word.ru, ...wrongOptions.take(3)]..shuffle(_random);
      return _UnitQuizQuestion(
        word: word,
        options: options,
        correctIndex: options.indexOf(word.ru),
      );
    }).toList();
  }
}

class _UnitQuizQuestion {
  const _UnitQuizQuestion({
    required this.word,
    required this.options,
    required this.correctIndex,
  });

  final WordEntry word;
  final List<String> options;
  final int correctIndex;
}

class QuizResultScreen extends StatelessWidget {
  const QuizResultScreen({
    super.key,
    required this.unit,
    required this.scorePercent,
    required this.mistakes,
  });

  final StudyUnit unit;
  final int scorePercent;
  final List<String> mistakes;

  @override
  Widget build(BuildContext context) {
    final mistakeWords = unit.words
        .where((w) => mistakes.contains(w.id))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          tx(
            context,
            ru: 'Результат теста',
            kz: 'Тест нәтижесі',
            en: 'Test result',
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    '$scorePercent%',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 8),
                  Text(tx(context, ru: 'Ваш результат', kz: 'Сіздің нәтижеңіз', en: 'Your result')),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            tx(
              context,
              ru: 'Ошибки: ${mistakes.length}',
              kz: 'Қателер: ${mistakes.length}',
              en: 'Mistakes: ${mistakes.length}',
            ),
          ),
          const SizedBox(height: 8),
          if (mistakeWords.isEmpty)
            Text(
              tx(
                context,
                ru: 'Отлично! Ошибок нет.',
                kz: 'Тамаша! Қате жоқ.',
                en: 'Excellent! No mistakes.',
              ),
            )
          else
            ...mistakeWords.map(
              (word) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(word.en),
                subtitle: Text('${word.ru} / ${word.kz}'),
              ),
            ),
        ],
      ),
    );
  }
}

enum _DiscoveryMode { minimal, dark, gamification }

class DiscoveryTab extends StatefulWidget {
  const DiscoveryTab({super.key});

  @override
  State<DiscoveryTab> createState() => _DiscoveryTabState();
}

class _DiscoveryTabState extends State<DiscoveryTab> {
  WordEntry? random;
  _DiscoveryMode mode = _DiscoveryMode.minimal;

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context).controller;
    random ??= controller.randomWord();
    final day = controller.wordOfDay;
    final palette = _paletteForMode(mode);

    return Scaffold(
      backgroundColor: palette.pageBg,
      appBar: AppBar(
        backgroundColor: palette.pageBg,
        title: Text(tr(context, 'discovery')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              _discoveryModeChip(
                'Минимал',
                mode == _DiscoveryMode.minimal,
                () {
                  setState(() => mode = _DiscoveryMode.minimal);
                },
                const Color(0xFFFFFFFF),
                const Color(0xFF4A5568),
              ),
              const SizedBox(width: 8),
              _discoveryModeChip(
                'Тёмный',
                mode == _DiscoveryMode.dark,
                () {
                  setState(() => mode = _DiscoveryMode.dark);
                },
                const Color(0xFF222844),
                Colors.white,
              ),
              const SizedBox(width: 8),
              _discoveryModeChip(
                'Геймифика',
                mode == _DiscoveryMode.gamification,
                () {
                  setState(() => mode = _DiscoveryMode.gamification);
                },
                const Color(0xFFFFC62D),
                const Color(0xFF6E2C00),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [palette.cardTop, palette.cardBottom],
              ),
              border: Border.all(color: palette.cardBorder),
            ),
            child: Column(
              children: [
                _ActionDiscoveryTile(
                  icon: Icons.quiz_outlined,
                  title: 'Мини-тесты',
                  subtitle: 'Выбор ответа, сопоставление, аудирование',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const MiniTestsScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                _ActionDiscoveryTile(
                  icon: Icons.edit_note_rounded,
                  title: 'My Vocabulary',
                  subtitle: 'Create, edit and delete your own saved words',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const MyVocabularyScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: ListTile(
              leading: const Icon(Icons.wb_sunny_outlined),
              title: const Text('Слово дня'),
              subtitle: Text('${day.en} • ${day.ru} • ${day.kz}'),
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: ListTile(
              leading: const Icon(Icons.psychology_alt_outlined),
              title: const Text('Совет по запоминанию'),
              subtitle: const Text(
                'Повторяй слово 3 раза: утром, днём и вечером.',
              ),
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Random word'),
                  const SizedBox(height: 6),
                  Text(
                    random!.en,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text('${random!.ru} / ${random!.kz}'),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: () =>
                        setState(() => random = controller.randomWord()),
                    child: const Text('Другое случайное слово'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          _BlockCard(
            title: 'Самые сложные слова',
            subtitle: 'Топ-10 слов по ошибкам',
            icon: Icons.trending_down,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const WeakWordsScreen()),
              );
            },
          ),
          _BlockCard(
            title: 'Избранные слова',
            subtitle: 'Ваш личный список',
            icon: Icons.favorite_outline,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const FavoritesScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Expanded _discoveryModeChip(
    String text,
    bool selected,
    VoidCallback onTap,
    Color selectedColor,
    Color selectedText,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: selected ? selectedColor : const Color(0xFFF4F7FC),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFD7E4F6)),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? selectedText : const Color(0xFF73839A),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  _DiscoveryPalette _paletteForMode(_DiscoveryMode mode) {
    switch (mode) {
      case _DiscoveryMode.minimal:
        return const _DiscoveryPalette(
          pageBg: Color(0xFFF3F7FD),
          cardTop: Color(0xFFFFFFFF),
          cardBottom: Color(0xFFF6FAFF),
          cardBorder: Color(0xFFD5E7FC),
        );
      case _DiscoveryMode.dark:
        return const _DiscoveryPalette(
          pageBg: Color(0xFF151A30),
          cardTop: Color(0xFF1D2340),
          cardBottom: Color(0xFF12172D),
          cardBorder: Color(0xFF323A66),
        );
      case _DiscoveryMode.gamification:
        return const _DiscoveryPalette(
          pageBg: Color(0xFFFFF8DA),
          cardTop: Color(0xFFFFEA8B),
          cardBottom: Color(0xFFFFC552),
          cardBorder: Color(0xFFFFCE5B),
        );
    }
  }
}

class _ActionDiscoveryTile extends StatelessWidget {
  const _ActionDiscoveryTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.6),
      borderRadius: BorderRadius.circular(16),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onTap: onTap,
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}

class _DiscoveryPalette {
  const _DiscoveryPalette({
    required this.pageBg,
    required this.cardTop,
    required this.cardBottom,
    required this.cardBorder,
  });

  final Color pageBg;
  final Color cardTop;
  final Color cardBottom;
  final Color cardBorder;
}

class MiniTestsScreen extends StatefulWidget {
  const MiniTestsScreen({super.key});

  @override
  State<MiniTestsScreen> createState() => _MiniTestsScreenState();
}

class _MiniTestsScreenState extends State<MiniTestsScreen> {
  static const int _totalQuestions = 10;

  final Random _random = Random();
  late List<_MiniTestQuestion> _questions;
  int _currentIndex = 0;
  int _score = 0;
  int? _selectedIndex;
  bool _isAnswered = false;
  bool _showResult = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_currentIndex == 0 && !_showResult && !_isAnswered && (_selectedIndex == null)) {
      _questions = _buildQuestions();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showResult) {
      return _buildResultScreen();
    }

    final question = _questions[_currentIndex];
    final progressText = '${_currentIndex + 1}/$_totalQuestions';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FC),
      appBar: AppBar(
        title: const Text('Mini Test'),
        backgroundColor: const Color(0xFFF5F7FC),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          progressText,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Score: $_score',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value: (_currentIndex + 1) / _totalQuestions,
                        minHeight: 10,
                        backgroundColor: const Color(0xFFE2E8F0),
                        color: const Color(0xFF3B82F6),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Choose the correct translation',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      question.word.en,
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Pick 1 correct answer from 4 options',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: Column(
                  children: List.generate(
                    question.options.length,
                    (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildAnswerButton(question, index),
                    ),
                  ),
                ),
              ),
              if (_isAnswered && _selectedIndex != question.correctIndex)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1F2),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFFDA4AF)),
                  ),
                  child: Text(
                    'Correct answer: ${question.options[question.correctIndex]}',
                    style: const TextStyle(
                      color: Color(0xFFB42318),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerButton(_MiniTestQuestion question, int index) {
    final isSelected = _selectedIndex == index;
    final isCorrect = index == question.correctIndex;

    Color borderColor = const Color(0xFFD8E1EE);
    Color fillColor = Colors.white;
    Color textColor = const Color(0xFF0F172A);

    if (_isAnswered) {
      if (isCorrect) {
        borderColor = const Color(0xFF22C55E);
        fillColor = const Color(0xFFECFDF3);
        textColor = const Color(0xFF166534);
      } else if (isSelected) {
        borderColor = const Color(0xFFEF4444);
        fillColor = const Color(0xFFFEF2F2);
        textColor = const Color(0xFFB91C1C);
      }
    }

    return SizedBox(
      width: double.infinity,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: fillColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 1.6),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: _isAnswered ? null : () => _handleAnswer(index),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    question.options[index],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ),
                if (_isAnswered && isCorrect)
                  const Icon(Icons.check_circle_rounded, color: Color(0xFF22C55E))
                else if (_isAnswered && isSelected && !isCorrect)
                  const Icon(Icons.cancel_rounded, color: Color(0xFFEF4444)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleAnswer(int index) async {
    final question = _questions[_currentIndex];
    final correct = index == question.correctIndex;

    setState(() {
      _selectedIndex = index;
      _isAnswered = true;
      if (correct) {
        _score += 1;
      }
    });

    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    if (_currentIndex == _totalQuestions - 1) {
      setState(() {
        _showResult = true;
      });
      return;
    }

    setState(() {
      _currentIndex += 1;
      _selectedIndex = null;
      _isAnswered = false;
    });
  }

  List<_MiniTestQuestion> _buildQuestions() {
    final controller = AppScope.of(context).controller;
    final allWords = controller.units.expand((unit) => unit.words).toList();
    allWords.shuffle(_random);

    final baseWords = allWords.take(_totalQuestions).toList();
    return baseWords.map((word) {
      final wrongOptions = allWords
          .where((item) => item.id != word.id)
          .map((item) => item.ru)
          .toSet()
          .toList()
        ..shuffle(_random);

      final options = <String>[
        word.ru,
        ...wrongOptions.take(3),
      ]..shuffle(_random);

      return _MiniTestQuestion(
        word: word,
        options: options,
        correctIndex: options.indexOf(word.ru),
      );
    }).toList();
  }

  Scaffold _buildResultScreen() {
    String message;
    if (_score <= 4) {
      message = 'Keep practicing';
    } else if (_score <= 7) {
      message = 'Good job';
    } else {
      message = 'Excellent';
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FC),
      appBar: AppBar(
        title: const Text('Mini Test Result'),
        backgroundColor: const Color(0xFFF5F7FC),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 92,
                  height: 92,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF60A5FA), Color(0xFF2563EB)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Icon(
                    Icons.emoji_events_rounded,
                    color: Colors.white,
                    size: 42,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  '$_score/$_totalQuestions',
                  style: const TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _questions = _buildQuestions();
                        _currentIndex = 0;
                        _score = 0;
                        _selectedIndex = null;
                        _isAnswered = false;
                        _showResult = false;
                      });
                    },
                    child: const Text('Try again'),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Back'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniTestQuestion {
  const _MiniTestQuestion({
    required this.word,
    required this.options,
    required this.correctIndex,
  });

  final WordEntry word;
  final List<String> options;
  final int correctIndex;
}

class MyVocabularyScreen extends StatefulWidget {
  const MyVocabularyScreen({super.key});

  @override
  State<MyVocabularyScreen> createState() => _MyVocabularyScreenState();
}

class _MyVocabularyScreenState extends State<MyVocabularyScreen> {
  final TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context).controller;
    final query = searchController.text.trim().toLowerCase();
    final items = controller.customWords.where((item) {
      return query.isEmpty ||
          item.word.toLowerCase().contains(query) ||
          item.translation.toLowerCase().contains(query) ||
          item.note.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Vocabulary'),
        actions: [
          IconButton(
            onPressed: () => _openEditor(context),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(context),
        icon: const Icon(Icons.add),
        label: const Text('Add word'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SkyHeaderCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Personal vocabulary notebook',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Create, edit and delete your own words. Everything is saved locally in your account.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 10),
                  Text('Saved words: ${controller.customWords.length}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: searchController,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              hintText: 'Search your words',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  controller.customWords.isEmpty
                      ? 'No personal words yet. Add your first word.'
                      : 'Nothing found for this search.',
                ),
              ),
            )
          else
            ...items.map(
              (item) => Card(
                child: ListTile(
                  title: Text(item.word),
                  subtitle: Text('${item.translation}\n${item.note}'),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => _openEditor(context, item: item),
                        icon: const Icon(Icons.edit_outlined),
                      ),
                      IconButton(
                        onPressed: () => _confirmDelete(context, item),
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _openEditor(
    BuildContext context, {
    CustomWordNote? item,
  }) async {
    final wordController = TextEditingController(text: item?.word ?? '');
    final translationController = TextEditingController(
      text: item?.translation ?? '',
    );
    final noteController = TextEditingController(text: item?.note ?? '');
    final controller = AppScope.of(context).controller;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            MediaQuery.of(sheetContext).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item == null ? 'Add word' : 'Edit word',
                style: Theme.of(sheetContext).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: wordController,
                decoration: const InputDecoration(labelText: 'Word'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: translationController,
                decoration: const InputDecoration(labelText: 'Translation'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: noteController,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Note or example',
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final word = wordController.text.trim();
                    final translation = translationController.text.trim();
                    final note = noteController.text.trim();
                    if (word.isEmpty || translation.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Word and translation are required'),
                        ),
                      );
                      return;
                    }

                    if (item == null) {
                      controller.addCustomWord(
                        word: word,
                        translation: translation,
                        note: note,
                      );
                    } else {
                      controller.updateCustomWord(
                        id: item.id,
                        word: word,
                        translation: translation,
                        note: note,
                      );
                    }
                    Navigator.of(sheetContext).pop();
                    setState(() {});
                  },
                  child: Text(item == null ? 'Save' : 'Update'),
                ),
              ),
            ],
          ),
        );
      },
    );

    wordController.dispose();
    translationController.dispose();
    noteController.dispose();
  }

  Future<void> _confirmDelete(BuildContext context, CustomWordNote item) async {
    final controller = AppScope.of(context).controller;
    final approved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete word'),
          content: Text('Delete "${item.word}" from your vocabulary?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (approved == true) {
      controller.deleteCustomWord(item.id);
      if (!mounted) return;
      ScaffoldMessenger.of(
        this.context,
      ).showSnackBar(const SnackBar(content: Text('Word deleted')));
    }
  }
}

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context).controller;
    final user = controller.user!;
    final overallPercent = (controller.overallProgress * 100).toStringAsFixed(0);
    final xpGoal = controller.level * 160;
    final xpProgress = (controller.xp / xpGoal).clamp(0, 1).toDouble();
    final initials = user.fullName
        .split(' ')
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0])
        .join();
    final previewBadges = [
      (
        '100 слов',
        '${controller.learnedWords} words',
        const Color(0xFFFFD84D),
        const Color(0xFFFFF4C1),
      ),
      (
        'Первый unit',
        '${controller.completedUnits} completed',
        const Color(0xFF7C8CFF),
        const Color(0xFFE6EAFF),
      ),
      (
        'Огонь streak',
        '${controller.streak} дней',
        const Color(0xFFFF8C4D),
        const Color(0xFFFFE0C2),
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        title: Text(tr(context, 'profile')),
        backgroundColor: const Color(0xFFF4F7FC),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF88A8D8).withValues(alpha: 0.14),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 84,
                      height: 84,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xFF84D2FF), Color(0xFF4B9FFF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          initials.isEmpty ? 'L' : initials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.firstName,
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF17233D),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            tx(
                              context,
                              ru: 'Группа: ${user.groupCode}',
                              kz: 'Топ: ${user.groupCode}',
                              en: 'Group: ${user.groupCode}',
                            ),
                            style: const TextStyle(
                              fontSize: 17,
                              color: Color(0xFF66758E),
                            ),
                          ),
                          Text(
                            tx(
                              context,
                              ru: 'Книга: ${controller.selectedBook.title}',
                              kz: 'Кітап: ${controller.selectedBook.title}',
                              en: 'Book: ${controller.selectedBook.title}',
                            ),
                            style: const TextStyle(
                              fontSize: 17,
                              color: Color(0xFF66758E),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: OutlinedButton(
                              onPressed: () => _showBookPicker(context, controller),
                              child: Text(
                                tx(
                                  context,
                                  ru: 'Сменить книгу',
                                  kz: 'Кітапты ауыстыру',
                                  en: 'Change book',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF4F7FC),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.settings_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFE1ECFB)),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFFFFF), Color(0xFFF8FBFF)],
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: Color(0xFFFFC531),
                            size: 30,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            tx(
                              context,
                              ru: '${controller.learnedWords} Слов выучено',
                              kz: '${controller.learnedWords} сөз меңгерілді',
                              en: '${controller.learnedWords} words learned',
                            ),
                            style: const TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1A2540),
                            ),
                          ),
                          const Spacer(),
                          const Icon(Icons.flag_rounded, color: Color(0xFFFFC531)),
                          const SizedBox(width: 6),
                          Text(
                            '${controller.level}',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: LinearProgressIndicator(
                          value: controller.overallProgress,
                          minHeight: 11,
                          backgroundColor: const Color(0xFFE8EEF8),
                          color: const Color(0xFF4F97F6),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _ProfileMetricPill(
                              label: 'Course progress',
                              value: '$overallPercent%',
                              start: const Color(0xFF63ACFF),
                              end: const Color(0xFFA6D7FF),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _ProfileMetricPill(
                              label: 'XP track',
                              value: '${controller.xp} / $xpGoal',
                              start: const Color(0xFF5FD0D6),
                              end: const Color(0xFFF2C84A),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: LinearProgressIndicator(
                          value: xpProgress,
                          minHeight: 10,
                          backgroundColor: const Color(0xFFE8EEF8),
                          color: const Color(0xFF67D0D4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.emoji_events_rounded,
                  color: Color(0xFFFFC531),
                  size: 34,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${controller.xp} XP / $xpGoal XP',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A2540),
                    ),
                  ),
                ),
                FilledButton.tonal(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const AchievementsScreen(),
                      ),
                    );
                  },
                  child: Text(
                    tx(
                      context,
                      ru: 'Все достижения',
                      kz: 'Барлық жетістік',
                      en: 'All achievements',
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  tx(
                    context,
                    ru: 'Достижения',
                    kz: 'Жетістіктер',
                    en: 'Achievements',
                  ),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A2540),
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AchievementsScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 144,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: previewBadges.length,
              separatorBuilder: (_, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final badge = previewBadges[index];
                return _AchievementPreviewCard(
                  title: badge.$1,
                  subtitle: badge.$2,
                  accent: badge.$3,
                  soft: badge.$4,
                );
              },
            ),
          ),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                _ProfileMenuTile(
                  icon: Icons.adjust_rounded,
                  iconColor: const Color(0xFFFFC531),
                  title: tx(
                    context,
                    ru: 'Ежедневная цель',
                    kz: 'Күнделікті мақсат',
                    en: 'Daily goal',
                  ),
                  trailing: tx(
                    context,
                    ru: '${user.dailyGoal} слов',
                    kz: '${user.dailyGoal} сөз',
                    en: '${user.dailyGoal} words',
                  ),
                  onTap: () => _showDailyGoalDialog(context, controller),
                ),
                _ProfileMenuTile(
                  icon: Icons.notifications_active_outlined,
                  iconColor: const Color(0xFF5AB7FF),
                  title: tx(
                    context,
                    ru: 'Напоминания',
                    kz: 'Еске салғыштар',
                    en: 'Reminders',
                  ),
                  trailing: controller.remindersEnabled
                      ? tx(context, ru: 'Включены', kz: 'Қосулы', en: 'On')
                      : tx(context, ru: 'Выключены', kz: 'Өшірулі', en: 'Off'),
                  onTap: () => controller.toggleReminders(!controller.remindersEnabled),
                ),
                _ProfileMenuTile(
                  icon: Icons.bar_chart_rounded,
                  iconColor: const Color(0xFF63A8FF),
                  title: 'Статистика ошибок',
                  trailing: '${controller.weakWords.length} слов',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const WeakWordsScreen()),
                    );
                  },
                ),
                _ProfileMenuTile(
                  icon: Icons.star_rounded,
                  iconColor: const Color(0xFFFFC531),
                  title: tx(
                    context,
                    ru: 'Слабые слова',
                    kz: 'Әлсіз сөздер',
                    en: 'Weak words',
                  ),
                  trailing: '${controller.weakWords.length}',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const WeakWordsScreen()),
                    );
                  },
                ),
                _ProfileMenuTile(
                  icon: Icons.favorite_rounded,
                  iconColor: const Color(0xFF77B9FF),
                  title: tx(
                    context,
                    ru: 'Избранные слова',
                    kz: 'Таңдаулы сөздер',
                    en: 'Favorite words',
                  ),
                  trailing: '${controller.favoriteWords.length}',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const FavoritesScreen()),
                    );
                  },
                ),
                _ProfileMenuTile(
                  icon: Icons.language_rounded,
                  iconColor: const Color(0xFF5D7CFF),
                  title: 'Язык интерфейса',
                  trailing: _languageLabel(context, controller.language),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 4, 14, 12),
                  child: SegmentedButton<AppLanguage>(
                    segments: [
                      ButtonSegment(
                        value: AppLanguage.ru,
                        label: Text(tr(context, 'lang_ru')),
                      ),
                      ButtonSegment(
                        value: AppLanguage.kz,
                        label: Text(tr(context, 'lang_kz')),
                      ),
                      ButtonSegment(
                        value: AppLanguage.en,
                        label: Text(tr(context, 'lang_en')),
                      ),
                    ],
                    selected: {controller.language},
                    onSelectionChanged: (selection) {
                      controller.setLanguage(selection.first);
                    },
                  ),
                ),
                _ProfileMenuTile(
                  icon: Icons.menu_book_rounded,
                  iconColor: const Color(0xFF5FBBFF),
                  title: tx(
                    context,
                    ru: 'Сменить книгу',
                    kz: 'Кітапты ауыстыру',
                    en: 'Change book',
                  ),
                  trailing: tx(context, ru: 'Открыть', kz: 'Ашу', en: 'Open'),
                  onTap: () => _showBookPicker(context, controller),
                ),
                _ProfileMenuTile(
                  icon: Icons.download_outlined,
                  iconColor: const Color(0xFF92A0B8),
                  title: 'Export progress',
                  trailing: 'CSV/PDF',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ExportProgressScreen(),
                      ),
                    );
                  },
                ),
                _ProfileMenuTile(
                  icon: Icons.admin_panel_settings_outlined,
                  iconColor: const Color(0xFF7B8DAE),
                  title: tx(
                    context,
                    ru: 'Панель учителя',
                    kz: 'Мұғалім панелі',
                    en: 'Teacher panel',
                  ),
                  trailing: tx(context, ru: 'Открыть', kz: 'Ашу', en: 'Open'),
                  onTap: () => _openTeacherPanel(context, controller),
                ),
                _ProfileMenuTile(
                  icon: Icons.logout_rounded,
                  iconColor: const Color(0xFFFF7A7A),
                  title: tx(
                    context,
                    ru: 'Выйти',
                    kz: 'Шығу',
                    en: 'Logout',
                  ),
                  trailing: tx(context, ru: 'Выход', kz: 'Шығу', en: 'Logout'),
                  trailingColor: const Color(0xFFE05757),
                  onTap: () {
                    controller.logout();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const RootFlow()),
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _languageLabel(BuildContext context, AppLanguage language) {
    switch (language) {
      case AppLanguage.ru:
        return tr(context, 'lang_ru');
      case AppLanguage.kz:
        return tr(context, 'lang_kz');
      case AppLanguage.en:
        return tr(context, 'lang_en');
    }
  }

  void _showBookPicker(BuildContext context, AppController controller) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return ListView(
          children: controller.books
              .map(
                (book) => ListTile(
                  title: Text(book.title),
                  trailing: controller.selectedBook.id == book.id
                      ? const Icon(Icons.check)
                      : null,
                  onTap: () {
                    controller.changeBook(book.id);
                    Navigator.pop(context);
                  },
                ),
              )
              .toList(),
        );
      },
    );
  }

  Future<void> _showDailyGoalDialog(
    BuildContext context,
    AppController controller,
  ) async {
    final textController = TextEditingController(
      text: '${controller.user?.dailyGoal ?? 10}',
    );
    final nextGoal = await showDialog<int>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            tx(
              dialogContext,
              ru: 'Ежедневная цель',
              kz: 'Күнделікті мақсат',
              en: 'Daily goal',
            ),
          ),
          content: TextField(
            controller: textController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: tx(
                dialogContext,
                ru: 'Количество слов',
                kz: 'Сөз саны',
                en: 'Words count',
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(tx(dialogContext, ru: 'Отмена', kz: 'Бас тарту', en: 'Cancel')),
            ),
            ElevatedButton(
              onPressed: () {
                final parsed = int.tryParse(textController.text.trim());
                Navigator.of(dialogContext).pop(parsed);
              },
              child: Text(tx(dialogContext, ru: 'Сохранить', kz: 'Сақтау', en: 'Save')),
            ),
          ],
        );
      },
    );
    textController.dispose();

    if (nextGoal == null) return;
    controller.setDailyGoal(nextGoal);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          tx(
            context,
            ru: 'Ежедневная цель обновлена',
            kz: 'Күнделікті мақсат жаңартылды',
            en: 'Daily goal updated',
          ),
        ),
      ),
    );
  }

  Future<void> _openTeacherPanel(
    BuildContext context,
    AppController controller,
  ) async {
    if (!controller.isTeacher) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Teacher panel только для учителей')),
      );
      return;
    }

    final passwordController = TextEditingController();
    final allowed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Teacher access'),
          content: TextField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Введите пароль',
              hintText: 'teacher1234',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(
                passwordController.text.trim() == 'teacher1234',
              ),
              child: const Text('Войти'),
            ),
          ],
        );
      },
    );
    passwordController.dispose();

    if (allowed != true) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Неверный пароль')),
        );
      }
      return;
    }

    if (!context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
    );
  }
}

class ReviewSessionScreen extends StatefulWidget {
  const ReviewSessionScreen({super.key});

  @override
  State<ReviewSessionScreen> createState() => _ReviewSessionScreenState();
}

class _ReviewSessionScreenState extends State<ReviewSessionScreen> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context).controller;
    final queue = controller.smartReviewQueue();

    if (queue.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Умное повторение')),
        body: const Center(
          child: Text('Слова для повторения пока не найдены.'),
        ),
      );
    }

    final word = queue[index];
    final unit = controller.units.firstWhere(
      (u) => u.words.any((w) => w.id == word.id),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Умное повторение')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Слово ${index + 1} из ${queue.length}'),
            const SizedBox(height: 12),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        word.en,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      Text('RU: ${word.ru}'),
                      Text('KZ: ${word.kz}'),
                      const SizedBox(height: 8),
                      Text(word.definitionA1),
                      const SizedBox(height: 6),
                      Text(word.example),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _apply(
                      controller,
                      unit.id,
                      word.id,
                      false,
                      queue.length,
                    ),
                    child: const Text('Сложно'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _apply(
                      controller,
                      unit.id,
                      word.id,
                      true,
                      queue.length,
                    ),
                    child: const Text('Знаю'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _apply(
    AppController controller,
    String unitId,
    String wordId,
    bool known,
    int total,
  ) {
    controller.markWord(unitId, wordId, known: known);
    if (index >= total - 1) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => index += 1);
  }
}

class TodayWordsScreen extends StatelessWidget {
  const TodayWordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final words = AppScope.of(context).controller.todayWords;

    return Scaffold(
      appBar: AppBar(title: const Text('Слова на сегодня')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: words
            .map(
              (w) => Card(
                child: ListTile(
                  title: Text(w.en),
                  subtitle: Text('${w.ru} • ${w.kz}'),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class WeakWordsScreen extends StatelessWidget {
  const WeakWordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final weakWords = AppScope.of(context).controller.weakWords;

    return Scaffold(
      appBar: AppBar(title: const Text('Weak words')),
      body: weakWords.isEmpty
          ? const Center(child: Text('Пока нет сложных слов.'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: weakWords
                  .map(
                    (w) => Card(
                      child: ListTile(
                        title: Text(w.en),
                        subtitle: Text('${w.ru} • ${w.kz}'),
                      ),
                    ),
                  )
                  .toList(),
            ),
    );
  }
}

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = AppScope.of(context).controller.favoriteWords;

    return Scaffold(
      appBar: AppBar(title: const Text('Favorite words')),
      body: favorites.isEmpty
          ? const Center(child: Text('Избранных слов пока нет.'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: favorites
                  .map(
                    (w) => Card(
                      child: ListTile(
                        title: Text(w.en),
                        subtitle: Text('${w.ru} • ${w.kz}'),
                      ),
                    ),
                  )
                  .toList(),
            ),
    );
  }
}

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final top = [
      ('1f2', 'Айдана', 940),
      ('1f1', 'Али', 860),
      ('2d1', 'Мадина', 820),
      ('3f3', 'Диас', 780),
      ('1d2', 'Аяжан', 730),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Leaderboard')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: top.length,
        itemBuilder: (context, index) {
          final row = top[index];
          return Card(
            child: ListTile(
              leading: CircleAvatar(child: Text('${index + 1}')),
              title: Text(row.$2),
              subtitle: Text('Группа ${row.$1}'),
              trailing: Text('${row.$3} XP'),
            ),
          );
        },
      ),
    );
  }
}

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context).controller;
    final xpGoal = controller.level * 160;
    final portalProgress = (controller.xp / xpGoal).clamp(0, 1).toDouble();
    final badges = [
      _PortalBadgeData(
        title: '100 слов',
        subtitle: '${controller.learnedWords} words',
        unlocked: controller.learnedWords >= 100,
        icon: Icons.workspace_premium_rounded,
        start: const Color(0xFFFFD972),
        end: const Color(0xFFFFB344),
      ),
      _PortalBadgeData(
        title: 'Первый unit',
        subtitle: '${controller.completedUnits} completed',
        unlocked: controller.completedUnits >= 1,
        icon: Icons.menu_book_rounded,
        start: const Color(0xFF8E8CFF),
        end: const Color(0xFF5E74FF),
      ),
      _PortalBadgeData(
        title: '5 дней подряд',
        subtitle: '${controller.streak} days',
        unlocked: controller.streak >= 5,
        icon: Icons.local_fire_department_rounded,
        start: const Color(0xFFFFC96D),
        end: const Color(0xFFFF7D3D),
      ),
      _PortalBadgeData(
        title: 'XP pilot',
        subtitle: '${controller.xp} XP',
        unlocked: controller.xp >= 300,
        icon: Icons.bolt_rounded,
        start: const Color(0xFF7DE1CF),
        end: const Color(0xFF2CB8B4),
      ),
      _PortalBadgeData(
        title: 'Collector',
        subtitle: '${controller.favoriteWords.length} favorites',
        unlocked: controller.favoriteWords.length >= 5,
        icon: Icons.favorite_rounded,
        start: const Color(0xFFFFA8C2),
        end: const Color(0xFFFF6F91),
      ),
      _PortalBadgeData(
        title: 'Notebook',
        subtitle: '${controller.customWords.length} personal',
        unlocked: controller.customWords.isNotEmpty,
        icon: Icons.edit_note_rounded,
        start: const Color(0xFF8BC5FF),
        end: const Color(0xFF4B93FF),
      ),
    ];
    final unlockedCount = badges.where((item) => item.unlocked).length;
    final tier = switch (unlockedCount) {
      >= 5 => 'Legend Orbit',
      >= 3 => 'Sky Explorer',
      _ => 'New Learner',
    };

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: Text(
          tx(
            context,
            ru: 'Достижения',
            kz: 'Жетістіктер',
            en: 'Achievements',
          ),
        ),
        backgroundColor: const Color(0xFFF6F7FB),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: const LinearGradient(
                colors: [Color(0xFFFFB33C), Color(0xFFFFD258)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFC24E).withValues(alpha: 0.35),
                  blurRadius: 24,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -10,
                  top: 18,
                  child: Container(
                    width: 94,
                    height: 94,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.18),
                    ),
                  ),
                ),
                Positioned(
                  left: -14,
                  bottom: -18,
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.auto_awesome_rounded, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            tx(
                              context,
                              ru: 'Портал достижений',
                              kz: 'Жетістік порталы',
                              en: 'Achievement Portal',
                            ),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFF1CA), Color(0xFFFFFFFF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.75),
                            width: 7,
                          ),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 182,
                              height: 182,
                              child: CircularProgressIndicator(
                                value: portalProgress,
                                strokeWidth: 14,
                                backgroundColor: const Color(0xFFE5E9F6),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFFFFC531),
                                ),
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  tier,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    color: Color(0xFF6A6774),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  controller.achievementLabel(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 30,
                                    height: 1.05,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF1C2239),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${controller.xp} XP',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF56637A),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: _PortalStatCard(
                              title: 'Unlocked',
                              value: '$unlockedCount/${badges.length}',
                              icon: Icons.workspace_premium_rounded,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _PortalStatCard(
                              title: 'Streak',
                              value: '${controller.streak} days',
                              icon: Icons.local_fire_department_rounded,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx(
                    context,
                    ru: 'Лента наград',
                    kz: 'Марапаттар ағыны',
                    en: 'Reward stream',
                  ),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1B2642),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  tx(
                    context,
                    ru:
                        'До следующего уровня нужно ${xpGoal - controller.xp <= 0 ? 0 : xpGoal - controller.xp} XP. Продолжай мини-тесты, повторение и личный словарь.',
                    kz:
                        'Келесі деңгейге ${xpGoal - controller.xp <= 0 ? 0 : xpGoal - controller.xp} XP керек. Мини-тест, қайталау және жеке сөздікті жалғастыр.',
                    en:
                        'You need ${xpGoal - controller.xp <= 0 ? 0 : xpGoal - controller.xp} XP for the next level. Keep going with mini tests, review, and your notebook.',
                  ),
                  style: const TextStyle(
                    color: Color(0xFF66758E),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: portalProgress,
                    minHeight: 12,
                    backgroundColor: const Color(0xFFE9EEF6),
                    color: const Color(0xFFFFC531),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text(
            tx(
              context,
              ru: 'Галерея бейджей',
              kz: 'Белгілер галереясы',
              en: 'Badge gallery',
            ),
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A2540),
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: badges.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.02,
            ),
            itemBuilder: (context, index) {
              return _PortalBadgeCard(data: badges[index]);
            },
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx(
                    context,
                    ru: 'Миссии портала',
                    kz: 'Портал миссиялары',
                    en: 'Portal missions',
                  ),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1B2642),
                  ),
                ),
                const SizedBox(height: 12),
                _PortalMissionTile(
                  icon: Icons.auto_awesome,
                  title: 'Reach 300 XP',
                  subtitle: 'Current: ${controller.xp} XP',
                  done: controller.xp >= 300,
                ),
                _PortalMissionTile(
                  icon: Icons.whatshot_rounded,
                  title: 'Keep a 5-day streak',
                  subtitle: 'Current: ${controller.streak} days',
                  done: controller.streak >= 5,
                ),
                _PortalMissionTile(
                  icon: Icons.favorite_rounded,
                  title: 'Save 5 favorite words',
                  subtitle: 'Current: ${controller.favoriteWords.length}',
                  done: controller.favoriteWords.length >= 5,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileMetricPill extends StatelessWidget {
  const _ProfileMetricPill({
    required this.label,
    required this.value,
    required this.start,
    required this.end,
  });

  final String label;
  final String value;
  final Color start;
  final Color end;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(colors: [start, end]),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementPreviewCard extends StatelessWidget {
  const _AchievementPreviewCard({
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.soft,
  });

  final String title;
  final String subtitle;
  final Color accent;
  final Color soft;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 178,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: soft,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(Icons.auto_awesome_rounded, color: accent, size: 30),
          ),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1B2642),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(color: Color(0xFF67758E)),
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuTile extends StatelessWidget {
  const _ProfileMenuTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.trailing,
    this.trailingColor,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String trailing;
  final Color? trailingColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: iconColor),
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            trailing,
            style: TextStyle(
              color: trailingColor ?? const Color(0xFF6F7F96),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
    );
  }
}

class _PortalBadgeData {
  const _PortalBadgeData({
    required this.title,
    required this.subtitle,
    required this.unlocked,
    required this.icon,
    required this.start,
    required this.end,
  });

  final String title;
  final String subtitle;
  final bool unlocked;
  final IconData icon;
  final Color start;
  final Color end;
}

class _PortalBadgeCard extends StatelessWidget {
  const _PortalBadgeCard({required this.data});

  final _PortalBadgeData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: data.unlocked
              ? [data.start.withValues(alpha: 0.2), data.end.withValues(alpha: 0.28)]
              : [const Color(0xFFF1F4F8), const Color(0xFFE8ECF3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: data.unlocked
              ? data.end.withValues(alpha: 0.4)
              : const Color(0xFFDCE3EE),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                colors: data.unlocked
                    ? [data.start, data.end]
                    : [const Color(0xFFD8DEE9), const Color(0xFFBEC6D4)],
              ),
            ),
            child: Icon(
              data.unlocked ? data.icon : Icons.lock_rounded,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          Text(
            data.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E2740),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            data.unlocked ? data.subtitle : 'Locked for now',
            style: const TextStyle(
              color: Color(0xFF66758E),
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _PortalStatCard extends StatelessWidget {
  const _PortalStatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withValues(alpha: 0.18),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PortalMissionTile extends StatelessWidget {
  const _PortalMissionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.done,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: done ? const Color(0xFFEFFFF5) : const Color(0xFFF6F8FC),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor:
                done ? const Color(0xFF3DCB7B) : const Color(0xFFDCE5F3),
            child: Icon(icon, color: done ? Colors.white : const Color(0xFF6F7F96)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E2740),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Color(0xFF66758E)),
                ),
              ],
            ),
          ),
          Icon(
            done ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
            color: done ? const Color(0xFF3DCB7B) : const Color(0xFF9BA7B9),
          ),
        ],
      ),
    );
  }
}

class PronunciationScreen extends StatefulWidget {
  const PronunciationScreen({super.key, required this.word});

  final String word;

  @override
  State<PronunciationScreen> createState() => _PronunciationScreenState();
}

class _PronunciationScreenState extends State<PronunciationScreen> {
  bool isSpeaking = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Произношение')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.word,
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const SizedBox(height: 8),
                    const Text('Нажми play и повтори слово 3 раза.'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isSpeaking ? null : _speakWord,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Play audio'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const _ActionDoneScreen(
                        title: 'Voice practice',
                        message: 'Запись и проверка произношения готовы.',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.mic_none_rounded),
                label: const Text('Записать голос'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _speakWord() async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => isSpeaking = true);
    try {
      await TtsService.speakWord(widget.word);
    } on PlatformException catch (error) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(error.message ?? 'Не удалось озвучить слово')),
      );
    } finally {
      if (mounted) {
        setState(() => isSpeaking = false);
      }
    }
  }

  @override
  void dispose() {
    TtsService.stop();
    super.dispose();
  }
}

class ListeningPracticeScreen extends StatefulWidget {
  const ListeningPracticeScreen({
    super.key,
    required this.prompt,
    required this.word,
  });

  final String prompt;
  final String word;

  @override
  State<ListeningPracticeScreen> createState() => _ListeningPracticeScreenState();
}

class _ListeningPracticeScreenState extends State<ListeningPracticeScreen> {
  bool isSpeaking = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Аудирование')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.prompt, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.headphones_outlined),
                title: const Text('Listening mode'),
                subtitle: const Text('Прослушай и выбери правильный ответ'),
                trailing: IconButton(
                  onPressed: isSpeaking ? null : _speakWord,
                  icon: const Icon(Icons.play_circle_fill_rounded, size: 34),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Слово для озвучивания: ${widget.word}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _speakWord() async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => isSpeaking = true);
    try {
      await TtsService.speakWord(widget.word);
    } on PlatformException catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text(error.message ?? 'Не удалось воспроизвести слово')),
      );
    } finally {
      if (mounted) {
        setState(() => isSpeaking = false);
      }
    }
  }

  @override
  void dispose() {
    TtsService.stop();
    super.dispose();
  }
}

class ExportProgressScreen extends StatelessWidget {
  const ExportProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context).controller;
    return Scaffold(
      appBar: AppBar(title: const Text('Экспорт прогресса')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ваш прогресс',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text('Слов выучено: ${controller.learnedWords}'),
            Text('Unit завершено: ${controller.completedUnits}'),
            Text('XP: ${controller.xp}'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const _ActionDoneScreen(
                        title: 'CSV экспорт',
                        message: 'Файл прогресса в CSV подготовлен.',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.table_chart_outlined),
                label: const Text('Экспорт в CSV'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const _ActionDoneScreen(
                        title: 'PDF экспорт',
                        message: 'Отчёт прогресса в PDF подготовлен.',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.picture_as_pdf_outlined),
                label: const Text('Экспорт в PDF'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionDoneScreen extends StatelessWidget {
  const _ActionDoneScreen({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.verified_rounded,
                    size: 46,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AssignUnitScreen extends StatefulWidget {
  const AssignUnitScreen({super.key});

  @override
  State<AssignUnitScreen> createState() => _AssignUnitScreenState();
}

class _AssignUnitScreenState extends State<AssignUnitScreen> {
  final deadlineController = TextEditingController();
  String selectedGroup = kGroups.first;
  String? selectedBookId;
  String? selectedUnitId;

  @override
  void dispose() {
    deadlineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context).controller;
    selectedBookId ??= controller.books.first.id;
    final selectedBook = controller.books.firstWhere(
      (book) => book.id == selectedBookId,
    );
    selectedUnitId ??= selectedBook.units.first.id;

    return Scaffold(
      appBar: AppBar(title: const Text('Назначить Unit')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<String>(
            initialValue: selectedGroup,
            decoration: const InputDecoration(labelText: 'Группа'),
            items: kGroups
                .map(
                  (group) => DropdownMenuItem(
                    value: group,
                    child: Text(group),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value == null) return;
              setState(() => selectedGroup = value);
            },
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            initialValue: selectedBookId,
            decoration: const InputDecoration(labelText: 'Книга'),
            items: controller.books
                .map(
                  (book) => DropdownMenuItem(
                    value: book.id,
                    child: Text(book.title),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value == null) return;
              final book = controller.books.firstWhere((item) => item.id == value);
              setState(() {
                selectedBookId = value;
                selectedUnitId = book.units.first.id;
              });
            },
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            initialValue: selectedUnitId,
            decoration: const InputDecoration(labelText: 'Unit'),
            items: selectedBook.units
                .map(
                  (unit) => DropdownMenuItem(
                    value: unit.id,
                    child: Text(unit.title),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value == null) return;
              setState(() => selectedUnitId = value);
            },
          ),
          const SizedBox(height: 10),
          TextField(
            controller: deadlineController,
            decoration: const InputDecoration(labelText: 'Дедлайн'),
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: () {
              if (selectedUnitId == null || deadlineController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Заполните все поля')),
                );
                return;
              }
              controller.assignUnitToGroup(
                groupCode: selectedGroup,
                unitId: selectedUnitId!,
                deadline: deadlineController.text,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Unit назначен группе $selectedGroup'),
                ),
              );
              Navigator.of(context).pop();
            },
            child: const Text('Подтвердить'),
          ),
        ],
      ),
    );
  }
}

class AnnouncementComposeScreen extends StatelessWidget {
  const AnnouncementComposeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Отправить объявление')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const TextField(decoration: InputDecoration(labelText: 'Заголовок')),
          const SizedBox(height: 10),
          const TextField(
            maxLines: 6,
            decoration: InputDecoration(labelText: 'Текст сообщения'),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Объявление отправлено')),
              );
            },
            icon: const Icon(Icons.send_rounded),
            label: const Text('Отправить'),
          ),
        ],
      ),
    );
  }
}

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context).controller;
    final assignment = controller.latestAssignment;

    return Scaffold(
      appBar: AppBar(title: const Text('Teacher/Admin panel')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              title: const Text('Студенты по группам'),
              subtitle: const Text('1f1: 24 студента • 1f2: 22 • 2d1: 20'),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Прогресс группы'),
              subtitle: Text(
                'Средний прогресс: ${(controller.overallProgress * 100).toStringAsFixed(0)}%',
              ),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Результаты тестов'),
              subtitle: const Text('Unit 1 avg: 76% • Unit 2 avg: 69%'),
            ),
          ),
          if (assignment != null)
            Card(
              child: ListTile(
                title: const Text('Последнее назначение'),
                subtitle: Text(
                  '${assignment.groupCode}: ${assignment.unitTitle} • дедлайн ${assignment.deadline}',
                ),
              ),
            ),
          Card(
            child: ListTile(
              title: const Text('Назначить unit'),
              subtitle: const Text('Выбрать группу, книгу, unit и дедлайн.'),
              trailing: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AssignUnitScreen()),
                  );
                },
                child: const Text('Назначить'),
              ),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Объявления'),
              subtitle: const Text('Отправить сообщение всей группе.'),
              trailing: IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AnnouncementComposeScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.send_outlined),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
