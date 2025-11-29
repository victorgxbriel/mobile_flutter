import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

abstract class StorageService {
  Future<File?> pickImage();
  Future<String> saveImage(File image, String fileName);
  Future<String?> getImageUrl(String key);
  Future<void> saveImageUrl(String key, String url);
  Future<void> deleteImage(String key);
}

class StorageServiceImpl implements StorageService {
  final ImagePicker _picker = ImagePicker();
  final SharedPreferences _prefs;

  StorageServiceImpl(this._prefs);

  @override
  Future<File?> pickImage() async {
    try {
      if (kIsWeb) {
        // Para web, usamos o image_picker diretamente
        final XFile? image = await ImagePicker().pickImage(
          source: ImageSource.gallery,
          imageQuality: 85,
        );
        return image != null ? File(image.path) : null;
      } else {
        // Para mobile/desktop, usamos o file_picker
        final result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: false,
        );
        if (result == null || result.files.isEmpty) return null;
        return File(result.files.single.path!);
      }
    } catch (e) {
      print('Erro ao selecionar imagem: $e');
      return null;
    }
  }

  @override
  Future<String> saveImage(File image, String fileName) async {
    try {
      print('1. Iniciando salvamento da imagem...');
      print('2. Caminho da imagem original: ${image.path}');
      print('3. Nome do arquivo para salvar: $fileName');

      if (kIsWeb) {
        // Para web, armazenamos apenas a URL da imagem
        print('4.1. Modo web: Armazenando URL da imagem');
        final imageUrl = image.path;
        await saveImageUrl('profile_$fileName', imageUrl);
        return imageUrl;
      } else {
        // Para mobile/desktop, salvamos o arquivo no sistema de arquivos
        print('4.2. Modo mobile/desktop: Salvando arquivo...');
        
        // Verifica se o arquivo de origem existe
        if (!await image.exists()) {
          throw Exception('Arquivo de origem não existe: ${image.path}');
        }

        // Obtém o diretório de documentos
        final directory = await getApplicationDocumentsDirectory();
        print('5. Diretório de documentos: ${directory.path}');
        
        // Cria o caminho completo do arquivo
        final String filePath = path.join(directory.path, fileName);
        print('6. Caminho completo do arquivo: $filePath');
        
        // Verifica se o arquivo já existe e remove
        final targetFile = File(filePath);
        if (await targetFile.exists()) {
          print('7. Arquivo de destino já existe, removendo...');
          await targetFile.delete();
        }
        
        // Copia o arquivo para o diretório do aplicativo
        print('8. Copiando arquivo...');
        final File savedImage = await image.copy(filePath);
        print('9. Arquivo salvo com sucesso em: ${savedImage.path}');
        
        // Salva o caminho local
        await saveImageUrl('profile_$fileName', savedImage.path);
        return savedImage.path;
      }
    } catch (e) {
      print('Erro ao salvar imagem: $e');
      print('Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  @override
  Future<String?> getImageUrl(String key) async {
    return _prefs.getString(key);
  }

  @override
  Future<void> saveImageUrl(String key, String url) async {
    await _prefs.setString(key, url);
  }

  @override
  Future<void> deleteImage(String key) async {
    await _prefs.remove(key);
  }
}
