import '../../application/ai/ai_gateway.dart';
import '../../core/result/ares_result.dart';
import '../../domain/ai/ai_request.dart';
import '../../domain/ai/ai_response.dart';
import '../ai/local_model_config.dart';
import '../ai/local_model_service.dart';

/// ARES uygulamasının içine gömülü llama.cpp motoru için adaptör.
///
/// Ollama veya başka bir HTTP sunucusu gerektirmez.
/// Modelin önceden yüklenmiş olması gerekir.
class EmbeddedLocalAiGatewayAdapter implements AresAiGateway {
  EmbeddedLocalAiGatewayAdapter({
    required LocalModelService service,
  }) : _service = service;

  final LocalModelService _service;

  @override
  Future<AresResult<AiResponse>> generate(
    AiRequest request,
  ) async {
    try {
      final loaded = await _service.isModelLoaded;

      if (!loaded) {
        return const AresFailure<AiResponse>(
          'Yerel AI modeli henüz yüklenmedi. '
          'Önce model indirilip yüklenmelidir.',
        );
      }

      if (request.instruction.trim().isEmpty) {
        return const AresFailure<AiResponse>(
          'Yerel AI isteği boş olamaz.',
        );
      }

      final text = await _service.generateText(
        request.instruction,
        maxTokens: LocalModelConfig.maxTokens,
        temperature: LocalModelConfig.temperature,
      );

      if (text.trim().isEmpty) {
        return const AresFailure<AiResponse>(
          'Yerel AI boş cevap üretti.',
        );
      }

      return AresSuccess<AiResponse>(
        AiResponse(
          text: text,
          modelName: LocalModelConfig.fileName,
        ),
      );
    } catch (error) {
      return AresFailure<AiResponse>(
        'Gömülü yerel AI hatası: $error',
      );
    }
  }
}
