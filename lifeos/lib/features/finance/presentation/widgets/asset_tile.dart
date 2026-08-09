import 'package:flutter/material.dart';

import '../../../../core/utils/formatters.dart';
import '../../domain/entities/asset.dart';

class AssetTile extends StatelessWidget {
  const AssetTile({super.key, required this.asset, this.onTap});

  final Asset asset;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color color = Color(asset.colorValue);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.18),
          child: Icon(asset.type.icon, color: color, size: 20),
        ),
        title: Text(asset.name, overflow: TextOverflow.ellipsis),
        subtitle: Text(asset.type.label),
        trailing: Text(
          AppFormatters.currency(asset.currentValue),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
