import 'dart:io';
import 'package:file_selector/file_selector.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart'; // Para debugPrint

class ImagePickerService {
  /// Abre el selector de archivos nativo, copia la imagen seleccionada 
  /// a la carpeta de documentos de la app y retorna la nueva ruta absoluta.
  static Future<String?> selectAndSaveImage() async {
    const XTypeGroup typeGroup = XTypeGroup(
      label: 'images',
      extensions: <String>['jpg', 'png', 'jpeg'],
      uniformTypeIdentifiers: <String>['public.jpg', 'public.png', 'public.jpeg'],
    );

    // 1. Abrir ventana nativa (funciona perfecto en macOS/Win/Linux)
    final XFile? file = await openFile(
      acceptedTypeGroups: <XTypeGroup>[typeGroup],
    );

    if (file == null) {
      return null; // Usuario canceló
    }

    try {
      // 2. Obtener directorio de la app
      final appDir = await getApplicationDocumentsDirectory();
      
      // 3. Crear carpeta específica si no existe
      final String folderPath = path.join(appDir.path, 'product_images');
      final Directory folderDir = Directory(folderPath);
      if (!await folderDir.exists()) {
        await folderDir.create(recursive: true);
      }

      // 4. Generar nombre único con Timestamp
      final String fileName = path.basename(file.path);
      final String uniqueName = '${DateTime.now().millisecondsSinceEpoch}_$fileName';
      final String savedImagePath = path.join(folderPath, uniqueName);

      // 5. Guardar (copiar) el archivo
      // file_selector devuelve un XFile, usamos saveTo para moverlo/copiarlo
      await file.saveTo(savedImagePath);

      return savedImagePath; // Éxito: Retornamos la ruta final

    } catch (e) {
      debugPrint('Error en ImagePickerService: $e');
      return null; // Fallo
    }
  }
}