import 'package:autobotv2email/phone_mockup/clickable_outline.dart';
import 'package:autobotv2email/phone_mockup/phone_mockup_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:async';
import 'dart:math';
import 'dart:ui';

// Action types for a more realistic simulation
enum TypingActionType { type, pause, backspace, think }

// Represents a single action in the typing sequence
class TypingAction {
  final TypingActionType type;
  final String? text;
  final Duration? duration;
  final int? count;

  TypingAction.type(this.text)
      : type = TypingActionType.type,
        duration = null,
        count = null;
  TypingAction.pause(this.duration)
      : type = TypingActionType.pause,
        text = null,
        count = null;
  TypingAction.backspace({this.count = 1})
      : type = TypingActionType.backspace,
        text = null,
        duration = null;
  TypingAction.think()
      : type = TypingActionType.think,
        text = null,
        duration = Duration(seconds: 2 + Random().nextInt(3)), // 2 to 4 second pause
        count = null;
}

class ComposeEmailScreen extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onSend;
  final Completer<void> onTypingComplete;
  final GlobalKey<ClickableOutlineState> sendButtonKey;

  const ComposeEmailScreen({
    super.key,
    required this.onBack,
    required this.onSend,
    required this.onTypingComplete,
    required this.sendButtonKey,
  });

  @override
  State<ComposeEmailScreen> createState() => _ComposeEmailScreenState();
}

class _ComposeEmailScreenState extends State<ComposeEmailScreen> {
  final _toController = TextEditingController();
  final _subjectController = TextEditingController();
  final _bodyController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _toFocusNode = FocusNode();
  final FocusNode _subjectFocusNode = FocusNode();
  final FocusNode _bodyFocusNode = FocusNode();
  final Random _random = Random();
  bool _isTyping = true;
  bool _blurFromField = false;
  bool _blurToField = false;

  @override
  void initState() {
    super.initState();
    // Page open hote hi "From" field ko blur kar dein
    _blurFromField = true; 
    _startTypingSimulation();
  }

  @override
  void dispose() {
    _toController.dispose();
    _subjectController.dispose();
    _bodyController.dispose();
    _scrollController.dispose();
    _toFocusNode.dispose();
    _subjectFocusNode.dispose();
    _bodyFocusNode.dispose();
    super.dispose();
  }

  // --- The "Human Typing Brain" ---
  Future<void> _startTypingSimulation() async {
    // Initial wait after opening the screen
    await Future.delayed(Duration(seconds: 7 + _random.nextInt(4)));

    final String txtData = await rootBundle.loadString('assets/email/email_template.txt');
    final lines = txtData.split('\n');
    final RegExp regExp = RegExp(r'^\d+\.\s*\((.*)\)$');

    List<TypingAction> subjectActions = [];
    List<TypingAction> bodyActions = [];

    // Pehli line se Subject ke actions banayein
    if (lines.isNotEmpty) {
      final subjectMatch = regExp.firstMatch(lines.first.trim());
      if (subjectMatch != null) {
        String subjectLine = subjectMatch.group(1)!;
        const subjectPrefix = 'Subject: ';
        if (subjectLine.startsWith(subjectPrefix)) {
          String subjectText = subjectLine.substring(subjectPrefix.length);
          subjectActions.addAll(_createTextActions(subjectText));
        }
      }
    }

    // Baaki lines se Body ke actions banayein
    for (int i = 1; i < lines.length; i++) {
      String currentLine = lines[i].trim();
      if (currentLine.toLowerCase() == '*space*') {
        bodyActions.add(TypingAction.type('\n'));
      } else {
        final match = regExp.firstMatch(currentLine);
        if (match != null) {
          bodyActions.add(TypingAction.think()); // Har line se pehle sochna
          bodyActions.addAll(_createTextActions(match.group(1)!));
          bodyActions.add(TypingAction.type('\n'));
        }
      }
    }

    // Actions ko execute karein
    await _executeActions(_subjectController, _subjectFocusNode, subjectActions);
    
    // Wait after subject is typed
    await Future.delayed(const Duration(seconds: 5));

    await _executeActions(_bodyController, _bodyFocusNode, bodyActions);
    
    // Start blurring "To" field's value
    if(mounted) {
      setState(() {
        _blurToField = true;
      });
    }

    // Type recipient email
    await _executeActions(_toController, _toFocusNode, _createTextActions("demo@gmail.com"));

    // Enable the send button
    if (mounted) {
      setState(() {
        _isTyping = false;
      });
    }

    // Wait for 5 seconds before signaling completion
    await Future.delayed(const Duration(seconds: 5));

    // Notify simulator that all typing and waiting is done
    if (mounted) {
      widget.onTypingComplete.complete();
    }
  }

  // Text ko actions mein convert karein
  List<TypingAction> _createTextActions(String text) {
    List<TypingAction> actions = [];
    final words = text.split(' ');
    for (var word in words) {
      actions.add(TypingAction.type(word));
      actions.add(TypingAction.pause(Duration(milliseconds: 200 + _random.nextInt(200)))); // Words ke beech pause
      actions.add(TypingAction.type(' ')); // Space type karein
    }
    // Aakhri space remove karein
    if (actions.isNotEmpty) {
       actions.removeLast();
    }
    return actions;
  }

  // Action sequence ko execute karein
  Future<void> _executeActions(TextEditingController controller, FocusNode focusNode, List<TypingAction> actions) async {
    if (!mounted) return;
    focusNode.requestFocus();
    if (mounted) {
      setState(() {});
    }

    for (final action in actions) {
      if (!mounted) return;
      switch (action.type) {
        case TypingActionType.type:
          await _typeText(controller, action.text!);
          break;
        case TypingActionType.pause:
        case TypingActionType.think:
          await Future.delayed(action.duration!);
          break;
        case TypingActionType.backspace:
          await _backspace(controller, action.count!);
          break;
      }
    }
    
    if (mounted) {
      focusNode.unfocus();
      setState(() {});
    }
  }

  // Real user jaisa text type karein
  Future<void> _typeText(TextEditingController controller, String text) async {
    for (int i = 0; i < text.length; i++) {
      if (!mounted) return;
      controller.text += text[i];
      controller.selection = TextSelection.fromPosition(TextPosition(offset: controller.text.length));
      setState(() {});

      if (controller == _bodyController && _scrollController.hasClients) {
        await Future.delayed(const Duration(milliseconds: 20));
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
        );
      }
      // Slower typing speed
      await Future.delayed(Duration(milliseconds: 150 + _random.nextInt(100)));
    }
  }

  // Backspace simulate karein
  Future<void> _backspace(TextEditingController controller, int count) async {
    for (int i = 0; i < count; i++) {
        if (!mounted || controller.text.isEmpty) return;
        controller.text = controller.text.substring(0, controller.text.length - 1);
        controller.selection = TextSelection.fromPosition(TextPosition(offset: controller.text.length));
        setState(() {});
        await Future.delayed(Duration(milliseconds: 100 + _random.nextInt(100)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final PhoneMockupContainerState? phoneMockupState = context.findAncestorStateOfType<PhoneMockupContainerState>();
    final ValueNotifier<String>? captionNotifier = phoneMockupState?.widget.currentCaption;
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: widget.onBack,
        ),
        actions: [
          IconButton(icon: const Icon(Icons.attach_file, color: Colors.black54), onPressed: () {}),
          ClickableOutline(
            key: widget.sendButtonKey,
            action: () async => widget.onSend(),
            captionNotifier: captionNotifier,
            caption: 'Now, click here to send the email.',
            child: IconButton(
              icon: Icon(Icons.send, color: _isTyping ? Colors.grey : Colors.black54),
              onPressed: _isTyping ? null : widget.onSend,
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black54),
            onSelected: (value) {},
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(value: 'schedule', child: Text('Schedule send')),
              const PopupMenuItem<String>(value: 'save_draft', child: Text('Save draft')),
              const PopupMenuItem<String>(value: 'discard', child: Text('Discard')),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            _buildAddressField(
                label: 'From',
                initialValue: 'thezestget@gmail.com',
                isFromField: true,
                shouldBlurValue: _blurFromField),
            const Divider(height: 1),
            _buildAddressField(
                label: 'To',
                controller: _toController,
                focusNode: _toFocusNode,
                shouldBlurValue: _blurToField),
            const Divider(height: 1),
            _buildSubjectField(),
            const Divider(height: 1),
            _buildBodyField(),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressField({
    required String label,
    TextEditingController? controller,
    String? initialValue,
    bool isFromField = false,
    FocusNode? focusNode,
    required bool shouldBlurValue,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: Colors.black54, fontSize: 16)),
          const SizedBox(width: 16),
          Expanded(
            child: ImageFiltered(
              imageFilter: shouldBlurValue
                  ? ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0)
                  : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
              child: TextField(
                focusNode: focusNode,
                controller: isFromField ? (TextEditingController()..text = initialValue ?? '') : controller,
                readOnly: isFromField,
                decoration: const InputDecoration(border: InputBorder.none),
              ),
            ),
          ),
          const Icon(Icons.expand_more, color: Colors.black54),
        ],
      ),
    );
  }

  Widget _buildSubjectField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: TextField(
        controller: _subjectController,
        focusNode: _subjectFocusNode,
        cursorColor: Colors.blue,
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Subject',
          hintStyle: TextStyle(color: Colors.black54, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildBodyField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextField(
        controller: _bodyController,
        focusNode: _bodyFocusNode,
        cursorColor: Colors.blue,
        maxLines: null,
        keyboardType: TextInputType.multiline,
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Compose email',
          hintStyle: TextStyle(color: Colors.black54, fontSize: 16),
        ),
      ),
    );
  }
}
