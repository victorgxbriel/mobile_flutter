import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:mobile_flutter/core/di/service_locator.dart';

class ProfileImagePicker extends StatefulWidget {
  final String? imageUrl;
  final String userId;
  final double size;
  final Function(String) onImageSelected;

  const ProfileImagePicker({
    Key? key,
    required this.userId,
    required this.onImageSelected,
    this.imageUrl,
    this.size = 120.0,
  }) : super(key: key);

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
    final localPath = await _storageService.getImageUrl('profile_${widget.userId}');
    if (mounted && localPath != null) {
      setState(() {
        _localImagePath = localPath;
      });
    }
  }

  Future<void> _pickImage() async {
    print('1. Iniciando seleção de imagem...');
    try {
      final image = await _storageService.pickImage();
      print('2. Imagem selecionada: ${image?.path ?? "Nenhuma imagem selecionada"}');
      
      if (image != null) {
        print('3. Tentando salvar a imagem...');
        try {
          // Salva a imagem localmente
          final savedPath = await _storageService.saveImage(
            image,
            'profile_${widget.userId}.jpg',
          );
          print('4. Imagem salva em: $savedPath');
          
          // Salva o caminho local
          await _storageService.saveImageUrl('profile_${widget.userId}', savedPath);
          print('5. Caminho da imagem salvo no SharedPreferences');
          
          if (mounted) {
            setState(() {
              _localImagePath = savedPath;
            });
            print('6. Estado atualizado com o novo caminho da imagem');
            
            // Notifica o widget pai sobre a nova imagem
            widget.onImageSelected(savedPath);
            print('7. Widget pai notificado sobre a nova imagem');
          }
        } catch (e) {
          print('Erro ao salvar a imagem: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Erro ao salvar a imagem')),
            );
          }
        }
      }
    } catch (e) {
      print('Erro ao selecionar a imagem: $e');
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
