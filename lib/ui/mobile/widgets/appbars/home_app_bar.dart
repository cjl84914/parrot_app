import 'package:flutter/material.dart';
import 'package:parrot/ui/mobile/widgets/buttons/menu_button.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(56.0);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.background,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
      elevation: 0.0,
      title: const Text("语鹦助手", style: TextStyle( fontSize: 16)),
      actions: const [
        SizedBox(width: 34),
        MenuButton()
      ],
    );
  }
}
