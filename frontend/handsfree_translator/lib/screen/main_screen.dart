import 'dart:io';

import 'package:flutter/material.dart';

import 'dart:math' as math;

import 'package:flutter_sound/flutter_sound.dart';
import 'package:handsfree_translator/model/audio.dart';
import 'package:handsfree_translator/widget/file_name.dart';
import 'package:handsfree_translator/widget/record_indicator.dart';
import 'package:handsfree_translator/widget/send_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  double scaleFactorUser1 = 1.0;
  double scaleFactorUser2 = 1.0;
  double? fontsizeUser1;
  double? fontsizeUser2;
  String textUser1 = "녹음 버튼을 눌러 번역을 시작하세요";
  String textUser2 = "Press the record button to start translating";
  String langUser1 = "한국어";
  String langUser2 = "English";

  final FlutterSoundPlayer _playerUser1 = FlutterSoundPlayer();
  final FlutterSoundPlayer _playerUser2 = FlutterSoundPlayer();
  final FlutterSoundRecorder _recorderUser1 = FlutterSoundRecorder();
  final FlutterSoundRecorder _recorderUser2 = FlutterSoundRecorder();
  final bool _playerUser1IsPlayed = false;
  final bool _playerUser2IsPlayed = false;
  final bool _recorderUser1IsRecord = false;
  final bool _recorderUser2IsRecord = false;
  late Directory appDirectory;

  final audioRecordBaseFilePathUser1 = "record_user1.wav";
  final audioRecordBaseFilePathUser2 = "record_user2.wav";
  String audioRecordFilePathUser1 = "";
  String audioRecordFilePathUser2 = "";
  String? audioPlayFilePathUser1 = "";
  String? audioPlayFilePathUser2 = "";

  ApiResponse? apiResponseUser1;
  ApiResponse? apiResponseUser2;

  @override
  void initState() {
    super.initState();
    _getDir();
    _playerUser1.openPlayer();
    _playerUser2.openPlayer();
    _recorderUser1.openRecorder();
    _recorderUser2.openRecorder();

    fileCheck(audioRecordFilePathUser1);
    fileCheck(audioRecordFilePathUser2);
  }

  @override
  void dispose() {
    _playerUser1.closePlayer();
    _playerUser2.closePlayer();
    _recorderUser1.closeRecorder();
    _recorderUser2.closeRecorder();
    super.dispose();
  }

  Future<void> _getDir() async {
    appDirectory = await getApplicationDocumentsDirectory();
  }

  Future<bool> _requestMicrophonePermission() async {
    var statusMicrophone = await Permission.microphone.request();
    var statusBluetooth = await Permission.bluetooth.request();
    return statusMicrophone == PermissionStatus.granted &&
        statusBluetooth == PermissionStatus.granted;
  }

  Future<bool> requestPermission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
    ].request();

    if (statuses[Permission.storage] == PermissionStatus.granted) {
      return true;
    }
    return false;
  }

  void play(player, filePath) async {
    await player.startPlayer(
        fromURI: "${appDirectory.path}/$filePath",
        // fromURI: filePath,
        codec: Codec.aacADTS,
        whenFinished: () {
          setState(() {});
        });
    setState(() {});
  }

  Future<void> stopPlayer(player) async {
    await player.stopPlayer();
  }

  Future<void> startRecording(recorder, filePath, playerIsRecord) async {
    await recorder.startRecorder(
      toFile: "${appDirectory.path}/$filePath",
      // audioSource: AudioSource.BLUETOOTH_SCO,
      // codec: Codec.aacADTS,
    );
    setState(() {
      playerIsRecord = true;
    });
  }

  Future<void> stopRecording(recorder, filePath, playerIsRecord) async {
    await recorder.stopRecorder();
    setState(() {
      playerIsRecord = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
              flex: 1,
              child: Transform.rotate(
                  angle: math.pi, child: mainCard(context, 'user2'))),
          SizedBox(
            height: 40,
            child: Row(
              children: [
                Flexible(
                  flex: 1,
                  child: midTab(context, 'user1'),
                ),
                Flexible(
                    flex: 1,
                    child: Transform.rotate(
                        angle: math.pi, child: midTab(context, 'user2'))),
              ],
            ),
          ),
          Flexible(flex: 1, child: mainCard(context, 'user1'))
        ],
      ),
    );
  }

  void _showDialog(BuildContext context, String usertype) {
    ValueNotifier<bool> isProcessing = ValueNotifier<bool>(false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Transform.rotate(
          angle: usertype == 'user1' ? 0 : math.pi,
          child: AlertDialog(
            title: ValueListenableBuilder<bool>(
              valueListenable: isProcessing,
              builder: (context, value, child) {
                return Text(
                  value ? "번역중 입니다..." : "녹음중 입니다...",
                  textAlign: TextAlign.center,
                );
              },
            ),
            content: RecordingIndicator(isProcessing: isProcessing),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor:
                      Theme.of(context).primaryColorDark, // Text Color
                ),
                child: Center(
                  child: Container(
                    width: 200,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColorDark,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Text(
                        '녹음 종료',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                onPressed: () async {
                  setState(() {
                    isProcessing.value = true;
                  });

                  if (usertype == "user1") {
                    await stopRecording(_recorderUser1,
                        audioRecordFilePathUser1, _recorderUser1IsRecord);
                    apiResponseUser1 = await uploadAudioFile(
                        "${appDirectory.path}/$audioRecordFilePathUser1",
                        'ko2en');

                    if (mounted) {
                      setState(() {
                        audioPlayFilePathUser1 =
                            apiResponseUser1?.uploadedAudioFileName ?? '';
                        audioPlayFilePathUser2 =
                            apiResponseUser1?.translatedAudioFileName ?? '';
                        textUser1 = apiResponseUser1?.transcribedText ?? '';
                        textUser2 = apiResponseUser1?.translatedText ?? '';
                      });
                    }
                  } else {
                    await stopRecording(_recorderUser2,
                        audioRecordFilePathUser2, _recorderUser2IsRecord);
                    apiResponseUser2 = await uploadAudioFile(
                        "${appDirectory.path}/$audioRecordFilePathUser2",
                        'en2ko');

                    if (mounted) {
                      setState(() {
                        audioPlayFilePathUser2 =
                            apiResponseUser2?.uploadedAudioFileName ?? '';
                        audioPlayFilePathUser1 =
                            apiResponseUser2?.translatedAudioFileName ?? '';
                        textUser2 = apiResponseUser2?.transcribedText ?? '';
                        textUser1 = apiResponseUser2?.translatedText ?? '';
                      });
                    }
                  }
                  isProcessing.value = false;
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> fileCheck(String audioFilePath) async {
    await _getDir();
    final file = File('${appDirectory.path}/$audioFilePath');
    print('${appDirectory.path}/$audioFilePath');
    if (await file.exists()) {
      await file.delete();
      print('delete');
    }
  }

  Container midTab(BuildContext context, String usertype) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: usertype == 'user1'
          ? Theme.of(context).primaryColorLight
          : Theme.of(context).primaryColorDark,
      child: Center(
        child: Text(
          usertype == 'user1' ? langUser1 : langUser2,
          textAlign: TextAlign.center,
          style: usertype == 'user1'
              ? Theme.of(context).textTheme.subtitle1
              : Theme.of(context).textTheme.subtitle2,
        ),
      ),
    );
  }

  Container mainCard(BuildContext context, String usertype) {
    return Container(
      color: usertype == 'user1'
          ? Theme.of(context).primaryColorLight
          : Theme.of(context).primaryColorDark,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Column(
          children: [
            Flexible(
              flex: 1,
              child: GestureDetector(
                onScaleUpdate: (ScaleUpdateDetails details) {
                  setState(() {
                    if (usertype == 'user1') {
                      scaleFactorUser1 =
                          (scaleFactorUser1 * details.scale.clamp(0.9, 1.05))
                              .clamp(0.5, 3.0);
                      fontsizeUser1 =
                          (Theme.of(context).textTheme.bodyText1!.fontSize! *
                              scaleFactorUser1);
                    } else {
                      scaleFactorUser2 =
                          (scaleFactorUser2 * details.scale.clamp(0.9, 1.05))
                              .clamp(0.5, 3.0);
                      fontsizeUser2 =
                          (Theme.of(context).textTheme.bodyText2!.fontSize! *
                              scaleFactorUser2);
                    }
                  });
                },
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: SingleChildScrollView(
                    child: Center(
                      child: usertype == 'user1'
                          ? Text(
                              textUser1,
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  ?.copyWith(fontSize: fontsizeUser1),
                            )
                          : Text(
                              textUser2,
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText2
                                  ?.copyWith(fontSize: fontsizeUser2),
                            ),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              height: 60,
              margin: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  MaterialButton(
                    onPressed: () async {
                      await requestPermission();
                      usertype == 'user1'
                          ? play(_playerUser1, audioPlayFilePathUser1)
                          : play(_playerUser2, audioPlayFilePathUser2);
                    },
                    color: usertype == 'user1'
                        ? Theme.of(context).primaryColorDark
                        : Theme.of(context).primaryColorLight,
                    padding: const EdgeInsets.all(15.0),
                    elevation: 1,
                    shape: const CircleBorder(),
                    child: Icon(
                      Icons.volume_up,
                      size: 35.0,
                      color: usertype == 'user1'
                          ? Theme.of(context).primaryColorLight
                          : Theme.of(context).primaryColorDark,
                    ),
                  ),
                  MaterialButton(
                    onPressed: () async {
                      await _requestMicrophonePermission();
                      await requestPermission();
                      // mPlayerIsRecord ? stopRecording() : startRecording();
                      if (usertype == 'user1') {
                        audioRecordFilePathUser1 =
                            generateFilenameWithTimestamp(
                                audioRecordBaseFilePathUser1);
                        startRecording(_recorderUser1, audioRecordFilePathUser1,
                            _recorderUser1IsRecord);
                      } else {
                        audioRecordFilePathUser2 =
                            generateFilenameWithTimestamp(
                                audioRecordBaseFilePathUser2);
                        startRecording(_recorderUser2, audioRecordFilePathUser2,
                            _recorderUser2IsRecord);
                      }
                      _showDialog(context, usertype);
                    },
                    color: usertype == 'user1'
                        ? Theme.of(context).primaryColorDark
                        : Theme.of(context).primaryColorLight,
                    padding: const EdgeInsets.all(15.0),
                    elevation: 1,
                    shape: const CircleBorder(),
                    child: Icon(
                      Icons.mic_outlined,
                      size: 35.0,
                      color: usertype == 'user1'
                          ? Theme.of(context).primaryColorLight
                          : Theme.of(context).primaryColorDark,
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
