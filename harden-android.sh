#!/usr/bin/env bash
# Capacitor가 빌드 때 새로 만드는 android/ 폴더의 보안 설정을 덤푸와 같은 수준으로 맞춰요.
# - 폰 자동 백업(구글 드라이브·기기 이전)에 아이 그림·목소리가 실리지 않게: allowBackup=false + 백업 규칙에서 모두 뺌
# - http(암호화 안 된 주소) 접속 금지: usesCleartextTraffic=false + network_security_config
# - 바깥 앱이 부를 수 있는 화면은 처음 여는 화면(런처)만, 나머지는 exported=false
set -euo pipefail
M=android/app/src/main/AndroidManifest.xml
X=android/app/src/main/res/xml
[ -f "$M" ] || { echo "AndroidManifest.xml 이 없어요"; exit 1; }
mkdir -p "$X"
cat > "$X/data_rules.xml" <<'XML'
<?xml version="1.0" encoding="utf-8"?>
<data-extraction-rules>
  <cloud-backup><exclude domain="root" path="."/><exclude domain="file" path="."/><exclude domain="database" path="."/><exclude domain="sharedpref" path="."/><exclude domain="external" path="."/></cloud-backup>
  <device-transfer><exclude domain="root" path="."/><exclude domain="file" path="."/><exclude domain="database" path="."/><exclude domain="sharedpref" path="."/><exclude domain="external" path="."/></device-transfer>
</data-extraction-rules>
XML
cat > "$X/network_security.xml" <<'XML'
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
  <base-config cleartextTrafficPermitted="false" />
</network-security-config>
XML
python3 - "$M" <<'PY'
import re,sys
p=sys.argv[1]; s=open(p,encoding='utf-8').read()
m=re.search(r'<application\b[^>]*>',s,re.S); assert m, 'no <application>'
tag=m.group(0)
for a in ['allowBackup','fullBackupContent','dataExtractionRules','usesCleartextTraffic','networkSecurityConfig']:
    tag=re.sub(r'\s+android:'+a+r'="[^"]*"','',tag)
tag=tag.replace('<application','<application\n        android:allowBackup="false"\n        android:fullBackupContent="false"\n        android:dataExtractionRules="@xml/data_rules"\n        android:usesCleartextTraffic="false"\n        android:networkSecurityConfig="@xml/network_security"',1)
s=s[:m.start()]+tag+s[m.end():]
# 런처 화면(MAIN/LAUNCHER)이 아닌 activity·service·receiver·provider 는 바깥에서 못 부르게
def fix(mm):
    t=mm.group(0)
    if 'android.intent.category.LAUNCHER' in t: return t
    head=re.match(r'<(activity|service|receiver|provider)\b[^>]*>',t,re.S).group(0)
    nh=re.sub(r'\s+android:exported="[^"]*"','',head)
    nh=re.sub(r'<(activity|service|receiver|provider)\b',lambda g:g.group(0)+' android:exported="false"',nh,count=1)
    return t.replace(head,nh,1)
s=re.sub(r'<(activity|service|receiver|provider)\b[^>]*?/>|<(activity|service|receiver|provider)\b.*?</\2>',fix,s,flags=re.S)
open(p,'w',encoding='utf-8').write(s)
PY
grep -n 'allowBackup\|exported\|Cleartext' "$M"
echo "android 보안 설정 적용됨"
