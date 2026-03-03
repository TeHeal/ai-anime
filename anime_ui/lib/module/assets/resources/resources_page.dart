import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/provider.dart';
import 'widgets/content_area.dart';
import 'widgets/modality_tabs.dart';
import 'widgets/resource_side_nav.dart';

/// 素材库页：Column(ModalityTabs + Row(SideNav + ContentArea))
class AssetsResourcesPage extends ConsumerWidget {
  const AssetsResourcesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modality = ref.watch(selectedModalityProvider);

    return Column(
      children: [
        ModalityTabs(modality: modality),
        Expanded(
          child: Row(
            children: [
              ResourceSideNav(modality: modality),
              Expanded(child: ContentArea(modality: modality)),
            ],
          ),
        ),
      ],
    );
  }
}
