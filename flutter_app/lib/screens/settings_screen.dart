import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Configurações'),
        elevation: 0,
      ),
      body: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 18,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Aparência',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Personalize seu ambiente para aproveitar cada detalhe.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.72)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.dark_mode_outlined),
                      title: const Text('Modo do Tema'),
                      subtitle: Text(_getThemeModeText(themeProvider.themeMode)),
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _ThemeButton(
                            label: 'Sistema',
                            selected: themeProvider.themeMode == ThemeMode.system,
                            onTap: () => themeProvider.setThemeMode(ThemeMode.system),
                          ),
                          _ThemeButton(
                            label: 'Claro',
                            selected: themeProvider.themeMode == ThemeMode.light,
                            onTap: () => themeProvider.setThemeMode(ThemeMode.light),
                          ),
                          _ThemeButton(
                            label: 'Escuro',
                            selected: themeProvider.themeMode == ThemeMode.dark,
                            onTap: () => themeProvider.setThemeMode(ThemeMode.dark),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Cor principal',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Wrap(
                    spacing: 14,
                    runSpacing: 14,
                    children: [
                      _ColorOption(
                        color: Colors.indigo,
                        isSelected: themeProvider.primaryColor == Colors.indigo,
                        onTap: () => themeProvider.setPrimaryColor(Colors.indigo),
                      ),
                      _ColorOption(
                        color: Colors.blue,
                        isSelected: themeProvider.primaryColor == Colors.blue,
                        onTap: () => themeProvider.setPrimaryColor(Colors.blue),
                      ),
                      _ColorOption(
                        color: Colors.teal,
                        isSelected: themeProvider.primaryColor == Colors.teal,
                        onTap: () => themeProvider.setPrimaryColor(Colors.teal),
                      ),
                      _ColorOption(
                        color: Colors.green,
                        isSelected: themeProvider.primaryColor == Colors.green,
                        onTap: () => themeProvider.setPrimaryColor(Colors.green),
                      ),
                      _ColorOption(
                        color: Colors.orange,
                        isSelected: themeProvider.primaryColor == Colors.orange,
                        onTap: () => themeProvider.setPrimaryColor(Colors.orange),
                      ),
                      _ColorOption(
                        color: Colors.red,
                        isSelected: themeProvider.primaryColor == Colors.red,
                        onTap: () => themeProvider.setPrimaryColor(Colors.red),
                      ),
                      _ColorOption(
                        color: Colors.purple,
                        isSelected: themeProvider.primaryColor == Colors.purple,
                        onTap: () => themeProvider.setPrimaryColor(Colors.purple),
                      ),
                      _ColorOption(
                        color: Colors.pink,
                        isSelected: themeProvider.primaryColor == Colors.pink,
                        onTap: () => themeProvider.setPrimaryColor(Colors.pink),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  static String _getThemeModeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'Seguir sistema';
      case ThemeMode.light:
        return 'Tema claro';
      case ThemeMode.dark:
        return 'Tema escuro';
    }
  }
}

class _ThemeButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _ColorOption extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorOption({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.black : Colors.transparent,
            width: 3,
          ),
        ),
        child: isSelected
            ? const Icon(
                Icons.check,
                color: Colors.white,
              )
            : null,
      ),
    );
  }
}