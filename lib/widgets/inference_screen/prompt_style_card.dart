import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class PromptStyleCard extends StatelessWidget {
  const PromptStyleCard({
    super.key,
    required this.isSelected,
    required this.styleKey,
    required this.imageUrl,
    required this.onTap,
  });

  final bool isSelected;
  final String styleKey;
  final String imageUrl;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: isSelected
              ? Border.all(
                  color: Colors.blue,
                  width: 2,
                )
              : Border.all(
                  color: Colors.transparent,
                  width: 2,
                ),
          borderRadius: const BorderRadius.all(Radius.circular(8))),
      child: Card(
        color: Colors.transparent,
        child: Column(
          children: [
            InkWell(
              onTap: () {
                onTap();
              },
              child: SizedBox(
                height: 100,
                width: 100,
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  child: FittedBox(
                    fit: BoxFit.cover,
                    clipBehavior: Clip.hardEdge,
                    child: CachedNetworkImage(
                      placeholder: (context, url) => Container(),
                      errorWidget: (context, url, error) => Container(),
                      imageUrl: imageUrl,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(styleKey,
                style: const TextStyle(
                  color: Colors.amber,
                )),
          ],
        ),
      ),
    );
  }
}
