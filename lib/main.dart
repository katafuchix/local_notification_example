import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();

  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings initializationSettingsIOS =
  DarwinInitializationSettings(
      onDidReceiveLocalNotification: onDidReceiveLocalNotification);

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  runApp(MyApp());
}

void onDidReceiveLocalNotification(
    int id, String? title, String? body, String? payload) async {
  // ここで通知を処理するコードを追加できます
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AlarmPage(),
    );
  }
}

class AlarmPage extends StatefulWidget {
  @override
  _AlarmPageState createState() => _AlarmPageState();
}

class _AlarmPageState extends State<AlarmPage> {
  DateTime? _selectedDateTime;

  Future<void> _pickDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void _setAlarm() async {
    if (_selectedDateTime == null) return;

    // 通知チャネルを設定する
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'alarm_channel', // id
      'Alarm Channel', // name
      description: 'Channel for alarm notifications', // description
      importance: Importance.max,
      sound: RawResourceAndroidNotificationSound('alarm'), // 音の設定
      playSound: true,
    );

    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      channel.id,
      channel.name,
      channelDescription: channel.description,
      importance: Importance.max,
      priority: Priority.high,
      sound: channel.sound,
      playSound: channel.playSound,
    );

    final iOSPlatformChannelSpecifics = DarwinNotificationDetails(
      //sound: 'assets/mp3/alarm.mp3',
      sound: 'loop1.wav'// サウンドファイルを指定
    );

    final platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Alarm',
      'Wake up!',
      tz.TZDateTime.from(_selectedDateTime!, tz.local),
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  void _cancelAlarm() async {
    await flutterLocalNotificationsPlugin.cancel(0); // 特定のIDの通知をキャンセル
  }

  void _cancelAllAlarms() async {
    await flutterLocalNotificationsPlugin.cancelAll(); // すべての通知をキャンセル
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Alarm Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _selectedDateTime == null
                  ? 'No date/time selected'
                  : 'Selected date/time: $_selectedDateTime',
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _pickDateTime(context),
              child: Text('Pick Date/Time'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _setAlarm,
              child: Text('Set Alarm'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _cancelAlarm,
              child: Text('Cancel Alarm'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _cancelAllAlarms,
              child: Text('Cancel All Alarms'),
            ),
          ],
        ),
      ),
    );
  }
}
