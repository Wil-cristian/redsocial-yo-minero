import 'package:flutter/material.dart';
import 'package:yominero/core/utils/sql_executor_nested.dart';

/// Página de desarrollo para probar funcionalidades
class DevTestPage extends StatefulWidget {
  const DevTestPage({super.key});

  @override
  State<DevTestPage> createState() => _DevTestPageState();
}

class _DevTestPageState extends State<DevTestPage> {
  String _output = '';

  void _addOutput(String message) {
    setState(() {
      _output += '$message\n';
    });
    print(message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dev Test'),
        backgroundColor: Colors.amber,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () async {
                _addOutput('🔧 Iniciando habilitación de respuestas anidadas...');
                try {
                  await SQLExecutor.enableNestedResponses();
                  _addOutput('✅ Proceso completado');
                } catch (e) {
                  _addOutput('❌ Error: $e');
                }
              },
              child: const Text('Habilitar Respuestas Anidadas'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                _addOutput('🧪 Iniciando prueba de respuestas anidadas...');
                try {
                  await SQLExecutor.testNestedResponses();
                  _addOutput('✅ Prueba completada');
                } catch (e) {
                  _addOutput('❌ Error en prueba: $e');
                }
              },
              child: const Text('Probar Respuestas Anidadas'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _output.isEmpty ? 'Output aparecerá aquí...' : _output,
                    style: const TextStyle(
                      color: Colors.green,
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => setState(() => _output = ''),
              child: const Text('Limpiar Output'),
            ),
          ],
        ),
      ),
    );
  }
}