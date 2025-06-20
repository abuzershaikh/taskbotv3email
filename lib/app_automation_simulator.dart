// lib/app_automation_simulator.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math'; // Import for Random
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'phone_mockup/phone_mockup_container.dart';
import 'phone_mockup/app_grid.dart';

class AppAutomationSimulator {
  final Random _random = Random();
  final GlobalKey<PhoneMockupContainerState> phoneMockupKey;
  final GlobalKey<AppGridState> appGridKey;
  final Stopwatch _stopwatch = Stopwatch();
  final List<Map<String, String>> _log = [];

  // Notifiers for the two display widgets
  final ValueNotifier<String> currentCaption;
  final ValueNotifier<String> currentAppName;

  File? _logFile;
  String _appNameForLog = '';
  String _simulationStartTimeForLog = '';

  AppAutomationSimulator({
    required this.phoneMockupKey,
    required this.appGridKey,
    required this.currentCaption,
    required this.currentAppName,
  });

  Future<void> _startLog(String appName) async {
    _appNameForLog = appName;
    _simulationStartTimeForLog = DateTime.now().toIso8601String();
    _log.clear();
    _stopwatch.reset();
    _stopwatch.start();

    final documentsDirectory = await getApplicationDocumentsDirectory();
    final logDirectory = Directory('${documentsDirectory.path}/commandlog');

    if (!await logDirectory.exists()) {
      await logDirectory.create(recursive: true);
    }

    final now = DateTime.now();
    final formatter = DateFormat('yyyy-MM-dd_HH-mm-ss');
    final String formattedDate = formatter.format(now);
    final fileName = '${appName}_$formattedDate.json';
    _logFile = File('${logDirectory.path}/$fileName');

    _log.add({'timestamp': '00:00', 'step': 'Simulation Start'});
    await _updateLogFile();
  }

  Future<void> _updateLogFile() async {
    if (_logFile == null) return;

    final logData = {
      'appName': _appNameForLog,
      'simulationStartTime': _simulationStartTimeForLog,
      'steps': _log,
    };
    final jsonString = const JsonEncoder.withIndent('  ').convert(logData);
    await _logFile!.writeAsString(jsonString);
  }

  Future<void> _stopLog() async {
    final elapsed = _stopwatch.elapsed;
    final timestamp =
        '${elapsed.inMinutes.toString().padLeft(2, '0')}:${(elapsed.inSeconds % 60).toString().padLeft(2, '0')}';
    _log.add({'timestamp': timestamp, 'step': 'Simulation Stop'});
    _stopwatch.stop();
    await _updateLogFile();
    print("Log file updated at: ${_logFile?.path}");
  }

  Future<void> _handleStep(String message, Future<void> Function() action) async {
    final elapsed = _stopwatch.elapsed;
    final timestamp =
        '${elapsed.inMinutes.toString().padLeft(2, '0')}:${(elapsed.inSeconds % 60).toString().padLeft(2, '0')}';
    print('$timestamp - $message');
    _log.add({'timestamp': timestamp, 'step': message});

    await _updateLogFile();

    // Update the detailed caption
    currentCaption.value = message;
    await Future.delayed(Duration(milliseconds: _random.nextInt(1000) + 700));
    await action();
    await Future.delayed(Duration(milliseconds: _random.nextInt(1500) + 1000));
  }

  Future<bool> startEmailSimulation(String textFileName) async {
    await _startLog('Gmail');
    currentAppName.value = 'Gmail';
    
    final phoneMockupState = phoneMockupKey.currentState;
    final appGridState = appGridKey.currentState;

    if (phoneMockupState == null || appGridState == null) {
      print("Error: PhoneMockupContainerState or AppGridState is null.");
      currentCaption.value = "Oops! The phone mockup isn't quite ready.";
      await _stopLog();
      return false;
    }

    await _handleStep("Let's write and send an email.", () async {
      await appGridState.performSlowRandomScroll(Duration(seconds: _random.nextInt(6) + 10));
    });

    await _handleStep("First, find and tap the Gmail app.", () async {
      await appGridState.scrollToApp('Gmail');
      final gmailAppKey = appGridState.getKeyForApp('Gmail');
      final gmailAppDetails = appGridState.getAppByName('Gmail');
      if (gmailAppKey != null && gmailAppDetails != null) {
        await gmailAppKey.currentState?.triggerOutlineAndExecute(
          () async => phoneMockupState.handleItemTap('Gmail', itemDetails: gmailAppDetails),
          specificCaption: "Opening Gmail..."
        );
      } else {
        throw Exception("Gmail app not found.");
      }
    });

    await _handleStep("Now, let's compose a new email.", () async {
       await phoneMockupState.clickComposeEmail();
    });

    await _handleStep("Writing the email for you...", () async {
       await phoneMockupState.waitForTyping();
    });
    
    await _handleStep("Email is ready. Sending now.", () async {
       await phoneMockupState.clickSendEmail();
    });
    
    await _handleStep("Waiting for 5 seconds on the email screen...", () async {
      await Future.delayed(const Duration(seconds: 5));
    });

    await _handleStep("Going back to the home screen.", () async {
        phoneMockupState.navigateHome();
    });

    await _handleStep("Doing some final human-like scrolling...", () async {
        await appGridState.performSlowRandomScroll(Duration(seconds: _random.nextInt(13) + 8)); // 8 to 20 seconds
    });

    currentCaption.value = 'Email simulation complete!';
    await _stopLog();
    currentAppName.value = '';
    return true;
  }
}
