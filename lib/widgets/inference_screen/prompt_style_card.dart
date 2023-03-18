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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              onTap();
            },
            child: Container(
              decoration: BoxDecoration(
                  border: isSelected
                      ? Border.all(
                          color: Colors.blue,
                          width: 3,
                        )
                      : Border.all(
                          color: Colors.transparent,
                          width: 3,
                        ),
                  borderRadius: const BorderRadius.all(Radius.circular(8))),
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
          const SizedBox(height: 10),
          Text(
            styleKey,
            style: TextStyle(
              color: Colors.white,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
