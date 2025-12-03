import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/utils/app_logger.dart';

final _log = detailLogger(StorageServiceImpl);

abstract class StorageService {
  Future<File?> pickImage();
  Future<String> saveImage(File image, String fileName);
  Future<String?> getImageUrl(String key);
  Future<void> saveImageUrl(String key, String url);
  Future<void> deleteImage(String key);
}

class StorageServiceImpl implements StorageService {
final SharedPreferences _prefs;

  StorageServiceImpl(this._prefs);

  @override
  Future<File?> pickImage() async {
    _log.d('Iniciando seleção de imagem...');
    try {
      if (kIsWeb) {
        // Para web, usamos o file_picker que funciona melhor
        final result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: false,
        );
        if (result == null || result.files.isEmpty) {
          _log.w('Nenhuma imagem selecionada pelo usuário');
          return null;
        }
        _log.i('Imagem selecionada (web): ${result.files.single.name}');
        return File(result.files.single.path!);
      } else {
        // Para mobile/desktop, usamos o file_picker
        final result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: false,
        );
        if (result == null || result.files.isEmpty) {
          _log.w('Nenhuma imagem selecionada pelo usuário');
          return null;
        }
        _log.i('Imagem selecionada: ${result.files.single.path}');
        return File(result.files.single.path!);
      }
    } catch (e, stackTrace) {
      _log.e('Erro ao selecionar imagem', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  @override
  Future<String> saveImage(File image, String fileName) async {
    _log.d('Salvando imagem: $fileName');
    _log.t('Caminho original: ${image.path}');
    
    try {
      if (kIsWeb) {
        // Para web, armazenamos apenas a URL da imagem
        _log.d('Modo web: Armazenando URL da imagem');
        final imageUrl = image.path;
        await saveImageUrl('profile_$fileName', imageUrl);
        _log.i('Imagem salva (web) com sucesso');
        return imageUrl;
      } else {
        // Para mobile/desktop, salvamos o arquivo no sistema de arquivos
        _log.d('Modo mobile/desktop: Salvando arquivo...');
        
        // Verifica se o arquivo de origem existe
        if (!await image.exists()) {
          _log.e('Arquivo de origem não existe: ${image.path}');
          throw Exception('Arquivo de origem não existe: ${image.path}');
        }

        // Obtém o diretório de documentos
        final directory = await getApplicationDocumentsDirectory();
        _log.t('Diretório de documentos: ${directory.path}');
        
        // Cria o caminho completo do arquivo
        final String filePath = path.join(directory.path, fileName);
        _log.t('Caminho de destino: $filePath');
        
        // Verifica se o arquivo já existe e remove
        final targetFile = File(filePath);
        if (await targetFile.exists()) {
          _log.d('Arquivo de destino já existe, removendo...');
          await targetFile.delete();
        }
        
        // Copia o arquivo para o diretório do aplicativo
        _log.d('Copiando arquivo...');
        final File savedImage = await image.copy(filePath);
        _log.i('Imagem salva com sucesso: ${savedImage.path}');
        
        // Salva o caminho local
        await saveImageUrl('profile_$fileName', savedImage.path);
        return savedImage.path;
      }
    } catch (e, stackTrace) {
      _log.e('Erro ao salvar imagem', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<String?> getImageUrl(String key) async {
    final url = _prefs.getString(key);
    _log.t('getImageUrl($key): ${url != null ? "encontrado" : "não encontrado"}');
    return url;
  }

  @override
  Future<void> saveImageUrl(String key, String url) async {
    await _prefs.setString(key, url);
    _log.t('saveImageUrl($key): URL salva');
  }

  @override
  Future<void> deleteImage(String key) async {
    await _prefs.remove(key);
    _log.d('deleteImage($key): Imagem removida');
  }
}
