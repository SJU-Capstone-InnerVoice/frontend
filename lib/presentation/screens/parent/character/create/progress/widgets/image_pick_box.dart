import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'dart:io';

class ImagePickerBox extends StatelessWidget {
  final bool hasImage;
  final File? imageFile;
  final VoidCallback onTap;

  const ImagePickerBox({
    super.key,
    required this.hasImage,
    required this.imageFile,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onTap,
            child: hasImage
                ? Container(
              height: 150,
              width: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              clipBehavior: Clip.hardEdge,
              child: Image.file(
                imageFile!,
                fit: BoxFit.cover,
              ),
            )
                : DottedBorder(
              color: Colors.grey,
              strokeWidth: 2,
              dashPattern: [8, 4],
              borderType: BorderType.RRect,
              radius: const Radius.circular(12),
              child: Container(
                height: 150,
                width: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.add_a_photo, size: 48, color: Colors.grey),
                    SizedBox(height: 12),
                    Text(
                      '사진 선택하기',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (hasImage)
            const Text(
              '우와! 정말 멋진 캐릭터네요 😍\n 다른 캐릭터로 바꾸고 싶다면 사진을 다시 눌러주세요!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.black87,
              ),
            ),
        ],
      ),
    );
  }
}