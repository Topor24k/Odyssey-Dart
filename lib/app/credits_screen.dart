import 'package:flutter/material.dart';

import '../data/photo_credits.dart';
import '../theme/odyssey_theme.dart';
import '../widgets/kit.dart';
import '../widgets/photo.dart';

/// Who took the photos in the app, and the licence each is used under.
class CreditsScreen extends StatelessWidget {
  const CreditsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RoundIconButton(
                      icon: Icons.arrow_back,
                      tooltip: 'Back',
                      size: 42,
                      onTap: () => Navigator.of(context).maybePop(),
                    ),
                    const SizedBox(height: 10),
                    const ScreenHeader(
                      title: 'Photo credits',
                      subtitle: 'From Wikimedia Commons',
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'The photos in Odyssey were taken by these '
                      'photographers and shared under Creative Commons or '
                      'public-domain licences. Thank you.',
                      style: OdysseyType.sans(
                        13.5,
                        color: AppColors.body,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              20,
              8,
              20,
              MediaQuery.paddingOf(context).bottom + 24,
            ),
            sliver: SliverList.separated(
              itemCount: photoCredits.length,
              separatorBuilder: (_, _) => const Divider(height: 20),
              itemBuilder: (context, i) {
                final c = photoCredits[i];
                return Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        width: 56,
                        height: 56,
                        child: PhotoImage(Photo(c.photo), width: 56),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c.caption,
                            style: OdysseyType.sans(
                              13.5,
                              color: AppColors.ink,
                              weight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${c.author} · ${c.license}',
                            style: OdysseyType.sans(12, color: AppColors.muted),
                          ),
                          SelectableText(
                            c.source,
                            maxLines: 1,
                            style: OdysseyType.sans(
                              10.5,
                              color: AppColors.sageInk,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
