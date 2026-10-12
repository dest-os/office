
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:llama_flutter_android/llama_flutter_android.dart';

class LocalModelService {
  LocalModelService({LlamaController? controller})
      : _controller = controller ?? LlamaController();

  final LlamaController _controller;

  bool _disposed = false;
  bool _loading = false;

  bool get isLoading => _loading;

  Future<bool> get isModelLoaded => _controller.isModelLoaded();

  Future<void> loadModel({
    required String modelPath,
    int threads = 4,
    int contextSize = 2048,
  }) async {
    if (_disposed) {
      throw StateError('ARES yerel model servisi kapatılmış.');
    }

    if (_loading) {
      throw StateError('Yerel model zaten yükleniyor.');
    }

    final file = File(modelPath);

    if (!await file.exists()) {
      throw FileSystemException(
        'Yerel model dosyası bulunamadı.',
        modelPath,
      );
    }

    final fileSize = await file.length();

    if (fileSize == 0) {
      throw FileSystemException(
        'Yerel model dosyası boş.',
        modelPath,
      );
    }

    _loading = true;

    try {
      debugPrint('ARES_MODEL: Model yükleme kontrolü başladı.');
      debugPrint('ARES_MODEL: Dosya boyutu: $fileSize bayt.');
      debugPrint('ARES_MODEL: Threads: $threads.');
      debugPrint('ARES_MODEL: Context size: $contextSize.');

      try {
        final gpu = await _controller.detectGpu();
        final freeRamMb = gpu.freeRamBytes ~/ (1024 * 1024);

        debugPrint('ARES_MODEL: GPU: ${gpu.gpuName}.');
        debugPrint(
          'ARES_MODEL: Vulkan destekli: ${gpu.vulkanSupported}.',
        );
        debugPrint('ARES_MODEL: Kullanılabilir RAM: $freeRamMb MB.');
        debugPrint(
          'ARES_MODEL: Önerilen GPU katmanı: '
          '${gpu.recommendedGpuLayers}.',
        );
      } catch (diagnosticError, stackTrace) {
        debugPrint(
          'ARES_MODEL: Donanım kontrolü yapılamadı: $diagnosticError',
        );
        debugPrintStack(stackTrace: stackTrace);
      }

      debugPrint('ARES_MODEL: Native model yüklemesi başlıyor.');

      await _controller.loadModel(
        modelPath: modelPath,
        threads: threads,
        contextSize: contextSize,
        gpuLayers: 0,
      );

      debugPrint('ARES_MODEL: Model yüklemesi tamamlandı.');
    } catch (error, stackTrace) {
      debugPrint('ARES_MODEL: Yükleme hatası: $error');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    } finally {
      _loading = false;
    }
  }

  Future<String> generateText(
    String prompt, {
    int maxTokens = 512,
    double temperature = 0.2,
  }) async {
    if (_disposed) {
      throw StateError('ARES yerel model servisi kapatılmış.');
    }

    if (!await _controller.isModelLoaded()) {
      throw StateError('Yerel model yüklenmemiş.');
    }

    if (prompt.trim().isEmpty) {
      throw ArgumentError('Soru boş olamaz.');
    }

    final output = StringBuffer();

    await for (final token in _controller.generate(
      prompt: prompt,
      maxTokens: maxTokens,
      temperature: temperature,
    )) {
      output.write(token);
    }

    return output.toString();
  }

  Future<void> stop() async {
    if (_disposed) return;
    await _controller.stop();
  }

  Future<void> dispose() async {
    if (_disposed) return;

    _disposed = true;
    await _controller.dispose();
  }
}
