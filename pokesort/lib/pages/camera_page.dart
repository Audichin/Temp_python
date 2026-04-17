import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  List<CameraDescription> _cameras = [];
  int _selectedCameraIndex = 0;
  bool _capturing = false;
  String? _capturedImagePath;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (!mounted || cameras.isEmpty) return;

    _cameras = cameras;
    _selectedCameraIndex = _preferredCameraIndex(cameras);
    await _setActiveCamera(_selectedCameraIndex);
  }

  int _preferredCameraIndex(List<CameraDescription> cameras) {
    final backIndex = cameras.indexWhere(
      (camera) => camera.lensDirection == CameraLensDirection.back,
    );
    if (backIndex != -1) return backIndex;

    final frontIndex = cameras.indexWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
    );
    if (frontIndex != -1) return frontIndex;

    return 0;
  }

  Future<void> _setActiveCamera(int index) async {
    final previousController = _controller;
    final controller = CameraController(
      _cameras[index],
      ResolutionPreset.medium,
      enableAudio: false,
    );

    final initializeFuture = controller.initialize();

    setState(() {
      _selectedCameraIndex = index;
      _controller = controller;
      _initializeControllerFuture = initializeFuture;
    });

    await previousController?.dispose();
    await initializeFuture;

    if (!mounted) {
      await controller.dispose();
      return;
    }

    setState(() {});
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;
    final nextIndex = (_selectedCameraIndex + 1) % _cameras.length;
    await _setActiveCamera(nextIndex);
  }

  String _cameraLabel() {
    if (_cameras.isEmpty) return 'Camera';

    switch (_cameras[_selectedCameraIndex].lensDirection) {
      case CameraLensDirection.front:
        return 'Front Camera';
      case CameraLensDirection.back:
        return 'Back Camera';
      case CameraLensDirection.external:
        return 'External Camera';
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _capture() async {
    try {
      if (_controller == null || _initializeControllerFuture == null) return;
      if (_capturing) return;

      setState(() {
        _capturing = true;
      });
      await _initializeControllerFuture!;

      final image = await _controller!.takePicture();

      if (!mounted) return;

      setState(() {
        _capturedImagePath = image.path;
        _capturing = false;
      });
    } catch (e) {
      debugPrint('$e');
      if (mounted) {
        setState(() {
          _capturing = false;
        });
      }
    }
  }

  void _retakePhoto() {
    setState(() {
      _capturedImagePath = null;
      _capturing = false;
    });
  }

  void _useCapturedPhoto() {
    final imagePath = _capturedImagePath;
    if (imagePath == null) return;

    Navigator.pop(context, imagePath);
  }

  Widget _buildPreview() {
    final controllerAspectRatio = _controller!.value.aspectRatio;
    if (controllerAspectRatio == 0) {
      return const Center(child: CircularProgressIndicator());
    }

    // The camera plugin reports aspect ratio in the sensor's native
    // landscape orientation. Inverting it produces the portrait framing
    // users expect on a phone camera screen.
    final previewAspectRatio = 1 / controllerAspectRatio;

    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: ColoredBox(
          color: Colors.black,
          child: AspectRatio(
            aspectRatio: previewAspectRatio,
            child: CameraPreview(_controller!),
          ),
        ),
      ),
    );
  }

  Widget _buildCapturedPhotoReview() {
    final imagePath = _capturedImagePath;
    if (imagePath == null) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        Expanded(
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.file(
                File(imagePath),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _useCapturedPhoto,
          icon: const Icon(Icons.check_circle_outline),
          label: const Text('Use Photo'),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: _retakePhoto,
          icon: const Icon(Icons.refresh),
          label: const Text('Retake Photo'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || _initializeControllerFuture == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Take Picture'),
        actions: [
          if (_cameras.length > 1)
            IconButton(
              tooltip: 'Switch camera',
              onPressed: _switchCamera,
              icon: const Icon(Icons.flip_camera_android),
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Column(
              children: [
                Expanded(
                  child: _capturedImagePath != null
                      ? _buildCapturedPhotoReview()
                      : FutureBuilder<void>(
                          future: _initializeControllerFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              return _buildPreview();
                            }

                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 16),
                if (_capturedImagePath == null) ...[
                  Center(
                    child: Text(
                      _cameraLabel(),
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_cameras.length > 1)
                        Padding(
                          padding: const EdgeInsets.only(right: 24),
                          child: IconButton.filledTonal(
                            tooltip: 'Switch camera',
                            onPressed: _switchCamera,
                            icon: const Icon(Icons.cameraswitch_outlined),
                          ),
                        ),
                      GestureDetector(
                        onTap: _capturing ? null : _capture,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 150),
                          opacity: _capturing ? 0.6 : 1,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: const BoxDecoration(
                              color: Colors.black,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(5),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: _capturing
                                  ? const Padding(
                                      padding: EdgeInsets.all(22),
                                      child: CircularProgressIndicator(
                                        strokeWidth: 3,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
