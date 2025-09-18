# Supabase Storage Setup

Comprehensive guide to setting up and using Supabase Storage for file uploads, downloads, and management in Flutter applications.

## Overview

Supabase Storage provides a scalable file storage solution with built-in security, image transformations, and CDN delivery. This guide covers setup, configuration, and implementation patterns.

## Storage Configuration

### 1. Bucket Setup

```sql
-- Create storage buckets
INSERT INTO storage.buckets (id, name, public) VALUES 
  ('avatars', 'avatars', true),
  ('posts', 'posts', true),
  ('private-files', 'private-files', false);

-- Set up Row Level Security policies
CREATE POLICY "Avatar images are publicly accessible" ON storage.objects
  FOR SELECT USING (bucket_id = 'avatars');

CREATE POLICY "Users can upload their own avatar" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'avatars' 
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "Users can update their own avatar" ON storage.objects
  FOR UPDATE USING (
    bucket_id = 'avatars' 
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "Users can delete their own avatar" ON storage.objects
  FOR DELETE USING (
    bucket_id = 'avatars' 
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

-- Post images policies
CREATE POLICY "Post images are publicly accessible" ON storage.objects
  FOR SELECT USING (bucket_id = 'posts');

CREATE POLICY "Authenticated users can upload post images" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'posts' 
    AND auth.role() = 'authenticated'
  );

-- Private files policies
CREATE POLICY "Users can access their own private files" ON storage.objects
  FOR ALL USING (
    bucket_id = 'private-files' 
    AND auth.uid()::text = (storage.foldername(name))[1]
  );
```

### 2. Storage Service Implementation

```dart
// lib/services/storage_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class StorageService {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  // Upload avatar image
  Future<String> uploadAvatar(File imageFile, String userId) async {
    try {
      final fileExt = path.extension(imageFile.path);
      final fileName = '$userId/avatar$fileExt';
      
      await _supabase.storage
          .from('avatars')
          .upload(fileName, imageFile, fileOptions: const FileOptions(
            cacheControl: '3600',
            upsert: true,
          ));
      
      return _supabase.storage
          .from('avatars')
          .getPublicUrl(fileName);
    } catch (error) {
      throw StorageException('Failed to upload avatar: $error');
    }
  }
  
  // Upload post image
  Future<String> uploadPostImage(File imageFile) async {
    try {
      final fileExt = path.extension(imageFile.path);
      final fileName = '${DateTime.now().millisecondsSinceEpoch}$fileExt';
      final userId = _supabase.auth.currentUser?.id;
      
      if (userId == null) throw Exception('User not authenticated');
      
      final filePath = '$userId/$fileName';
      
      await _supabase.storage
          .from('posts')
          .upload(filePath, imageFile, fileOptions: const FileOptions(
            cacheControl: '3600',
          ));
      
      return _supabase.storage
          .from('posts')
          .getPublicUrl(filePath);
    } catch (error) {
      throw StorageException('Failed to upload post image: $error');
    }
  }
  
  // Upload multiple images
  Future<List<String>> uploadMultipleImages(List<File> imageFiles, String folder) async {
    final uploadTasks = imageFiles.map((file) => uploadPostImage(file));
    return await Future.wait(uploadTasks);
  }
  
  // Download file
  Future<Uint8List> downloadFile(String bucket, String path) async {
    try {
      return await _supabase.storage
          .from(bucket)
          .download(path);
    } catch (error) {
      throw StorageException('Failed to download file: $error');
    }
  }
  
  // Delete file
  Future<void> deleteFile(String bucket, String path) async {
    try {
      await _supabase.storage
          .from(bucket)
          .remove([path]);
    } catch (error) {
      throw StorageException('Failed to delete file: $error');
    }
  }
  
  // Get file URL with transformations
  String getImageUrl(String bucket, String path, {
    int? width,
    int? height,
    String? format,
    int? quality,
  }) {
    var url = _supabase.storage.from(bucket).getPublicUrl(path);
    
    final transformations = <String>[];
    
    if (width != null) transformations.add('width=$width');
    if (height != null) transformations.add('height=$height');
    if (format != null) transformations.add('format=$format');
    if (quality != null) transformations.add('quality=$quality');
    
    if (transformations.isNotEmpty) {
      url += '?${transformations.join('&')}';
    }
    
    return url;
  }
  
  // List files in bucket
  Future<List<FileObject>> listFiles(String bucket, {String? folder}) async {
    try {
      return await _supabase.storage
          .from(bucket)
          .list(path: folder);
    } catch (error) {
      throw StorageException('Failed to list files: $error');
    }
  }
}

class StorageException implements Exception {
  final String message;
  StorageException(this.message);
  
  @override
  String toString() => 'StorageException: $message';
}
```

## Image Upload Components

### 1. Image Picker Widget

```dart
// lib/widgets/image_picker_widget.dart
class ImagePickerWidget extends StatefulWidget {
  final Function(File) onImageSelected;
  final String? initialImageUrl;
  final double size;
  final bool isCircular;
  
  const ImagePickerWidget({
    Key? key,
    required this.onImageSelected,
    this.initialImageUrl,
    this.size = 100,
    this.isCircular = false,
  }) : super(key: key);
  
  @override
  _ImagePickerWidgetState createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showImageSourceDialog,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: widget.isCircular ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: widget.isCircular ? null : BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
          color: Colors.grey[100],
        ),
        child: _buildImageContent(),
      ),
    );
  }
  
  Widget _buildImageContent() {
    if (_selectedImage != null) {
      return ClipRRect(
        borderRadius: widget.isCircular 
            ? BorderRadius.circular(widget.size / 2)
            : BorderRadius.circular(8),
        child: Image.file(
          _selectedImage!,
          width: widget.size,
          height: widget.size,
          fit: BoxFit.cover,
        ),
      );
    }
    
    if (widget.initialImageUrl != null) {
      return ClipRRect(
        borderRadius: widget.isCircular 
            ? BorderRadius.circular(widget.size / 2)
            : BorderRadius.circular(8),
        child: Image.network(
          widget.initialImageUrl!,
          width: widget.size,
          height: widget.size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildPlaceholder();
          },
        ),
      );
    }
    
    return _buildPlaceholder();
  }
  
  Widget _buildPlaceholder() {
    return Icon(
      Icons.add_photo_alternate,
      size: widget.size * 0.4,
      color: Colors.grey[400],
    );
  }
  
  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            if (_selectedImage != null || widget.initialImageUrl != null)
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Remove'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _selectedImage = null;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        final file = File(image.path);
        setState(() {
          _selectedImage = file;
        });
        widget.onImageSelected(file);
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $error')),
      );
    }
  }
}
```

### 2. Multiple Image Picker

```dart
// lib/widgets/multiple_image_picker.dart
class MultipleImagePicker extends StatefulWidget {
  final Function(List<File>) onImagesSelected;
  final int maxImages;
  final List<String>? initialImageUrls;
  
  const MultipleImagePicker({
    Key? key,
    required this.onImagesSelected,
    this.maxImages = 5,
    this.initialImageUrls,
  }) : super(key: key);
  
  @override
  _MultipleImagePickerState createState() => _MultipleImagePickerState();
}

class _MultipleImagePickerState extends State<MultipleImagePicker> {
  List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Images (${_selectedImages.length}/${widget.maxImages})',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _selectedImages.length + 1,
            itemBuilder: (context, index) {
              if (index == _selectedImages.length) {
                return _buildAddButton();
              }
              return _buildImageItem(index);
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildAddButton() {
    if (_selectedImages.length >= widget.maxImages) {
      return const SizedBox.shrink();
    }
    
    return GestureDetector(
      onTap: _pickImages,
      child: Container(
        width: 100,
        height: 100,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey[100],
        ),
        child: Icon(
          Icons.add_photo_alternate,
          size: 40,
          color: Colors.grey[400],
        ),
      ),
    );
  }
  
  Widget _buildImageItem(int index) {
    return Container(
      width: 100,
      height: 100,
      margin: const EdgeInsets.only(right: 8),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              _selectedImages[index],
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => _removeImage(index),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      final remainingSlots = widget.maxImages - _selectedImages.length;
      final imagesToAdd = images.take(remainingSlots);
      
      final newFiles = imagesToAdd.map((image) => File(image.path)).toList();
      
      setState(() {
        _selectedImages.addAll(newFiles);
      });
      
      widget.onImagesSelected(_selectedImages);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick images: $error')),
      );
    }
  }
  
  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
    widget.onImagesSelected(_selectedImages);
  }
}
```

## Upload Progress and Management

### 1. Upload Progress Widget

```dart
// lib/widgets/upload_progress_widget.dart
class UploadProgressWidget extends StatefulWidget {
  final File file;
  final String bucket;
  final Function(String) onUploadComplete;
  final Function(String) onUploadError;
  
  const UploadProgressWidget({
    Key? key,
    required this.file,
    required this.bucket,
    required this.onUploadComplete,
    required this.onUploadError,
  }) : super(key: key);
  
  @override
  _UploadProgressWidgetState createState() => _UploadProgressWidgetState();
}

class _UploadProgressWidgetState extends State<UploadProgressWidget> {
  double _progress = 0.0;
  bool _isUploading = false;
  String? _error;
  
  @override
  void initState() {
    super.initState();
    _startUpload();
  }
  
  Future<void> _startUpload() async {
    setState(() {
      _isUploading = true;
      _error = null;
    });
    
    try {
      final storageService = GetIt.instance<StorageService>();
      
      // Simulate progress updates
      for (int i = 0; i <= 100; i += 10) {
        await Future.delayed(const Duration(milliseconds: 100));
        if (mounted) {
          setState(() {
            _progress = i / 100;
          });
        }
      }
      
      final url = await storageService.uploadPostImage(widget.file);
      
      setState(() {
        _isUploading = false;
        _progress = 1.0;
      });
      
      widget.onUploadComplete(url);
    } catch (error) {
      setState(() {
        _isUploading = false;
        _error = error.toString();
      });
      
      widget.onUploadError(error.toString());
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.file(
                  widget.file,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      path.basename(widget.file.path),
                      style: const TextStyle(fontWeight: FontWeight.medium),
                    ),
                    const SizedBox(height: 4),
                    if (_error != null)
                      Text(
                        _error!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      )
                    else if (_isUploading)
                      Text(
                        'Uploading... ${(_progress * 100).toInt()}%',
                        style: const TextStyle(fontSize: 12),
                      )
                    else
                      const Text(
                        'Upload complete',
                        style: TextStyle(color: Colors.green, fontSize: 12),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (_isUploading) ...[
            const SizedBox(height: 8),
            LinearProgressIndicator(value: _progress),
          ],
        ],
      ),
    );
  }
}
```

### 2. Upload Manager Service

```dart
// lib/services/upload_manager.dart
class UploadManager {
  final Map<String, UploadTask> _activeTasks = {};
  final StreamController<Map<String, UploadTask>> _controller = 
      StreamController<Map<String, UploadTask>>.broadcast();
  
  Stream<Map<String, UploadTask>> get tasksStream => _controller.stream;
  
  String startUpload(File file, String bucket, {String? folder}) {
    final taskId = DateTime.now().millisecondsSinceEpoch.toString();
    final task = UploadTask(
      id: taskId,
      file: file,
      bucket: bucket,
      folder: folder,
    );
    
    _activeTasks[taskId] = task;
    _controller.add(Map.from(_activeTasks));
    
    _performUpload(task);
    
    return taskId;
  }
  
  Future<void> _performUpload(UploadTask task) async {
    try {
      task.status = UploadStatus.uploading;
      _controller.add(Map.from(_activeTasks));
      
      final storageService = GetIt.instance<StorageService>();
      final url = await storageService.uploadPostImage(task.file);
      
      task.status = UploadStatus.completed;
      task.url = url;
      task.progress = 1.0;
      
    } catch (error) {
      task.status = UploadStatus.failed;
      task.error = error.toString();
    }
    
    _controller.add(Map.from(_activeTasks));
    
    // Remove completed/failed tasks after delay
    Timer(const Duration(seconds: 3), () {
      _activeTasks.remove(task.id);
      _controller.add(Map.from(_activeTasks));
    });
  }
  
  void cancelUpload(String taskId) {
    final task = _activeTasks[taskId];
    if (task != null) {
      task.status = UploadStatus.cancelled;
      _activeTasks.remove(taskId);
      _controller.add(Map.from(_activeTasks));
    }
  }
  
  void dispose() {
    _controller.close();
  }
}

class UploadTask {
  final String id;
  final File file;
  final String bucket;
  final String? folder;
  
  UploadStatus status = UploadStatus.pending;
  double progress = 0.0;
  String? url;
  String? error;
  
  UploadTask({
    required this.id,
    required this.file,
    required this.bucket,
    this.folder,
  });
}

enum UploadStatus {
  pending,
  uploading,
  completed,
  failed,
  cancelled,
}
```

## Image Optimization

### 1. Image Compression

```dart
// lib/utils/image_utils.dart
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ImageUtils {
  static Future<File?> compressImage(File file, {
    int quality = 85,
    int maxWidth = 1024,
    int maxHeight = 1024,
  }) async {
    try {
      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        '${file.path}_compressed.jpg',
        quality: quality,
        minWidth: maxWidth,
        minHeight: maxHeight,
        format: CompressFormat.jpeg,
      );
      
      return compressedFile != null ? File(compressedFile.path) : null;
    } catch (error) {
      print('Image compression failed: $error');
      return file; // Return original if compression fails
    }
  }
  
  static Future<Uint8List?> resizeImage(Uint8List imageBytes, {
    int? width,
    int? height,
  }) async {
    try {
      return await FlutterImageCompress.compressWithList(
        imageBytes,
        minWidth: width ?? 300,
        minHeight: height ?? 300,
        quality: 85,
      );
    } catch (error) {
      print('Image resize failed: $error');
      return imageBytes;
    }
  }
}
```

Supabase Storage provides a robust file management solution. Implement proper security policies, optimize images before upload, and provide clear feedback during upload processes.
