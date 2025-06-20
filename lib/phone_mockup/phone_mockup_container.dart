import 'dart:async'; // For Timer
import 'dart:io' show File;
import 'dart:math'; // For Random
import 'package:autobotv2email/phone_mockup/internal_toast.dart';
// For BackdropFilter

import 'package:autobotv2email/email/compose_email.dart';
import 'package:autobotv2email/phone_mockup/clickable_outline.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'app_grid.dart';
import 'notification_drawer.dart';
import '../email/primary_email.dart';

// Enum to manage the current view being displayed in the phone mockup
enum CurrentScreenView {
  appGrid,
  primaryEmail,
  composeEmail,
}

typedef AppItemTapCallback = void Function(String itemName,
    {Map<String, String>? itemDetails});

class PhoneMockupContainer extends StatefulWidget {
  final GlobalKey<AppGridState> appGridKey;
  final File? mockupWallpaperImage;
  final ValueNotifier<String> currentCaption;

  const PhoneMockupContainer({
    super.key,
    required this.appGridKey,
    this.mockupWallpaperImage,
    required this.currentCaption,
  });

  @override
  State<PhoneMockupContainer> createState() => PhoneMockupContainerState();
}

class _BatteryFillClipper extends CustomClipper<Rect> {
  final double level; // 0.0 to 1.0

  _BatteryFillClipper({required this.level});

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0.0, 0.0, size.width * level, size.height);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) {
    return (oldClipper as _BatteryFillClipper).level != level;
  }
}

class PhoneMockupContainerState extends State<PhoneMockupContainer> {
  final GlobalKey<NotificationDrawerState> _drawerKey =
      GlobalKey<NotificationDrawerState>();

  CurrentScreenView _currentScreenView = CurrentScreenView.appGrid;
  Widget _currentAppScreenWidget = const SizedBox();

  // --- Status Bar State ---
  Timer? _statusBarTimer;
  String _formattedTime = '';
  int _batteryLevel = 81;
  bool _isCharging = false;
  int _signalStrength = 4; // 1-4
  final Random _random = Random();
  DateTime _lastBatteryUpdateTime = DateTime.now();
  final Duration _batteryDropInterval = const Duration(minutes: 3);
  int _secondsUntilNextSignalChange = 3;
  
  // <<<<<<<<<<<< KEYBOARD ICON KI VISIBILITY KE LIYE NAYA STATE >>>>>>>>>>>>>>
  bool _isKeyboardIconVisible = false;

  // Keys for email screens
  final GlobalKey<ClickableOutlineState> _composeEmailFabKey = GlobalKey<ClickableOutlineState>();
  final GlobalKey<ClickableOutlineState> _sendEmailButtonKey = GlobalKey<ClickableOutlineState>();
  Completer<void>? _typingCompleter;

  // Toast state
  Widget? _currentToast;

  get currentNotificationDrawerHeight => null;

  @override
  void initState() {
    super.initState();
    _updateCurrentScreenWidget();
    _setInitialStatusBarState();
    _startStatusBarTimer();
  }

  @override
  void dispose() {
    _statusBarTimer?.cancel();
    super.dispose();
  }
  
  void _showToast(String message) {
    if (!mounted) return;
    setState(() {
      _currentToast = InternalToast(
        message: message,
        onDismissed: () {
          if (mounted) {
            setState(() {
              _currentToast = null;
            });
          }
        },
      );
    });
  }


  void _setInitialStatusBarState() {
    _formattedTime = DateFormat('h:mm:ss a').format(DateTime.now());
    _batteryLevel = 81;
    _isCharging = false;
    _signalStrength = 4;
  }

  void _startStatusBarTimer() {
    _statusBarTimer?.cancel();
    _statusBarTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      _updateStatusBar();
    });
  }

  void _updateStatusBar() {
    final now = DateTime.now();
    final newTime = DateFormat('h:mm:ss a').format(now);
    int newSignalStrength = _signalStrength;
    _secondsUntilNextSignalChange--;
    if (_secondsUntilNextSignalChange <= 0) {
      newSignalStrength = _random.nextInt(4) + 1;
      _secondsUntilNextSignalChange = _random.nextInt(3) + 2;
    }

    int newBatteryLevel = _batteryLevel;
    bool newIsCharging = _isCharging;

    if (newIsCharging) {
      if (now.difference(_lastBatteryUpdateTime).inSeconds >= 2) {
        newBatteryLevel++;
        _lastBatteryUpdateTime = now;
      }
      if (newBatteryLevel >= 100) {
        newBatteryLevel = 100;
        newIsCharging = false;
        _lastBatteryUpdateTime = now;
      }
    } else {
      if (now.difference(_lastBatteryUpdateTime) >= _batteryDropInterval) {
        newBatteryLevel--;
        _lastBatteryUpdateTime = now;
      }

      if (newBatteryLevel <= 10) {
        if (_random.nextDouble() < 0.1) { // 10% chance to start charging if battery is low
          newIsCharging = true;
          _lastBatteryUpdateTime = now;
        }
      }

      if (newBatteryLevel < 0) newBatteryLevel = 0;
    }

    if (newTime != _formattedTime ||
        newBatteryLevel != _batteryLevel ||
        newIsCharging != _isCharging ||
        newSignalStrength != _signalStrength) {
      setState(() {
        _formattedTime = newTime;
        _batteryLevel = newBatteryLevel;
        _isCharging = newIsCharging;
        _signalStrength = newSignalStrength;
      });
    }
  }

  IconData _getSignalIcon() {
    switch (_signalStrength) {
      case 1:
        return Icons.signal_cellular_alt_1_bar;
      case 2:
        return Icons.signal_cellular_alt_2_bar;
      case 3:
        return Icons.signal_cellular_alt;
      case 4:
      default:
        return Icons.signal_cellular_4_bar;
    }
  }

  Widget _getBatteryWidget() {
    if (_isCharging) {
      return Row(
        children: [
          Text("$_batteryLevel%",
              style: const TextStyle(color: Colors.greenAccent, fontSize: 12)),
          const SizedBox(width: 4),
          Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Icon(Icons.battery_full, color: Colors.grey.shade700, size: 18.0),
              ClipRect(
                clipper: _BatteryFillClipper(level: _batteryLevel / 100.0),
                child: const Icon(Icons.battery_full, color: Colors.greenAccent, size: 18.0),
              ),
            ],
          ),
        ],
      );
    } else {
      IconData batteryIcon;
      Color batteryColor = Colors.white;

      if (_batteryLevel > 95) {
        batteryIcon = Icons.battery_full;
      } else if (_batteryLevel > 80) {
        batteryIcon = Icons.battery_6_bar;
      } else if (_batteryLevel > 65) {
        batteryIcon = Icons.battery_5_bar;
      } else if (_batteryLevel > 50) {
        batteryIcon = Icons.battery_4_bar;
      } else if (_batteryLevel > 35) {
        batteryIcon = Icons.battery_3_bar;
      } else if (_batteryLevel > 20) {
        batteryIcon = Icons.battery_2_bar;
      } else if (_batteryLevel > 10) {
        batteryIcon = Icons.battery_1_bar;
      } else {
        batteryIcon = Icons.battery_alert;
        batteryColor = Colors.red;
      }

      return Row(
        children: [
          Text("$_batteryLevel%",
              style: TextStyle(color: batteryColor, fontSize: 12)),
          const SizedBox(width: 4),
          Icon(batteryIcon, color: batteryColor, size: 18),
        ],
      );
    }
  }

  Widget _buildStatusBar() {
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      color: Colors.black,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Left aligned Time
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              _formattedTime,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          
          // <<<<<<<<<<<< KEYBOARD ICON AB SIRF ZAROORAT PAR DIKHEGA >>>>>>>>>>>>>>
          if (_isKeyboardIconVisible)
            const Icon(Icons.keyboard_outlined, color: Colors.white, size: 18),

          // Right aligned Icons
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min, 
              children: [
                Icon(_getSignalIcon(), color: Colors.white, size: 18),
                const SizedBox(width: 4),
                const Icon(Icons.wifi, color: Colors.white, size: 18),
                const SizedBox(width: 4),
                _getBatteryWidget(),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // <<<<<<<<<<<< ICON VISIBILITY AB IN FUNCTIONS SE CONTROL HOGI >>>>>>>>>>>>>>
  void showPrimaryEmailScreen() {
    setState(() {
      _currentScreenView = CurrentScreenView.primaryEmail;
      _isKeyboardIconVisible = false; // Hide icon
      _updateCurrentScreenWidget();
    });
  }

  void showComposeEmailScreen() {
    setState(() {
      _currentScreenView = CurrentScreenView.composeEmail;
      _isKeyboardIconVisible = true; // Show icon
      _updateCurrentScreenWidget();
    });
  }

  Future<void> clickComposeEmail() async {
    if (_currentScreenView == CurrentScreenView.primaryEmail) {
       _composeEmailFabKey.currentState?.triggerOutlineAndAction(
        outlineDuration: const Duration(seconds: 2),
       );
    }
  }

  Future<void> waitForTyping() async {
    while (_typingCompleter == null || _typingCompleter!.isCompleted) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    await _typingCompleter!.future;
  }
  
  Future<void> clickSendEmail() async {
     if (_currentScreenView == CurrentScreenView.composeEmail) {
        _sendEmailButtonKey.currentState?.triggerOutlineAndAction(
          outlineDuration: const Duration(seconds: 5),
        );
     }
  }


  void handleItemTap(String itemName, {Map<String, String>? itemDetails}) {
    print('PhoneMockupContainer: Item tapped: $itemName');
    widget.currentCaption.value = 'Tapping on "$itemName" now.';
    if (itemName == 'Gmail') {
      showPrimaryEmailScreen();
    } else {
       print(
          "PhoneMockupContainer: Item '$itemName' is not handled.");
    }
  }

  @override
  void didUpdateWidget(PhoneMockupContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.mockupWallpaperImage != oldWidget.mockupWallpaperImage &&
        _currentScreenView == CurrentScreenView.appGrid) {
      setState(() {
        _updateCurrentScreenWidget();
      });
    }
  }

  void _updateCurrentScreenWidget() {
    switch (_currentScreenView) {
      case CurrentScreenView.appGrid:
        _currentAppScreenWidget = AppGrid(
          key: widget.appGridKey,
          phoneMockupKey: widget.key as GlobalKey<PhoneMockupContainerState>,
          wallpaperImage: widget.mockupWallpaperImage,
          onAppTap: handleItemTap,
        );
        break;
      case CurrentScreenView.primaryEmail: 
        _currentAppScreenWidget = PrimaryEmailScreen(
          onBack: () => navigateHome(),
          onCompose: () => showComposeEmailScreen(),
          composeButtonKey: _composeEmailFabKey,
        );
        break;
      case CurrentScreenView.composeEmail:
        _typingCompleter = Completer<void>();
        _currentAppScreenWidget = ComposeEmailScreen(
          onBack: () => showPrimaryEmailScreen(),
          onSend: () {
            showPrimaryEmailScreen();
            // Using addPostFrameCallback for a more reliable way to show the toast after the screen transition
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showToast("Sending email...");
            });
          },
          onTypingComplete: _typingCompleter!,
          sendButtonKey: _sendEmailButtonKey,
        );
        break;
    }
  }

  void navigateHome() {
    setState(() {
      _currentScreenView = CurrentScreenView.appGrid;
      _isKeyboardIconVisible = false; // Hide icon on home screen
      _updateCurrentScreenWidget();
      widget.currentCaption.value = ' ';
    });
  }

  void _openNotificationDrawer() {
    _drawerKey.currentState?.openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 300,
        height: 600,
        decoration: const BoxDecoration(
          color: Colors.black,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(0.0),
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _openNotificationDrawer,
                  child: _buildStatusBar(),
                ),
              ),
              const Positioned(
                top: 30,
                left: 0,
                right: 0,
                child: Divider(
                  height: 1,
                  color: Colors.white30,
                ),
              ),
              Positioned.fill(
                top: 31,
                child: Material(
                  type: MaterialType.transparency,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    child: KeyedSubtree(
                      key: ValueKey<CurrentScreenView>(_currentScreenView),
                      child: _currentAppScreenWidget,
                    ),
                  ),
                ),
              ),
              if (_currentToast != null)
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Center(child: _currentToast!),
                ),
              NotificationDrawer(key: _drawerKey),
            ],
          ),
        ),
      ),
    );
  }
}
