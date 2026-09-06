import 'package:flutter/material.dart';

import '../../../../config/app_config.dart';
import '../../../../config/dependency_injection.dart';
import '../../../../core/errors/failures.dart';
import '../../../../features/products/presentation/controllers/product_controller.dart';
import '../controllers/printer_controller.dart';

class PrinterPage extends StatefulWidget {
  const PrinterPage({super.key});

  @override
  State<PrinterPage> createState() => _PrinterPageState();
}

class _PrinterPageState extends State<PrinterPage> {
  ProductController get _controller => locator<PrinterController>();

  @override
  void initState() {
    super.initState();
    _controller.discover();
  }

  Future<void> _connect(String address) async {
    final ok = await _controller.connect(address);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok ? 'Printer connected' : 'Connection failed',
        ),
      ),
    );
  }

  Future<void> _testPrint() async {
    final ok = await _controller.testPrint();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok ? 'Test receipt sent' : 'Print failed',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thermal Printer'),
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _StatusCard(
                controller: _controller,
              ),
              const SizedBox(height: 16),
              const Text(
                'Available printers',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (_controller.isDiscovering)
                const Padding(
                  padding: EdgeInsets.all(8),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_controller.devices.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    'No printers found. Ensure Bluetooth is on.',
                  ),
                )
              else
                for (final device in _controller.devices)
                  Card(
                    child: ListTile(
                      leading: const Icon(
                        Icons.print_outlined,
                      ),
                      title: Text(device.name),
                      subtitle: Text(device.address),
                      trailing:
                          _controller.connectedAddress == device.address
                              ? const Icon(
                                  Icons.check_circle,
                                  color: AppConfig.SUCCESS_COLOR,
                                )
                              : FilledButton.tonal(
                                  onPressed: _controller.isConnecting
                                      ? null
                                      : () => _connect(
                                            device.address,
                                          ),
                                  child: const Text(
                                    'Connect',
                                  ),
                                ),
                    ),
                  ),
              const SizedBox(height: 12),
              if (_controller.isConnected)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _controller.isPrinting
                            ? null
                            : _testPrint,
                        icon: const Icon(
                          Icons.receipt_long_outlined,
                        ),
                        label: const Text(
                          'Test print',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor:
                              AppConfig.ERROR_COLOR,
                        ),
                        onPressed: _controller.disconnect,
                        child: const Text(
                          'Disconnect',
                        ),
                      ),
                    ),
                  ],
                ),
              if (_controller.failure != null) ...[
                const SizedBox(height: 12),
                Text(
                  mapFailureToMessage(
                    _controller.failure!,
                  ),
                  style: const TextStyle(
                    color: AppConfig.ERROR_COLOR,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              const Center(
                child: Text(
                  'ESC/POS thermal receipt printing over Bluetooth.',
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.controller,
  });

  final PrinterController controller;

  @override
  Widget build(BuildContext context) {
    const highlightAlpha = 31;

    return Card(
      color: controller.isConnected
          ? AppConfig.SUCCESS_COLOR.withAlpha(
              highlightAlpha,
            )
          : AppConfig.WARNING_COLOR.withAlpha(
              highlightAlpha,
            ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              controller.isConnected
                  ? Icons.bluetooth_connected
                  : Icons.bluetooth_disabled,
              color: controller.isConnected
                  ? AppConfig.SUCCESS_COLOR
                  : AppConfig.WARNING_COLOR,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.isConnected
                        ? 'Connected'
                        : 'Not connected',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (controller.isConnected)
                    Text(
                      controller.connectedAddress ?? '',
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
