import 'package:yominero/shared/models/response.dart';

/// Repositorio para gestionar respuestas a posts
abstract class ResponseRepository {
  /// Obtener todas las respuestas de un post
  Future<List<Response>> getResponsesForPost(String postId);

  /// Crear una nueva respuesta
  Future<Response> createResponse({
    required String postId,
    required String content,
    String? parentResponseId,
  });

  /// Editar una respuesta existente
  Future<Response> updateResponse({
    required String responseId,
    required String content,
  });

  /// Eliminar una respuesta
  Future<void> deleteResponse(String responseId);

  /// Dar like a una respuesta
  Future<void> likeResponse(String responseId);

  /// Quitar like de una respuesta
  Future<void> unlikeResponse(String responseId);

  /// Marcar respuesta como mejor respuesta (solo el autor del post)
  Future<void> markAsBestAnswer({
    required String responseId,
    required String postId,
  });

  /// Crear una respuesta anidada (respuesta a otra respuesta)
  Future<Response> createNestedResponse({
    required String postId,
    required String parentResponseId,
    required String content,
  });
}
