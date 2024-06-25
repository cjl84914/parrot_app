import 'package:flutter/material.dart';
import 'package:parrot/providers/character.dart';
import 'package:parrot/providers/session.dart';
import 'package:parrot/providers/tts.dart';
import 'package:parrot/providers/user.dart';
import 'package:parrot/ui/mobile/pages/character/character_customization_page.dart';
import 'package:parrot/ui/mobile/widgets/buttons/menu_button.dart';
import 'package:parrot/ui/mobile/widgets/future_avatar.dart';
import 'package:parrot/ui/mobile/widgets/tiles/session_tile.dart';
import 'package:provider/provider.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(56.0);

  @override
  Widget build(BuildContext context) {
    Session session = context.watch<Session>();
    String displayMessage = session.character.name;
    if (displayMessage.length > 30) {
      displayMessage = '${displayMessage.substring(0, 30)}...';
    }
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.background,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
      elevation: 0.0,
      title: ListTile(
        onTap: () async{
          await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const CharacterCustomizationPage()));
          context.read<Session>().notify();
        },
        contentPadding: EdgeInsets.zero,
        leading: FutureAvatar(
          key: session.character.key,
          image: session.character.profile,
          radius: 16,
        ),
        title:Text(
          displayMessage,
          style: Theme.of(context).textTheme.labelLarge,
        ),
       subtitle:  Text(
          session.model.name,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        )
      ),
      actions: [
        Builder(builder: (context) {
          bool isMuted = context.watch<TTS>().isMuted;
          return IconButton(
            icon: Icon(isMuted ? Icons.volume_off : Icons.volume_up),
            onPressed: () {
              context.read<TTS>().isMuted = !isMuted;
              context.read<TTS>().notify();
            },
          );
        }),
        const MenuButton()
      ],
    );
  }
}
