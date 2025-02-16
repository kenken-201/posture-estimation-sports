import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:posture_estimation_sports/router.dart';
import 'package:posture_estimation_sports/ui/home/home_buttons.dart';
import 'package:posture_estimation_sports/util/utils.dart';

import '../../notifier/home/video_picker_notifier.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    logger.d('HomePage#build が呼ばれました');
    // videoPickerProvider の状態を監視
    final videoPickerState = ref.watch(videoPickerNotifierProvider);

    // ref.listen を使って videoPickerState の変化を監視し、遷移を処理
    // 状態が変更されたときに一度だけ反応するのみで要件的には必要十分
    ref.listen<AsyncValue<List<File>>>(videoPickerNotifierProvider,
        (previous, next) {
      next.when(
        data: (frames) {
          // フレームのデータが取得できた場合、遷移を試みる
          if (frames.isNotEmpty) {
            logger.d('姿勢推定画面に遷移します');
            PoseEstimationRoute($extra: frames).go(context);
          }
        },
        loading: () {
          logger.d('フレーム抽出中...');
        },
        error: (error, stack) {
          logger.e('エラーが発生しました: $error');
        },
      );
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Flutter Demo Home Page'),
      ),
      body: Center(
        child: videoPickerState.when(
          data: (frames) {
            if (frames.isEmpty) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  HomeButtons(
                    onDeviceEstimationPressed: () async {
                      logger.d('端末上で姿勢推定 ボタンがタップされました');
                      await ref
                          .read(videoPickerNotifierProvider.notifier)
                          .pickAndProcessVideo();
                    },
                    onServerEstimationPressed: () {
                      logger.d('サーバ上で姿勢推定 ボタンがタップされました');
                      const PostureEstimationPageRoute().go(context);
                    },
                  ),
                ],
              );
            } else {
              return const CircularProgressIndicator();
            }
          },
          loading: () => const CircularProgressIndicator(),
          error: (error, stack) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("エラー $error"),
              HomeButtons(
                onDeviceEstimationPressed: () async {
                  logger.d('端末上で姿勢推定 ボタンがタップされました');
                  await ref
                      .read(videoPickerNotifierProvider.notifier)
                      .pickAndProcessVideo();
                },
                onServerEstimationPressed: () {
                  logger.d('サーバ上で姿勢推定 ボタンがタップされました');
                  const PostureEstimationPageRoute().go(context);
                },
              ),
            ].withSpaceBetween(height: 20),
          ),
        ),
      ),
    );
  }
}
