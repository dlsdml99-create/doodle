#!/usr/bin/env bash
# Doodle 아이콘·시작 화면·마이크 권한을 안드로이드 프로젝트에 넣음
set -e
RES=android/app/src/main/res
rm -rf "$RES/mipmap-anydpi-v26"
for d in mdpi hdpi xhdpi xxhdpi xxxhdpi; do
  cp "icons/ic_launcher-$d.png" "$RES/mipmap-$d/ic_launcher.png"
  cp "icons/ic_launcher_round-$d.png" "$RES/mipmap-$d/ic_launcher_round.png"
  rm -f "$RES/mipmap-$d/ic_launcher_foreground.png"
done
for f in $(find "$RES" -name 'splash.png'); do cp icons/splash.png "$f"; done
# 대사 녹음용 마이크 권한
MAN=android/app/src/main/AndroidManifest.xml
if ! grep -q RECORD_AUDIO "$MAN"; then
  sed -i 's#</manifest>#    <uses-permission android:name="android.permission.RECORD_AUDIO" />\n    <uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />\n</manifest>#' "$MAN"
fi
echo "아이콘·권한 적용 완료"
