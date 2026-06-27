import 'package:flutter/material.dart';

class ActiveFeaturePage extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<String> items;
  final bool readOnly;

  const ActiveFeaturePage({
    super.key,
    required this.title,
    required this.icon,
    required this.items,
    this.readOnly = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF0F766E),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(icon, color: const Color(0xFF0F766E)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    Text(readOnly ? 'Mode lihat data' : 'Fitur aktif',
                        style: TextStyle(color: Colors.white.withOpacity(0.82))),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...items.map((item) => Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: ListTile(
                leading: Icon(icon, color: const Color(0xFF1565C0)),
                title: Text(item, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(readOnly ? 'Tersedia sebagai data dummy' : 'Dapat digunakan sekarang'),
                trailing: readOnly
                    ? const Icon(Icons.visibility_outlined)
                    : const Icon(Icons.check_circle_outline, color: Colors.green),
              ),
            )),
      ],
    );
  }
}
