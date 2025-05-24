import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:naturechime/screens/library_screen.dart';
import 'package:naturechime/widgets/recording_list_item.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:naturechime/models/recording_model.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isRecording = false;
  bool _isLoading = false;
  late AudioRecorder _audioRecorder;
  String? _currentRecordingPath;
  Timer? _timer;
  int _recordingDurationSeconds = 0;
  String _formattedTime = '00:00';
  CloudinaryPublic? _cloudinary;

  // Placeholder data for recordings
  // Replace with actual data fetching logic
  final List<Map<String, dynamic>> _sampleRecordings = [
    {
      'title': 'Morning Birds Chirping',
      'dateTime': DateTime.now().subtract(const Duration(hours: 2)),
      'durationSeconds': 105, // 1 minute 45 seconds
      'location': 'Central Park, NYC',
    },
    {
      'title': 'Rainforest Ambience',
      'dateTime': DateTime.now().subtract(const Duration(days: 1, hours: 5)),
      'durationSeconds': 300, // 5 minutes
      'location': 'Amazon Rainforest',
    },
    {
      'title': 'Ocean Waves Sound',
      'dateTime': DateTime.now().subtract(const Duration(days: 3)),
      'durationSeconds': 180, // 3 minutes
      // 'location': null, // Example with no location
    },
  ];

  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder();
    _initializeCloudinary();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  String _formatDuration(int totalSeconds) {
    final duration = Duration(seconds: totalSeconds);
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  Future<void> _initializeCloudinary() async {
    final String? cloudNameFromEnv = dotenv.env['CLOUDINARY_CLOUD_NAME'];
    final String? uploadPresetFromEnv = dotenv.env['CLOUDINARY_UPLOAD_PRESET'];

    if (cloudNameFromEnv != null &&
        cloudNameFromEnv.isNotEmpty &&
        uploadPresetFromEnv != null &&
        uploadPresetFromEnv.isNotEmpty) {
      try {
        _cloudinary = CloudinaryPublic(cloudNameFromEnv, uploadPresetFromEnv, cache: false);
      } catch (e) {
        debugPrint("Error initializing Cloudinary: $e");
        _cloudinary = null;
      }
    }
  }

  Future<bool> _checkPermission() async {
    try {
      var status = await Permission.microphone.status;
      if (!status.isGranted) {
        status = await Permission.microphone.request();
      }
      return status.isGranted;
    } catch (e) {
      debugPrint("Error checking/requesting permission: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error with microphone permissions: $e')),
        );
      }
      return false;
    }
  }

  void _startTimer() {
    _recordingDurationSeconds = 0;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _recordingDurationSeconds++;
          _formattedTime = _formatDuration(_recordingDurationSeconds);
        });
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  Future<void> _startRecording() async {
    final hasPermission = await _checkPermission();
    if (!hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission is required to record audio.')),
        );
      }
      return;
    }

    try {
      final Directory dir = await path_provider.getTemporaryDirectory();
      final fileName = 'recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
      _currentRecordingPath = '${dir.path}/$fileName';

      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          sampleRate: 22050,
          bitRate: 64000,
        ),
        path: _currentRecordingPath!,
      );

      setState(() {
        _isRecording = true;
      });
      _startTimer();
    } catch (e) {
      debugPrint("Error starting recording: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error starting recording: $e')),
        );
      }
    }
  }

  Future<void> _stopAndSaveRecording() async {
    try {
      final path = await _audioRecorder.stop();
      _stopTimer();

      setState(() {
        _isRecording = false;
      });

      _currentRecordingPath = path;
      if (_currentRecordingPath != null) {
        await _saveRecording();
      }
    } catch (e) {
      debugPrint("Error stopping recording: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error stopping recording: $e')),
        );
      }
    }
  }

  Future<void> _saveRecording() async {
    if (_cloudinary == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cloudinary is not configured. Cannot save recording.')),
        );
      }
      return;
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must be logged in to save recordings.')),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Upload to Cloudinary
      CloudinaryResponse response = await _cloudinary!.uploadFile(
        CloudinaryFile.fromFile(
          _currentRecordingPath!,
          resourceType: CloudinaryResourceType.Video,
        ),
      );

      String downloadUrl = response.secureUrl;
      if (downloadUrl.isEmpty) {
        throw Exception("Cloudinary returned an empty URL.");
      }

      // Create a title with timestamp
      String title = "Quick Recording ${DateFormat('MMM d, h:mm a').format(DateTime.now())}";

      Recording newRecording = Recording(
        id: '',
        userId: currentUser.uid,
        title: title,
        audioUrl: downloadUrl,
        createdAt: Timestamp.now(),
        durationSeconds: _recordingDurationSeconds,
      );

      await FirebaseFirestore.instance.collection('recordings').add(newRecording.toJson());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recording saved successfully!')),
        );
      }
    } catch (e) {
      debugPrint("Error saving recording: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save recording: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onRecordButtonPressed() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (_isRecording) {
        await _stopAndSaveRecording();
      } else {
        await _startRecording();
      }
    } catch (e) {
      debugPrint("Error during recording: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onPlayRecordingPressed(Map<String, dynamic> recording) {
    // Handle play recording logic
    debugPrint("Play pressed for: \${recording['title']}");
    // Example: Navigate to a player screen or use an audio player service
  }

  void _onSeeAllPressed() {
    // Navigate to a screen showing all recordings
    debugPrint("See All pressed");
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => const LibraryScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 20),
              Text(
                _formattedTime,
                style: textTheme.headlineMedium?.copyWith(
                  color: _isRecording
                      ? colorScheme.onSurface
                      : colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: 90,
                height: 90,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _onRecordButtonPressed,
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(20),
                    backgroundColor: _isRecording ? colorScheme.error : colorScheme.primary,
                    foregroundColor: _isRecording ? colorScheme.onError : colorScheme.onPrimary,
                  ),
                  child: _isLoading
                      ? SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: _isRecording ? colorScheme.onError : colorScheme.onPrimary,
                          ),
                        )
                      : Icon(
                          _isRecording ? CupertinoIcons.stop_fill : CupertinoIcons.mic_fill,
                          size: 40,
                        ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Tap to record',
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Recently Recorded',
                    style: textTheme.titleLarge?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _onSeeAllPressed,
                    icon: Text(
                      'See All',
                      style: textTheme.labelLarge?.copyWith(
                        color: colorScheme.primary,
                      ),
                    ),
                    label: Icon(
                      CupertinoIcons.chevron_forward,
                      size: 18,
                      color: colorScheme.primary,
                    ),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (_sampleRecordings.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40.0),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          CupertinoIcons.moon_zzz,
                          size: 60,
                          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No recordings yet.',
                          style:
                              textTheme.titleMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                        Text(
                          'Tap the microphone to start a new one!',
                          style:
                              textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _sampleRecordings.length > 3
                      ? 3
                      : _sampleRecordings.length, // Show max 3 or less
                  itemBuilder: (context, index) {
                    final recording = _sampleRecordings[index];
                    return RecordingListItem(
                      title: recording['title'] as String,
                      dateTime: recording['dateTime'] as DateTime,
                      durationSeconds: recording['durationSeconds'] as int,
                      location: recording['location'] as String?,
                      onPlay: () => _onPlayRecordingPressed(recording),
                    );
                  },
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
