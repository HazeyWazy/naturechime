import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:naturechime/models/recording_model.dart';
import 'package:naturechime/models/user_model.dart';
import 'package:naturechime/widgets/audio_level_indicator.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  bool _isRecording = false;
  bool _isUploading = false; // To show loading indicator on save
  double _currentAudioLevel = 0.0; // Initial audio level
  final TextEditingController _titleController = TextEditingController(text: 'Recording title');
  late AudioRecorder _audioRecorder;
  StreamSubscription<Amplitude>? _amplitudeSubscription;
  StreamSubscription<User?>? _userSubscription;
  String? _currentRecordingPath;
  Timer? _timer;
  int _recordingDurationSeconds = 0;
  String _formattedTime = '00:00:00';

  // Cloudinary Configuration
  String? _cloudinaryCloudName;
  String? _cloudinaryUploadPreset;
  CloudinaryPublic? _cloudinary;

  UserModel? _userModel; // To store fetched user data from Firestore
  bool _isLoadingUserModel = false; // To manage loading state for user model

  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder();

    debugPrint("RecordScreen initState: Attempting to load Cloudinary .env variables.");
    final String? cloudNameFromEnv = dotenv.env['CLOUDINARY_CLOUD_NAME'];
    final String? uploadPresetFromEnv = dotenv.env['CLOUDINARY_UPLOAD_PRESET'];

    debugPrint("RecordScreen initState: CLOUDINARY_CLOUD_NAME from .env = '$cloudNameFromEnv'");
    debugPrint(
        "RecordScreen initState: CLOUDINARY_UPLOAD_PRESET from .env = '$uploadPresetFromEnv'");

    if (cloudNameFromEnv != null &&
        cloudNameFromEnv.isNotEmpty &&
        uploadPresetFromEnv != null &&
        uploadPresetFromEnv.isNotEmpty) {
      _cloudinaryCloudName = cloudNameFromEnv;
      _cloudinaryUploadPreset = uploadPresetFromEnv;
      try {
        debugPrint(
            "RecordScreen initState: Attempting to initialize CloudinaryPublic with CloudName: '$_cloudinaryCloudName', Preset: '$_cloudinaryUploadPreset'");
        _cloudinary =
            CloudinaryPublic(_cloudinaryCloudName!, _cloudinaryUploadPreset!, cache: false);
        debugPrint("RecordScreen initState: Cloudinary client initialized successfully.");
      } catch (e) {
        _cloudinary = null; // Ensure it's null if constructor fails
        debugPrint("RecordScreen initState: ERROR initializing CloudinaryPublic: $e");
      }
    } else {
      _cloudinaryCloudName = null;
      _cloudinaryUploadPreset = null;
      _cloudinary = null;
      debugPrint(
          "RecordScreen initState: CRITICAL - Cloudinary Cloud Name or Upload Preset is not set or is empty in .env. Uploads disabled.");
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    debugPrint("RecordScreen initState: Initial Firebase User ID: ${currentUser?.uid}");
    _fetchUserModelAndSetTitle(currentUser); // Fetch UserModel on init

    _userSubscription = FirebaseAuth.instance.userChanges().listen((User? firebaseUser) async {
      debugPrint(
          "RecordScreen userChanges listener: Firebase User event. UID: ${firebaseUser?.uid}");
      if (firebaseUser != null) {
        // It's good practice to reload to get the latest auth state,
        // though displayName here will come from Firestore.
        try {
          await firebaseUser.reload();
          final refreshedFirebaseUser = FirebaseAuth.instance.currentUser;
          if (mounted) {
            _fetchUserModelAndSetTitle(refreshedFirebaseUser);
          }
        } catch (e) {
          debugPrint("RecordScreen userChanges listener: Error reloading firebaseUser: $e");
          if (mounted) {
            _fetchUserModelAndSetTitle(firebaseUser); // Use the user from stream on error
          }
        }
      } else {
        // User logged out
        if (mounted) {
          setState(() {
            _userModel = null; // Clear user model on logout
          });
          _setDefaultTitle(); // Set default title for logged-out state
        }
      }
    });
  }

  Future<void> _fetchUserModelAndSetTitle(User? firebaseUser) async {
    if (!mounted) return;

    if (firebaseUser == null) {
      debugPrint("_fetchUserModelAndSetTitle: No Firebase user, clearing UserModel.");
      setState(() {
        _userModel = null;
        _isLoadingUserModel = false;
      });
      _setDefaultTitle();
      return;
    }

    // Avoid fetching if UID is the same and model already exists, unless forced
    if (_userModel != null && _userModel!.uid == firebaseUser.uid && !_isLoadingUserModel) {
      debugPrint(
          "_fetchUserModelAndSetTitle: UserModel for ${firebaseUser.uid} already loaded. Setting title.");
      _setDefaultTitle();
      return;
    }

    setState(() {
      _isLoadingUserModel = true;
    });

    try {
      debugPrint("_fetchUserModelAndSetTitle: Fetching UserModel for UID: ${firebaseUser.uid}");
      final userDocSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(firebaseUser.uid).get();

      if (!mounted) return;

      if (userDocSnapshot.exists) {
        // Explicitly cast to Map<String, dynamic> before passing to fromFirestore
        final data = userDocSnapshot.data() as Map<String, dynamic>?;
        if (data != null) {
          setState(() {
            _userModel =
                UserModel.fromFirestore(userDocSnapshot as DocumentSnapshot<Map<String, dynamic>>);
            debugPrint(
                "_fetchUserModelAndSetTitle: UserModel loaded successfully for UID: ${_userModel?.uid}, DisplayName: ${_userModel?.displayName}");
          });
        } else {
          debugPrint(
              "_fetchUserModelAndSetTitle: User document data is null for UID: ${firebaseUser.uid}");
          setState(() {
            _userModel = null; // Ensure userModel is null if data is bad
          });
        }
      } else {
        debugPrint(
            "_fetchUserModelAndSetTitle: User document not found in Firestore for UID: ${firebaseUser.uid}");
        setState(() {
          _userModel = null; // Clear user model if not found
        });
      }
    } catch (e, s) {
      debugPrint("_fetchUserModelAndSetTitle: Error fetching UserModel: $e\nStack trace: $s");
      if (mounted) {
        setState(() {
          _userModel = null; // Clear on error
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingUserModel = false;
        });
        _setDefaultTitle(); // Always attempt to set title after fetch attempt
      }
    }
  }

  void _setDefaultTitle() {
    // Now uses _userModel.displayName
    final String? currentDisplayName = _userModel?.displayName;
    final String defaultDateBasedTitle =
        "My Recording ${DateFormat('yyyy-MM-dd').format(DateTime.now())}";
    String newTitle;

    if (currentDisplayName != null && currentDisplayName.isNotEmpty) {
      newTitle = "$currentDisplayName's Recording";
      debugPrint(
          "RecordScreen _setDefaultTitle (from Firestore): DisplayName available ('$currentDisplayName'). Tentative title: '$newTitle'");
    } else {
      newTitle = defaultDateBasedTitle;
      debugPrint(
          "RecordScreen _setDefaultTitle (from Firestore): DisplayName null/empty in UserModel. Tentative title: '$newTitle'. User UID: ${_userModel?.uid}");
    }

    bool isPlaceholderTitle =
        _titleController.text == 'Recording title' || _titleController.text.isEmpty;
    bool isCurrentTitleADefaultNameBased = _titleController.text.endsWith("'s Recording");
    bool isCurrentTitleADateBasedDefault = _titleController.text.startsWith("My Recording ") &&
        _titleController.text.contains(DateFormat('yyyy-MM-dd').format(DateTime.now()));

    if (newTitle == defaultDateBasedTitle) {
      // DisplayName is not available or empty
      if (isPlaceholderTitle || isCurrentTitleADefaultNameBased) {
        if (_titleController.text != newTitle) {
          setState(() {
            _titleController.text = newTitle;
            debugPrint("RecordScreen _setDefaultTitle: Set to date-based default: '$newTitle'");
          });
        }
      } else {
        debugPrint(
            "RecordScreen _setDefaultTitle: DisplayName null/empty. Preserving custom title: '${_titleController.text}'");
      }
    } else {
      // DisplayName is available, newTitle is "DisplayName's Recording"
      if (isPlaceholderTitle ||
          isCurrentTitleADateBasedDefault ||
          isCurrentTitleADefaultNameBased) {
        if (_titleController.text != newTitle) {
          setState(() {
            _titleController.text = newTitle;
            debugPrint("RecordScreen _setDefaultTitle: Set to name-based default: '$newTitle'");
          });
        }
      } else {
        debugPrint(
            "RecordScreen _setDefaultTitle: DisplayName available. Preserving custom title: '${_titleController.text}'");
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _amplitudeSubscription?.cancel();
    _userSubscription?.cancel();
    _audioRecorder.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _recordingDurationSeconds = 0;
    _timer?.cancel(); // Cancel any existing timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _recordingDurationSeconds++;
      if (mounted) {
        setState(() {
          _formattedTime = _formatDuration(_recordingDurationSeconds);
        });
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  String _formatDuration(int totalSeconds) {
    final duration = Duration(seconds: totalSeconds);
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  Future<bool> _checkPermission() async {
    debugPrint("_checkPermission: Called");
    try {
      var status = await Permission.microphone.status;
      debugPrint("_checkPermission: Initial status = $status");
      if (!status.isGranted) {
        status = await Permission.microphone.request();
        debugPrint("_checkPermission: Status after request = $status");
      }
      return status.isGranted;
    } catch (e) {
      debugPrint("_checkPermission: ERROR checking/requesting permission: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error with microphone permissions: ${e.toString()}')),
        );
      }
      return false; // Return false if an error occurs
    }
  }

  Future<void> _startRecording() async {
    debugPrint("_startRecording: Called");
    final hasPermission = await _checkPermission();
    debugPrint("_startRecording: hasPermission = $hasPermission");

    if (!hasPermission) {
      debugPrint("_startRecording: Microphone permission denied. Showing SnackBar.");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Microphone permission is required to record audio.'),
          ),
        );
      }
      return;
    }

    try {
      debugPrint("_startRecording: Attempting to get temporary directory.");
      final Directory dir = await path_provider.getTemporaryDirectory();
      debugPrint("_startRecording: Temporary directory path = ${dir.path}");

      final fileName = 'recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
      _currentRecordingPath = '${dir.path}/$fileName';
      debugPrint("_startRecording: Recording path set to: $_currentRecordingPath");

      debugPrint("_startRecording: Attempting to call _audioRecorder.start()");
      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          sampleRate: 22050,
          bitRate: 64000,
        ),
        path: _currentRecordingPath!,
      );
      debugPrint("_startRecording: _audioRecorder.start() call completed.");

      _amplitudeSubscription =
          _audioRecorder.onAmplitudeChanged(const Duration(milliseconds: 160)).listen((amp) {
        // debugPrint("_startRecording: Amplitude changed: ${amp.current}"); // Can be very noisy
        if (mounted) {
          setState(() {
            double normalized = (amp.current + 160) / 160;
            _currentAudioLevel = normalized.clamp(0.0, 1.0);
          });
        }
      });
      debugPrint("_startRecording: Amplitude subscription set up.");

      if (mounted) {
        debugPrint(
            "_startRecording: Successfully started, setting _isRecording to true and starting timer.");
        setState(() {
          _isRecording = true;
        });
        _startTimer();
      }
      debugPrint("_startRecording: Recording process initiated fully.");
    } catch (e) {
      debugPrint("_startRecording: ERROR starting recording: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error starting recording: $e'),
          ),
        );
      }
    }
  }

  Future<void> _stopRecording() async {
    debugPrint("_stopRecording: Called");
    try {
      final path = await _audioRecorder.stop();
      _stopTimer();
      await _amplitudeSubscription?.cancel();
      _amplitudeSubscription = null;
      if (mounted) {
        setState(() {
          _isRecording = false;
          _currentAudioLevel = 0.0;
        });
      }
      debugPrint("Stopped recording. File saved at: $path");
      _currentRecordingPath = path;
    } catch (e) {
      debugPrint("Error stopping recording: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error stopping recording: $e')),
        );
      }
    }
  }

  void _toggleRecording() async {
    debugPrint("Record button tapped (_toggleRecording). _isRecording = $_isRecording");
    if (_isRecording) {
      await _stopRecording();
    } else {
      _formattedTime = _formatDuration(0);
      _recordingDurationSeconds = 0;
      await _startRecording();
    }
  }

  Future<void> _saveRecording() async {
    if (_cloudinary == null) {
      debugPrint("Cloudinary client not initialized. Check .env configuration.");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cloudinary is not configured. Cannot save recording.'),
          ),
        );
      }
      return;
    }

    if (_currentRecordingPath == null || _currentRecordingPath!.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No recording available to save.'),
          ),
        );
      }
      return;
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You must be logged in to save recordings.'),
          ),
        );
      }
      return;
    }

    if (_titleController.text.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a title for your recording.'),
          ),
        );
      }
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // Upload to Cloudinary
      CloudinaryResponse response = await _cloudinary!.uploadFile(
        CloudinaryFile.fromFile(
          _currentRecordingPath!,
          resourceType: CloudinaryResourceType.Video, // Audio is treated as video by Cloudinary
        ),
      );

      String downloadUrl = response.secureUrl;

      if (downloadUrl.isEmpty) {
        throw Exception("Cloudinary returned an empty URL.");
      }

      Recording newRecording = Recording(
        id: '',
        userId: currentUser.uid,
        title: _titleController.text.trim(),
        audioUrl: downloadUrl,
        createdAt: Timestamp.now(),
        durationSeconds: _recordingDurationSeconds,
      );

      await FirebaseFirestore.instance.collection('recordings').add(newRecording.toJson());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Recording "${_titleController.text}" saved successfully!')),
        );
        // Reset state after successful save
        _currentRecordingPath = null;
        _recordingDurationSeconds = 0;
        _formattedTime = _formatDuration(0);
        // Reset title or navigate away
      }
    } catch (e) {
      debugPrint("Error saving recording to Cloudinary/Firestore: $e");
      String errorMessage = 'Failed to save recording.';
      if (e is CloudinaryException) {
        errorMessage = 'Cloudinary error: ${e.message}';
      } else if (e.toString().toLowerCase().contains('dioexception') ||
          e.toString().toLowerCase().contains('socketexception') ||
          e.toString().toLowerCase().contains('network is unreachable')) {
        errorMessage =
            'Network connection error during upload. Please check your internet connection and try again.';
      } else {
        errorMessage = 'Failed to save recording: ${e.toString()}';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  Future<void> _discardRecording() async {
    if (_currentRecordingPath != null) {
      try {
        final file = File(_currentRecordingPath!);
        if (await file.exists()) {
          await file.delete();
          debugPrint("Discarded local file: $_currentRecordingPath");
        }
      } catch (e) {
        debugPrint("Error deleting discarded file: $e");
      }
    }
    // Reset UI elements
    setState(() {
      _currentRecordingPath = null;
      _currentAudioLevel = 0.0;
      _recordingDurationSeconds = 0;
      _formattedTime = _formatDuration(0);
      _isRecording = false; // Ensure recording state is reset
    });
    _setDefaultTitle(); // Reset title based on current _userModel

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recording discarded.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final formattedDate = DateFormat('d MMMM yyyy, h:mm a').format(now);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const SizedBox(height: 20),
                  Text(
                    'Record Sound',
                    textAlign: TextAlign.center,
                    style: textTheme.headlineSmall!.copyWith(color: colorScheme.onSurface),
                  ),
                  Text(
                    formattedDate,
                    textAlign: TextAlign.center,
                    style: textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.normal,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 30),
                  AudioLevelIndicator(audioLevel: _currentAudioLevel, barCount: 20),
                  const SizedBox(height: 30),
                  Text(
                    _formattedTime,
                    textAlign: TextAlign.center,
                    style: textTheme.headlineMedium!.copyWith(color: colorScheme.onSurface),
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: SizedBox(
                      width: 90,
                      height: 90,
                      child: ElevatedButton(
                        onPressed:
                            _isUploading ? null : _toggleRecording, // Disable while uploading
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(20),
                          backgroundColor: _isRecording ? colorScheme.error : colorScheme.primary,
                          foregroundColor:
                              _isRecording ? colorScheme.onError : colorScheme.onPrimary,
                        ),
                        child: Icon(
                          _isRecording ? CupertinoIcons.stop_fill : CupertinoIcons.mic_fill,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                  TextFormField(
                    controller: _titleController,
                    enabled: !_isRecording, // Disable title edit while recording
                    decoration: InputDecoration(
                      labelText: 'Recording Title',
                      hintText: 'My Awesome Recording',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: colorScheme.outlineVariant),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: colorScheme.outlineVariant),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      SizedBox(
                        width: 120,
                        child: ElevatedButton.icon(
                          onPressed:
                              _isUploading ? null : _discardRecording, // Disable while uploading
                          icon: const Icon(CupertinoIcons.trash),
                          label: const Text('Discard'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.surfaceContainerHighest,
                            foregroundColor: colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 120,
                        child: ElevatedButton.icon(
                          onPressed: _isUploading || _isRecording
                              ? null
                              : _saveRecording, // Disable while uploading or recording
                          icon: _isUploading
                              ? SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: colorScheme.onPrimary,
                                  ))
                              : const Icon(CupertinoIcons.check_mark_circled),
                          label: Text(_isUploading ? 'Saving...' : 'Save'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
