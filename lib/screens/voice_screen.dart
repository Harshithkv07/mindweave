import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import '../services/mindweave_provider.dart';
import '../services/storage_service.dart';

/// VoiceScreen provides offline speech synthesis and voice guidance for patients
/// using flutter_tts. Operates entirely locally on the device without requiring
/// any internet access or external cloud services.
class VoiceScreen extends StatefulWidget {
  const VoiceScreen({super.key});

  @override
  State<VoiceScreen> createState() => _VoiceScreenState();
}

class _VoiceScreenState extends State<VoiceScreen>
    with SingleTickerProviderStateMixin {
  late FlutterTts _flutterTts;
  final TextEditingController _customTextController = TextEditingController();

  bool _isSpeaking = false;
  String _currentSpeakingText = '';
  double _speechRate = 0.42; // Gentle, clear speed for patient accessibility
  final double _volume = 1.0;
  final double _pitch = 1.0;

  late AnimationController _waveAnimationController;

  @override
  void initState() {
    super.initState();
    _initTts();
    _waveAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  Future<void> _initTts() async {
    _flutterTts = FlutterTts();

    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(_speechRate);
    await _flutterTts.setVolume(_volume);
    await _flutterTts.setPitch(_pitch);

    // Ensure audio continues in silent mode on iOS if allowed
    await _flutterTts.setIosAudioCategory(
      IosTextToSpeechAudioCategory.playback,
      [
        IosTextToSpeechAudioCategoryOptions.defaultToSpeaker,
        IosTextToSpeechAudioCategoryOptions.allowBluetooth,
      ],
    );

    _flutterTts.setStartHandler(() {
      if (mounted) {
        setState(() {
          _isSpeaking = true;
        });
      }
    });

    _flutterTts.setCompletionHandler(() {
      if (mounted) {
        setState(() {
          _isSpeaking = false;
          _currentSpeakingText = '';
        });
      }
    });

    _flutterTts.setCancelHandler(() {
      if (mounted) {
        setState(() {
          _isSpeaking = false;
          _currentSpeakingText = '';
        });
      }
    });

    _flutterTts.setErrorHandler((msg) {
      if (mounted) {
        setState(() {
          _isSpeaking = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Speech synthesis error: $msg'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _waveAnimationController.dispose();
    _customTextController.dispose();
    super.dispose();
  }

  Future<void> _speak(String text) async {
    if (text.trim().isEmpty) return;

    await _flutterTts.stop();
    await _flutterTts.setSpeechRate(_speechRate);
    await _flutterTts.setVolume(_volume);
    await _flutterTts.setPitch(_pitch);

    setState(() {
      _currentSpeakingText = text;
    });

    final result = await _flutterTts.speak(text);
    if (result == 1) {
      setState(() {
        _isSpeaking = true;
      });
    }
  }

  Future<void> _stop() async {
    await _flutterTts.stop();
    if (mounted) {
      setState(() {
        _isSpeaking = false;
        _currentSpeakingText = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MindWeaveProvider>(context);
    final profile = provider.profile ?? StorageService.getProfile();
    final patientName = profile?.name ?? 'Margaret';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          '🎤 Voice Guidance Assistant',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.wifi_off, size: 14, color: Colors.green.shade800),
                const SizedBox(width: 6),
                Text(
                  '100% Offline TTS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Voice Player Hero Banner
                _buildSpeakerHeroBanner(patientName),
                const SizedBox(height: 24),

                // Speech Speed & Tone Adjustments
                _buildVoiceControlsCard(),
                const SizedBox(height: 24),

                // Guided Patient Flow Presets
                const Text(
                  'Patient Care Flows',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Tap any care guidance prompt to synthesize voice instructions offline.',
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
                const SizedBox(height: 14),
                _buildCareFlowCard(
                  emoji: '🌅',
                  title: 'Daily Orientation & Morning Greeting',
                  subtitle: 'Helps orient time, day, and daily schedule.',
                  message:
                      'Good morning $patientName! Today is a beautiful new day. You are in the comfort of your home, and your care plan is all set. Let us take a deep breath and start the day smoothly.',
                  color: Colors.amber,
                ),
                const SizedBox(height: 12),
                _buildCareFlowCard(
                  emoji: '💧',
                  title: 'Hydration & Water Reminder',
                  subtitle: 'Prompts gentle fluid intake.',
                  message:
                      '$patientName, please take a moment to drink a full glass of fresh water. Staying well hydrated supports your memory, focus, and overall well-being.',
                  color: Colors.blue,
                ),
                const SizedBox(height: 12),
                _buildCareFlowCard(
                  emoji: '💊',
                  title: 'Prescribed Medication Routine',
                  subtitle: 'Walks patient through scheduled medications.',
                  message:
                      'It is time for your scheduled medication, $patientName. Please ensure you take your medication with water as instructed by your caregiver. Take your time.',
                  color: Colors.teal,
                ),
                const SizedBox(height: 12),
                _buildCareFlowCard(
                  emoji: '🧩',
                  title: 'Cognitive Game Encouragement',
                  subtitle: 'Explains rules and comforts the patient.',
                  message:
                      'Ready for today\'s memory exercise? Remember, there is no timer pressure. Finding the matching cards helps keep your neural pathways active and strong. Let\'s begin whenever you are ready.',
                  color: Colors.indigo,
                ),
                const SizedBox(height: 12),
                _buildCareFlowCard(
                  emoji: '🌿',
                  title: 'Calming Breath & Relaxation',
                  subtitle: 'Guided relaxation and reassurance.',
                  message:
                      'Take a slow, deep breath in through your nose. Hold it gently. Now exhale slowly through your mouth. You are safe, supported, and doing wonderfully today.',
                  color: Colors.purple,
                ),

                const SizedBox(height: 28),

                // Custom Offline Text Synthesizer
                _buildCustomSpeakerCard(),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpeakerHeroBanner(String patientName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _isSpeaking
              ? [Colors.deepPurple.shade700, Colors.indigo.shade800]
              : [Colors.indigo.shade700, Colors.blue.shade800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedBuilder(
                animation: _waveAnimationController,
                builder: (context, child) {
                  final scale = _isSpeaking
                      ? 1.0 + (_waveAnimationController.value * 0.15)
                      : 1.0;
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _isSpeaking
                              ? Colors.tealAccent
                              : Colors.white38,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        _isSpeaking
                            ? Icons.volume_up_rounded
                            : Icons.record_voice_over_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isSpeaking
                          ? '🔊 Speaking to $patientName...'
                          : 'Audio Voice Guidance',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isSpeaking
                          ? 'Speech synthesis active (Offline TTS)'
                          : 'Clear, gentle speech guidance for daily routines',
                      style: TextStyle(
                        color: Colors.indigo.shade100,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_currentSpeakingText.isNotEmpty) ...[
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '"$_currentSpeakingText"',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  height: 1.4,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
          const SizedBox(height: 18),
          Row(
            children: [
              if (_isSpeaking)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 12),
                  ),
                  onPressed: _stop,
                  icon: const Icon(Icons.stop_rounded),
                  label: const Text(
                    'Stop Speaking',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                )
              else
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.indigo.shade900,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 12),
                  ),
                  onPressed: () {
                    _speak(
                      'Hello $patientName. I am your MindWeave voice companion. I am here to guide you through your daily routines and cognitive exercises.',
                    );
                  },
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text(
                    'Play Introduction',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceControlsCard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Voice Pace & Pitch',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                Text(
                  _speechRate <= 0.35
                      ? 'Gentle & Slow'
                      : _speechRate <= 0.5
                          ? 'Standard Clear'
                          : 'Brisk',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.speed, size: 20, color: Colors.grey),
                const SizedBox(width: 8),
                const Text('Pace:', style: TextStyle(fontSize: 13)),
                Expanded(
                  child: Slider(
                    value: _speechRate,
                    min: 0.25,
                    max: 0.75,
                    divisions: 10,
                    label: '${(_speechRate * 100).round()}%',
                    onChanged: (val) {
                      setState(() => _speechRate = val);
                      _flutterTts.setSpeechRate(val);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCareFlowCard({
    required String emoji,
    required String title,
    required String subtitle,
    required String message,
    required MaterialColor color,
  }) {
    final isThisSpeaking = _isSpeaking && _currentSpeakingText == message;

    return Card(
      elevation: isThisSpeaking ? 3 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isThisSpeaking
            ? BorderSide(color: color.shade600, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _speak(message),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(emoji, style: const TextStyle(fontSize: 26)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '"$message"',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade800,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  isThisSpeaking
                      ? Icons.stop_circle_rounded
                      : Icons.play_circle_fill_rounded,
                  color: isThisSpeaking ? Colors.red : color.shade700,
                  size: 34,
                ),
                onPressed: () {
                  if (isThisSpeaking) {
                    _stop();
                  } else {
                    _speak(message);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomSpeakerCard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Custom Offline Speech Prompt',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Type any custom message for the patient to hear aloud through speech synthesis.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _customTextController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText:
                    'e.g., "Margaret, your daughter Sarah called and will visit this Saturday afternoon."',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    _customTextController.clear();
                  },
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear'),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 12),
                  ),
                  onPressed: () {
                    _speak(_customTextController.text);
                  },
                  icon: const Icon(Icons.volume_up),
                  label: const Text(
                    'Speak Prompt',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}