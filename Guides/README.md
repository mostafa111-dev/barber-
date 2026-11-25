# كربيجي

تطبيق ديسكتوب أوفلاين لمحل الحلاقة. افتح اختصار سطح المكتب لتشغيل `Karbigi.exe` في نافذة مستقلة. يحفظ بيانات المحل في `Database/Database.xlsx` والحسابات المشفّرة في `Database/Accounts.json`.

## النقل

أغلق التطبيق وشغّل `Create Transfer Package.cmd`، ثم انقل `Portable/Karbigi-Desktop-Transfer.zip`. على الجهاز الآخر فك الضغط وشغّل `Install Karbigi.cmd`. يحتاج Windows 10/11 64 بت، ولا يحتاج Edge أو إنترنت.

## المشروع

- `Application`: الواجهة وخط Cairo والشعار ومكتبة Excel المحلية.
- `Desktop`: طبقة التشغيل الديسكتوب والوصول الآمن لملفات البيانات.
- `Database`: بيانات المحل والحسابات.
- `Portable/Karbigi-Desktop`: ملفات التشغيل المحلية.
- `Guides`: دليل المشروع والنقل.
