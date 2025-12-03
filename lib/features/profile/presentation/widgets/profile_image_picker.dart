import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:mobile_flutter/app/utils/app_logger.dart';
import 'package:mobile_flutter/core/di/service_locator.dart';

final _log = logger(ProfileImagePicker);

class ProfileImagePicker extends StatefulWidget {
  final String? imageUrl;
  final String userId;
  final double size;
  final Function(String) onImageSelected;

  const ProfileImagePicker({
    super.key,
    required this.userId,
    required this.onImageSelected,
    this.imageUrl,
    this.size = 120.0,
  });

  @override
  State<ProfileImagePicker> createState() => _ProfileImagePickerState();
}

class _ProfileImagePickerState extends State<ProfileImagePicker> {
  String? _localImagePath;
  final _storageService = ServiceLocator().storageService;

  @override
  void initState() {
    super.initState();
    _loadLocalImage();
  }

  Future<void> _loadLocalImage() async {
    _log.t('Carregando imagem local para user: ${widget.userId}');
    final localPath = await _storageService.getImageUrl('profile_${widget.userId}');
    if (mounted && localPath != null) {
      _log.d('Imagem local encontrada: $localPath');
      setState(() {
        _localImagePath = localPath;
      });
    }
  }

  Future<void> _pickImage() async {
    _log.i('Iniciando seleção de imagem...');
    try {
      final image = await _storageService.pickImage();
      
      if (image != null) {
        _log.d('Imagem selecionada: ${image.path}');
        try {
          // Salva a imagem localmente
          final savedPath = await _storageService.saveImage(
            image, 'profile_${widget.userId}.jpg',
          );
          _log.d('Imagem salva em: $savedPath');
          
          // Salva o caminho local
          await _storageService.saveImageUrl('profile_${widget.userId}', savedPath);
          _log.t('Caminho da imagem salvo no SharedPreferences');
          
          if (mounted) {
            setState(() {
              _localImagePath = savedPath;
            });
            _log.i('Imagem de perfil atualizada com sucesso');
            
            // Notifica o widget pai sobre a nova imagem
            widget.onImageSelected(savedPath);
          }
        } catch (e, st) {
          _log.e('Erro ao salvar a imagem', error: e, stackTrace: st);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Erro ao salvar a imagem')),
            );
          }
        }
      } else {
        _log.d('Nenhuma imagem selecionada');
      }
    } catch (e, st) {
      _log.e('Erro ao selecionar a imagem', error: e, stackTrace: st);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Container da imagem de perfil (sem GestureDetector aqui)
        Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: _buildImage(),
        ),
        // Ícone de câmera clicável
        Positioned(
          bottom: 0,
          right: 0,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: _pickImage,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.photo_camera, color: Colors.white, size: 20),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImage() {
    if (_localImagePath != null) {
      if (kIsWeb) {
        // Na web, usamos Image.network para URLs blob
        return ClipOval(
          child: Image.network(
            _localImagePath!,
            width: widget.size,
            height: widget.size,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
          ),
        );
      } else {
        // Em outras plataformas, usamos Image.file
        return ClipOval(
          child: Image.file(
            File(_localImagePath!),
            width: widget.size,
            height: widget.size,
            fit: BoxFit.cover,
          ),
        );
      }
    } else if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: widget.imageUrl!,
          width: widget.size,
          height: widget.size,
          fit: BoxFit.cover,
          placeholder: (context, url) => _buildPlaceholder(),
          errorWidget: (context, url, error) => _buildPlaceholder(),
        ),
      );
    } else {
      return _buildPlaceholder();
    }
  }

  Widget _buildPlaceholder() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person,
        size: widget.size * 0.6,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
