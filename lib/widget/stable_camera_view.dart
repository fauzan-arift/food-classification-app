import 'dart:developer';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class StableCameraView extends StatefulWidget {
  final Function(File imageFile)? onImageCaptured;
  final Function(CameraImage cameraImage)? onImageStream;
  final Widget? overlayWidget;
  final bool useImageStream;

  const StableCameraView({
    super.key,
    this.onImageCaptured,
    this.onImageStream,
    this.overlayWidget,
    this.useImageStream = false,
  });

  @override
  State<StableCameraView> createState() => _StableCameraViewState();
}

class _StableCameraViewState extends State<StableCameraView>
    with WidgetsBindingObserver {
  bool _isCameraInitialized = false;
  List<CameraDescription> _cameras = [];
  CameraController? _controller;
  bool _isProcessing = false;
  bool _isTakingPicture = false;
  int _selectedCameraIndex = 0;
  FlashMode _flashMode = FlashMode.off;

  Future<void> _initCamera() async {
    try {
      if (_cameras.isEmpty) {
        _cameras = await availableCameras();
      }

      if (_cameras.isNotEmpty) {
        await _setupCameraController(_cameras[_selectedCameraIndex]);
      }
    } catch (e) {
      log('Error initializing camera: $e');
    }
  }

  Future<void> _setupCameraController(CameraDescription description) async {
    await _controller?.dispose();

    _controller = CameraController(
      description,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.jpeg
          : ImageFormatGroup.bgra8888,
    );

    try {
      await _controller!.initialize();
      await _controller!.setFlashMode(_flashMode);

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });

        if (widget.useImageStream && widget.onImageStream != null) {
          _controller!.startImageStream(_processCameraImage);
        }
      }
    } catch (e) {
      log('Error setting up camera controller: $e');
    }
  }

  void _processCameraImage(CameraImage image) async {
    if (_isProcessing || widget.onImageStream == null) {
      return;
    }

    _isProcessing = true;
    try {
      await widget.onImageStream!(image);
    } catch (e) {
      log('Error processing camera image: $e');
    } finally {
      _isProcessing = false;
    }
  }

  Future<void> _takePicture() async {
    if (!_isCameraInitialized ||
        _controller == null ||
        _isTakingPicture ||
        widget.onImageCaptured == null) {
      return;
    }

    setState(() {
      _isTakingPicture = true;
    });

    try {
      // Stop image stream if running
      if (widget.useImageStream) {
        await _controller!.stopImageStream();
      }

      final XFile picture = await _controller!.takePicture();
      final File imageFile = File(picture.path);

      widget.onImageCaptured!(imageFile);

      // Restart image stream if it was running
      if (widget.useImageStream && widget.onImageStream != null) {
        await Future.delayed(const Duration(milliseconds: 100));
        if (_controller != null && _controller!.value.isInitialized) {
          _controller!.startImageStream(_processCameraImage);
        }
      }
    } catch (e) {
      log('Error taking picture: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isTakingPicture = false;
        });
      }
    }
  }

  Future<void> _toggleFlash() async {
    if (!_isCameraInitialized || _controller == null) return;

    try {
      switch (_flashMode) {
        case FlashMode.off:
          _flashMode = FlashMode.auto;
          break;
        case FlashMode.auto:
          _flashMode = FlashMode.always;
          break;
        case FlashMode.always:
          _flashMode = FlashMode.off;
          break;
        default:
          _flashMode = FlashMode.off;
      }

      await _controller!.setFlashMode(_flashMode);

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      log('Error toggling flash: $e');
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length <= 1) return;

    setState(() {
      _isCameraInitialized = false;
    });

    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    await _setupCameraController(_cameras[_selectedCameraIndex]);
  }

  IconData _getFlashIcon() {
    switch (_flashMode) {
      case FlashMode.off:
        return Icons.flash_off;
      case FlashMode.auto:
        return Icons.flash_auto;
      case FlashMode.always:
        return Icons.flash_on;
      default:
        return Icons.flash_off;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeCamera();
    super.dispose();
  }

  Future<void> _disposeCamera() async {
    if (_controller != null) {
      try {
        // Stop image stream first
        if (widget.useImageStream) {
          await _controller!.stopImageStream();
        }

        // Set flash to off before disposing
        if (_controller!.value.isInitialized) {
          await _controller!.setFlashMode(FlashMode.off);
        }

        await _controller!.dispose();
      } catch (e) {
        log('Error disposing camera: $e');
      }
      _controller = null;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    switch (state) {
      case AppLifecycleState.inactive:
        _disposeCamera();
        break;
      case AppLifecycleState.resumed:
        _initCamera();
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          SizedBox.expand(child: CameraPreview(_controller!)),

          if (widget.overlayWidget != null) widget.overlayWidget!,

          if (!widget.useImageStream)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: _toggleFlash,
                      icon: Icon(
                        _getFlashIcon(),
                        color: Colors.white,
                        size: 32,
                      ),
                    ),

                    GestureDetector(
                      onTap: _isTakingPicture ? null : _takePicture,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          color: _isTakingPicture
                              ? Colors.grey
                              : Colors.transparent,
                        ),
                        child: _isTakingPicture
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 40,
                              ),
                      ),
                    ),

                    IconButton(
                      onPressed: _cameras.length > 1 ? _switchCamera : null,
                      icon: Icon(
                        Icons.flip_camera_ios,
                        color: _cameras.length > 1 ? Colors.white : Colors.grey,
                        size: 32,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
