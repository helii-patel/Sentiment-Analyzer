import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../models/saved_review.dart';
import '../models/sentiment_result.dart';
import '../providers/auth_provider.dart';
import '../providers/history_provider.dart';
import '../providers/review_provider.dart';
import '../services/api_service.dart';
import '../widgets/animated_card.dart';
import '../widgets/gradient_header.dart';
import '../widgets/primary_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  late FocusNode _reviewFocus;
  final stt.SpeechToText _speech = stt.SpeechToText();

  Timer? _liveDebounce;
  SentimentResult? _currentResult;

  bool _loading = false;
  bool _liveLoading = false;
  bool _apiDown = false;
  bool _speechAvailable = false;
  bool _isListening = false;
  String? _speechLocaleId;
  bool _voiceRetriedWithoutLocale = false;
  String _voiceSessionBaseText = '';

  int _liveRequestId = 0;
  String? _apiMessage;
  String _liveStatus = 'Start typing to get live sentiment.';

  @override
  void initState() {
    super.initState();
    _reviewFocus = FocusNode();
    _initSpeech();
  }

  @override
  void dispose() {
    _liveDebounce?.cancel();
    _speech.stop();
    _controller.dispose();
    _reviewFocus.dispose();
    super.dispose();
  }

  Future<void> _initSpeech() async {
    final available = await _speech.initialize(
      debugLogging: true,
      onStatus: (status) {
        if (!mounted) return;
        if (status == 'notListening' || status == 'done') {
          setState(() {
            _isListening = false;
            if (_controller.text.trim().isEmpty) {
              _liveStatus = 'Start typing to get live sentiment.';
            }
          });
        }
      },
      onError: (error) {
        if (!mounted) return;
        if (error.errorMsg == 'error_language_unavailable' && !_voiceRetriedWithoutLocale) {
          _voiceRetriedWithoutLocale = true;
          setState(() {
            _isListening = false;
            _speechLocaleId = null;
            _liveStatus = 'Language unavailable. Retrying with default recognizer language...';
          });
          _toggleVoiceInput();
          return;
        }
        setState(() {
          _isListening = false;
          _liveStatus = 'Voice input error: ${error.errorMsg}.';
        });
      },
    );
    if (!mounted) return;
    if (!available) {
      setState(() {
        _speechAvailable = false;
        _speechLocaleId = null;
        _liveStatus = 'Voice recognition service is unavailable on this emulator.';
      });
      return;
    }

    final locale = await _speech.systemLocale();
    final locales = await _speech.locales();
    if (!mounted) return;

    final availableLocaleIds = locales.map((e) => e.localeId).toSet();
    String? selectedLocaleId = locale?.localeId;
    if (selectedLocaleId == null || !availableLocaleIds.contains(selectedLocaleId)) {
      const preferredLocaleIds = ['en_US', 'en_IN', 'en_GB'];
      for (final localeId in preferredLocaleIds) {
        if (availableLocaleIds.contains(localeId)) {
          selectedLocaleId = localeId;
          break;
        }
      }
      selectedLocaleId ??= locales.isNotEmpty ? locales.first.localeId : null;
    }

    setState(() {
      _speechAvailable = true;
      _speechLocaleId = selectedLocaleId;
      if (_controller.text.trim().isEmpty) {
        _liveStatus = 'Voice ready (${_speechLocaleId ?? 'default locale'}).';
      }
    });
  }

  void _onInputChanged(String value) {
    _liveDebounce?.cancel();
    final text = value.trim();

    if (text.isEmpty) {
      setState(() {
        _currentResult = null;
        _liveLoading = false;
        _apiDown = false;
        _apiMessage = null;
        _liveStatus = 'Start typing to get live sentiment.';
      });
      return;
    }

    _liveDebounce = Timer(const Duration(milliseconds: 700), () {
      _runLiveAnalysis(text);
    });
  }

  Future<void> _runLiveAnalysis(String text) async {
    final lines = text.split('\n').where((line) => line.trim().isNotEmpty).toList();
    if (lines.isEmpty) return;

    final requestId = ++_liveRequestId;
    setState(() {
      _liveLoading = true;
      _liveStatus = 'Analyzing live input...';
    });

    try {
      final result = await ApiService.analyzeTexts(lines);
      if (!mounted || requestId != _liveRequestId) return;

      setState(() {
        _currentResult = result;
        _liveLoading = false;
        _apiDown = false;
        _apiMessage = null;
        _liveStatus = 'Live sentiment updated.';
      });
    } on ApiException catch (e) {
      if (!mounted || requestId != _liveRequestId) return;
      setState(() {
        _liveLoading = false;
        _apiDown = e.type == ApiErrorType.network;
        _apiMessage = e.message;
        _liveStatus = 'Live analysis unavailable.';
      });
    } catch (_) {
      if (!mounted || requestId != _liveRequestId) return;
      setState(() {
        _liveLoading = false;
        _liveStatus = 'Unexpected error during live analysis.';
      });
    }
  }

  Future<void> _toggleVoiceInput() async {
    if (!_speechAvailable) {
      await _initSpeech();
      if (!_speechAvailable && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Voice input is not available on this device.')),
        );
      }
      return;
    }

    if (_isListening) {
      await _speech.stop();
      if (mounted) {
        setState(() => _isListening = false);
      }
      return;
    }

    _voiceSessionBaseText = _controller.text.trim();
    _voiceRetriedWithoutLocale = false;
    final started = await _speech.listen(
      localeId: _speechLocaleId,
      listenFor: const Duration(seconds: 45),
      pauseFor: const Duration(seconds: 4),
      listenOptions: stt.SpeechListenOptions(
        partialResults: true,
        listenMode: stt.ListenMode.dictation,
      ),
      onResult: (result) {
        if (!mounted) return;
        final spoken = result.recognizedWords.trim();
        final text = spoken.isEmpty
            ? _voiceSessionBaseText
            : (_voiceSessionBaseText.isEmpty ? spoken : '$_voiceSessionBaseText\n$spoken');
        setState(() {
          _controller.text = text;
          _controller.selection = TextSelection.fromPosition(
            TextPosition(offset: _controller.text.length),
          );
          _liveStatus = 'Voice captured. Live analysis running...';
        });
        _onInputChanged(text);
      },
    );

    if (!mounted) return;
    final didStart = started == true;
    setState(() {
      _isListening = didStart;
      if (didStart) {
        _liveStatus = 'Listening... speak now.';
      } else {
        _liveStatus = 'Could not start voice capture. Try emulator mic settings.';
      }
    });
  }

  Future<void> _analyze() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter at least one review')),
      );
      return;
    }

    final reviews = text.split('\n').where((line) => line.trim().isNotEmpty).toList();
    setState(() {
      _loading = true;
      _apiDown = false;
      _apiMessage = null;
    });

    try {
      final result = await ApiService.analyzeTexts(reviews);
      if (!mounted) return;

      setState(() {
        _currentResult = result;
        _loading = false;
        _liveStatus = 'Manual analysis completed.';
      });

      try {
        await context.read<HistoryProvider>().addToHistory(result);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Analysis done, but history sync failed: $e')),
        );
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _apiDown = e.type == ApiErrorType.network;
        _apiMessage = e.message;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Something went wrong. Please try again.')),
      );
    }
  }

  String _dominantSentiment(SentimentResult result) {
    if (result.positiveCount > result.negativeCount) return 'POSITIVE';
    if (result.negativeCount > result.positiveCount) return 'NEGATIVE';
    return 'NEUTRAL';
  }

  double _averageScore(SentimentResult result) {
    if (result.results.isEmpty) return 0;
    double total = 0;
    for (final r in result.results) {
      final s = r.sentiment.toUpperCase();
      if (s == 'POSITIVE') {
        total += r.confidence;
      } else if (s == 'NEGATIVE') {
        total -= r.confidence;
      }
    }
    return (total / result.results.length).clamp(-1.0, 1.0);
  }

  double _avgConfidence(SentimentResult result) {
    if (result.results.isEmpty) return 0;
    final total = result.results.fold<double>(0, (sum, r) => sum + r.confidence);
    return (total / result.results.length).clamp(0, 1);
  }

  String _emojiFor(String sentiment) {
    switch (sentiment) {
      case 'POSITIVE':
        return '😊';
      case 'NEGATIVE':
        return '😟';
      default:
        return '😐';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_apiDown) _buildApiStatusBanner(),
                  _buildInputSection(),
                  const SizedBox(height: 18),
                  _buildLiveSentimentCard(),
                  if (_loading) _buildLoadingState(),
                  if (_currentResult != null) ...[
                    const SizedBox(height: 24),
                    _buildResultsSection(),
                  ] else if (!_loading) ...[
                    const SizedBox(height: 24),
                    _buildNoResultsPlaceholder(),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return const GradientHeader(
      title: Text(
        'Sentiment Analysis',
        style: TextStyle(
          color: Colors.white,
          fontSize: 26,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInputSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedCard(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Text Input',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Type reviews and get real-time sentiment. Voice input is optional.',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
            ),
            const SizedBox(height: 20),
            Container(
              height: 170,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.3)),
              ),
              child: TextField(
                controller: _controller,
                focusNode: _reviewFocus,
                onChanged: _onInputChanged,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'e.g. This movie was amazing!',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _liveStatus,
                    style: TextStyle(
                      fontSize: 12,
                      color: _liveLoading ? const Color(0xFF6366F1) : Colors.grey.shade500,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton.filled(
                  onPressed: _toggleVoiceInput,
                  icon: Icon(_isListening ? Icons.mic_off_rounded : Icons.mic_rounded),
                  tooltip: _isListening ? 'Stop voice input' : 'Start voice input',
                ),
              ],
            ),
            const SizedBox(height: 14),
            PrimaryButton(
              text: _loading ? 'Analyzing...' : 'Analyze Sentiment',
              onPressed: _loading ? () {} : _analyze,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveSentimentCard() {
    final result = _currentResult;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (result == null) {
      return AnimatedCard(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Live sentiment result will appear here as you type.',
            style: TextStyle(fontSize: 14),
          ),
        ),
      );
    }

    final dominant = _dominantSentiment(result);
    final score = _averageScore(result);
    final confidence = _avgConfidence(result);
    final scoreColor = score >= 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444);

    return AnimatedCard(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: scoreColor.withValues(alpha: 0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(_emojiFor(dominant), style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 10),
                Text(
                  'Real-Time: $dominant',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              'Score: ${(score * 100).toStringAsFixed(0)}',
              style: TextStyle(fontSize: 14, color: scoreColor, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              minHeight: 10,
              borderRadius: BorderRadius.circular(8),
              value: (score + 1) / 2,
              backgroundColor: Colors.grey.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
            ),
            const SizedBox(height: 10),
            Text(
              'Confidence: ${(confidence * 100).toStringAsFixed(1)}%',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApiStatusBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFCA5A5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_off_rounded, color: Color(0xFFEF4444)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _apiMessage ?? 'Backend is offline. Start the API server.',
              style: const TextStyle(color: Color(0xFF7F1D1D)),
            ),
          ),
          TextButton(
            onPressed: _loading ? null : _analyze,
            child: const Text('Retry'),
          ),
          TextButton(
            onPressed: () => setState(() => _apiDown = false),
            child: const Text('Dismiss'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            const SizedBox(
              width: 80,
              height: 80,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF6366F1)),
                  Icon(Icons.psychology_rounded, size: 40, color: Color(0xFF6366F1)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Analyzing Sentiment...',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Processing your reviews with AI',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsPlaceholder() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 20),
          Icon(Icons.auto_awesome_rounded, size: 60, color: Colors.grey.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          const Text(
            'No Results Yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Type or speak a review to get instant sentiment feedback',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsSection() {
    final result = _currentResult!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Detailed Results',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: _saveCurrentResult,
                  tooltip: 'Save analysis',
                  icon: const Icon(Icons.bookmark_add_rounded),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.keyboard_arrow_up_rounded),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildDistributionChart(result),
        const SizedBox(height: 24),
        ...result.results.map((r) => _buildIndividualResultCard(r)),
      ],
    );
  }

  Future<void> _saveCurrentResult() async {
    final result = _currentResult;
    if (result == null) return;

    final auth = context.read<AuthProvider>();
    final userId = auth.currentUserId;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to save results')),
      );
      return;
    }

    final titleController = TextEditingController();
    final noteController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save analysis'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if ((value ?? '').trim().isEmpty) {
                    return 'Title is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: noteController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Note (optional)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(context, true);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (shouldSave != true || !mounted) return;

    final now = DateTime.now();
    final saved = SavedReview(
      id: 0,
      userId: userId,
      title: titleController.text.trim(),
      note: noteController.text.trim(),
      result: result,
      createdAt: now,
      updatedAt: now,
    );

    try {
      await context.read<ReviewProvider>().add(saved);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saved to library')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Save failed: $e')),
      );
    }
  }

  Widget _buildDistributionChart(SentimentResult result) {
    return AnimatedCard(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1E293B)
              : Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            const Text('Sentiment Distribution', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            SizedBox(
              height: 150,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: result.positiveCount.toDouble(),
                      color: const Color(0xFF10B981),
                      radius: 25,
                      showTitle: false,
                    ),
                    PieChartSectionData(
                      value: result.negativeCount.toDouble(),
                      color: const Color(0xFFEF4444),
                      radius: 25,
                      showTitle: false,
                    ),
                  ],
                  centerSpaceRadius: 40,
                  sectionsSpace: 5,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildBadge('${result.positiveCount} Positive', const Color(0xFF10B981)),
                const SizedBox(width: 20),
                _buildBadge('${result.negativeCount} Negative', const Color(0xFFEF4444)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: color.withValues(alpha: 0.8),
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildIndividualResultCard(IndividualResult r) {
    final isPos = r.sentiment.toLowerCase() == 'positive';
    final color = isPos ? const Color(0xFF10B981) : const Color(0xFFEF4444);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isPos ? Icons.thumb_up_rounded : Icons.thumb_down_rounded,
                color: color,
                size: 18,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(r.sentiment, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                  Text(
                    '${(r.confidence * 100).toInt()}% confidence',
                    style: TextStyle(color: color.withValues(alpha: 0.6), fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(r.text, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 16),
          const Text(
            'Confidence Level',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          _buildSmallProgress(r.confidence, color),
        ],
      ),
    );
  }

  Widget _buildSmallProgress(double val, Color color) {
    return Container(
      height: 4,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(2),
      ),
      child: FractionallySizedBox(
        widthFactor: val,
        alignment: Alignment.centerLeft,
        child: Container(
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
      ),
    );
  }
}
