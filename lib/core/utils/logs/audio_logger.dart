import 'package:ffmpeg_kit_flutter/ffprobe_kit.dart';
import 'package:collection/collection.dart';

class AudioLogger {
  static Future<void> printWavInfo(String path) async {
    final session = await FFprobeKit.getMediaInformation(path);
    final info = await session.getMediaInformation();

    if (info == null) {
      print('❌ FFprobe 실패: $path');
      return;
    }

    final stream = info.getStreams()?.firstWhereOrNull(
          (s) => s.getAllProperties()?['codec_type'] == 'audio',
    );

    if (stream == null) {
      print('❌ 오디오 스트림 없음: $path');
      return;
    }

    final props = stream.getAllProperties() ?? {};

    print('==================================================================');
    print('🎧 FFprobe 정보: $path');
    print('  • 샘플레이트: ${props['sample_rate'] ?? '알 수 없음'} Hz');
    print('  • 채널 수: ${props['channels'] ?? '알 수 없음'}');
    print('  • 코덱: ${props['codec_name'] ?? '알 수 없음'}');
    print('  • 비트레이트: ${props['bit_rate'] ?? '알 수 없음'} bps');
    print('==================================================================');
  }
}