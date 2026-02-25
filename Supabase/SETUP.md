# Supabase Kurulum (MindStack Swift)

## 1) Auth
- Supabase Dashboard → `Authentication` → `Providers`
- `Email` / `Password` aktif olsun.

## 2) Veritabanı Şeması + RLS
- Supabase Dashboard → `SQL Editor`
- `mindstack_swift/Supabase/schema.sql` dosyasını çalıştır.

Bu SQL şunları kurar:
- Kategori → Konu(Track) → Ders → Soru → Seçenek tabloları
- Kullanıcı istatistikleri (XP, seri/streak, doğru/yanlış)
- RLS policy’ler
- `record_question_attempt` RPC (atomic kayıt + istatistik güncelleme)
- `get_user_daily_xp`, `get_user_summary`, `get_user_track_breakdown` RPC’leri (analiz ekranı için)

## 3) iOS Yapılandırma
Uygulama bu değerleri `Info.plist` içinden okur:
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`

Dosya: `mindstack_swift/MindStack/Resources/Info.plist`

## 4) Seed Data (Opsiyonel)
`schema.sql` içinde minimal seed var.

Daha zengin TR içerik için:
- `mindstack_swift/Supabase/seed_content.sql` dosyasını çalıştır.

Not: `seed_content.sql` tekrar çalıştırılabilir (upsert mantığıyla günceller).
