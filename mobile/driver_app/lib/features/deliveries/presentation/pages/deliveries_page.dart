import 'package:flutter/material.dart';

class DeliveriesPage extends StatelessWidget {
  const DeliveriesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('قائمة الطلبات الجارية')),
      body: ListView.builder(
        itemCount: 3,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: const Icon(Icons.delivery_dining, color: Colors.blue),
              title: Text('طلب رقم #${1024 + index}'),
              subtitle: const Text('حالة الطلب: جاري التوصيل للموقع'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // نظام توجيه قياسي نظيف لمنع كراش الـ Router الميت
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const Scaffold(body: Center(child: Text('تفاصيل الشحنة'))))
                );
              },
            ),
          );
        },
      ),
    );
  }
}