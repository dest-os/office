/// ARES yerel yapay zekâ modelinin yapılandırması.
class LocalModelConfig {
  LocalModelConfig._();

  /// Model deposu.
  static const String repository = 'ggml-org/Qwen3-0.6B-GGUF';

  /// İndirilecek GGUF dosyasının adı.
  static const String fileName = 'Qwen3-0.6B-Q4_0.gguf';

  /// Sabitlenmiş model sürümünün indirme adresi.
  static const String downloadUrl =
      'https://huggingface.co/ggml-org/Qwen3-0.6B-GGUF/resolve/main/Qwen3-0.6B-Q4_0.gguf';

  /// Beklenen dosya boyutu (bayt).
  // Hugging Face reports 429 MB; do not hard-code a rounded byte count.
  // The downloader still verifies HTTP length and the GGUF magic header.
  static const int expectedSizeBytes = 0;

  /// İlk yükleme testi için daha düşük kaynak kullanımı.
  static const int threads = 2;
  static const int contextSize = 256;

  /// Metin üretim ayarları.
  static const int maxTokens = 256;
  static const double temperature = 0.2;
}
