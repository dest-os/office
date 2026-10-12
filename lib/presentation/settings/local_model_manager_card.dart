import 'dart:io';

import 'package:flutter/material.dart';

import '../../infrastructure/ai/local_model_config.dart';
import '../../infrastructure/ai/local_model_downloader.dart';
import '../../infrastructure/ai/local_model_service.dart';
import '../../infrastructure/ai/local_model_storage.dart';

/// ARES gömülü yerel modelinin indirme ve yükleme kontrolleri.
class LocalModelManagerCard extends StatefulWidget {
  const LocalModelManagerCard({
    super.key,
    required this.service,
    required this.downloader,
  });

  final LocalModelService service;
  final LocalModelDownloader downloader;

  @override
  State<LocalModelManagerCard> createState() =>
      _LocalModelManagerCardState();
}

class _LocalModelManagerCardState extends State<LocalModelManagerCard> {
  final LocalModelStorage _storage = LocalModelStorage();

  bool _busy = false;
  bool _modelAvailable = false;
  bool _modelLoaded = false;
  double? _progress;
  String _status = 'Model durumu kontrol ediliyor.';

  @override
  void initState() {
    super.initState();
    _refreshStatus();
  }

  Future<void> _refreshStatus() async {
    try {
      final available = await _storage.isModelAvailable();
      final loaded = await widget.service.isModelLoaded;

      if (!mounted) return;

      setState(() {
        _modelAvailable = available;
        _modelLoaded = loaded;
        _status = loaded
            ? 'Yerel model belleğe yüklendi.'
            : available
                ? 'Model cihazda hazır; yüklenebilir.'
                : 'Model henüz indirilmedi.';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _status = 'Model durumu alınamadı: $error');
    }
  }

  Future<void> _downloadAndLoad() async {
    if (_busy) return;

    setState(() {
      _busy = true;
      _progress = 0;
      _status = 'Model indiriliyor. Dosya yaklaşık 429 MB.';
    });

    try {
      final path = await widget.downloader.downloadModel(
        onProgress: (value) {
          if (!mounted) return;
          setState(() => _progress = value);
        },
      );

      if (!mounted) return;

      setState(() => _status = 'İndirme tamamlandı. Model yükleniyor.');

      // Download progress is complete; model loading is a separate native step.
      if (mounted) {
        setState(() {
          _progress = null;
          _status = 'İndirme tamamlandı. Model belleğe yükleniyor…';
        });
      }

      await widget.service.loadModel(
        modelPath: path,
        threads: LocalModelConfig.threads,
        contextSize: LocalModelConfig.contextSize,
      );

      final loaded = await widget.service.isModelLoaded;
      if (!loaded) {
        throw StateError(
          'Native yükleme çağrısı tamamlandı ancak llama.cpp modeli yüklü göstermedi.',
        );
      }

      // Eski 1.7B dosyası yalnızca yeni model gerçekten yüklendikten sonra silinir.
      await _storage.deleteLegacyModel();

      if (!mounted) return;

      setState(() {
        _modelAvailable = true;
        _modelLoaded = true;
        _progress = 1;
        _status = 'Model indirildi ve belleğe yüklendi.';
      });
    } catch (error) {
      if (!mounted) return;

      // Preserve the real load error. Previously _refreshStatus() immediately
      // replaced it with the generic "model ready" status.
      var available = false;
      var loaded = false;
      try {
        available = await _storage.isModelAvailable();
        loaded = await widget.service.isModelLoaded;
      } catch (_) {
        // Keep the original error as the useful diagnostic.
      }
      if (!mounted) return;

      setState(() {
        _modelAvailable = available;
        _modelLoaded = loaded;
        _progress = null;
        _status = 'İşlem başarısız: $error';
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _loadExistingModel() async {
    if (_busy) return;

    setState(() {
      _busy = true;
      _status = 'Cihazdaki model yükleniyor.';
    });

    try {
      final path = await _storage.getModelPath();

      if (!await File(path).exists()) {
        throw FileSystemException('Model dosyası bulunamadı.', path);
      }

      await widget.service.loadModel(
        modelPath: path,
        threads: LocalModelConfig.threads,
        contextSize: LocalModelConfig.contextSize,
      );

      final loaded = await widget.service.isModelLoaded;
      if (!loaded) {
        throw StateError(
          'Native yükleme çağrısı tamamlandı ancak llama.cpp modeli yüklü göstermedi.',
        );
      }

      // Eski 1.7B dosyası yalnızca yeni model gerçekten yüklendikten sonra silinir.
      await _storage.deleteLegacyModel();

      if (!mounted) return;

      setState(() {
        _modelAvailable = true;
        _modelLoaded = true;
        _status = 'Model belleğe yüklendi.';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _status = 'Model yüklenemedi: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _modelLoaded
        ? Colors.greenAccent
        : _modelAvailable
            ? Colors.orangeAccent
            : Colors.white70;

    return Card(
      color: const Color(0xFF0A1722),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFF123A57)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.memory, color: Colors.cyanAccent),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'ARES Gömülü Yerel AI',
                    style: TextStyle(
                      color: Colors.cyanAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              LocalModelConfig.fileName,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 4),
            const Text(
              'İlk indirme için internet bağlantısı ve yaklaşık 430 MB boş alan gerekir. '
              'İndirildikten sonra model cihaz üzerinde çalışır.',
              style: TextStyle(color: Colors.white60, height: 1.4),
            ),
            const SizedBox(height: 12),
            Text(
              _status,
              style: TextStyle(color: statusColor),
            ),
            if (_busy && _progress != null) ...[
              const SizedBox(height: 10),
              LinearProgressIndicator(
                value: _progress,
                color: Colors.cyanAccent,
                backgroundColor: Colors.white12,
              ),
              const SizedBox(height: 4),
              Text(
                '${((_progress ?? 0) * 100).toStringAsFixed(1)}%',
                style: const TextStyle(color: Colors.white70),
              ),
            ] else if (_busy) ...[
              const SizedBox(height: 10),
              const LinearProgressIndicator(
                color: Colors.cyanAccent,
              ),
            ],
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: _busy || _modelLoaded
                      ? null
                      : _modelAvailable
                          ? _loadExistingModel
                          : _downloadAndLoad,
                  icon: Icon(
                    _modelAvailable ? Icons.play_arrow : Icons.download,
                  ),
                  label: Text(
                    _modelAvailable ? 'Modeli yükle' : 'İndir ve yükle',
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: _busy ? null : _refreshStatus,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Durumu yenile'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
