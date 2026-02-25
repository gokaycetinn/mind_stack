-- MindStack içerik seed (TR)
-- Çalıştırma: Supabase SQL Editor
-- Not: schema.sql çalıştırılmış olmalı.

begin;

-- Kategoriler (upsert)
insert into public.categories (title, description, sort)
values
  ('Algoritmalar', 'Temel algoritma ve veri yapıları', 1),
  ('Sistem Tasarımı', 'Ölçeklenebilir sistemler ve mimari', 2),
  ('Swift Temelleri', 'Swift diline hızlı giriş', 3),
  ('Git', 'Versiyon kontrol pratikleri', 4)
on conflict (title) do update set
  description = excluded.description,
  sort = excluded.sort;

-- Tracks (upsert)
with c as (select id from public.categories where title = 'Algoritmalar')
insert into public.tracks (category_id, title, description, level, sort)
select c.id, v.title, v.description, v.level, v.sort
from c
cross join (values
  ('Big‑O ve Analiz', 'Karmaşıklık analizi ve sezgiler', 'Başlangıç', 1),
  ('Diziler ve HashMap', 'En çok kullanılan veri yapıları', 'Başlangıç', 2),
  ('Sıralama ve Arama', 'Temel sıralama/arama yaklaşımları', 'Orta', 3)
) as v(title, description, level, sort)
on conflict (category_id, title) do update set
  description = excluded.description,
  level = excluded.level,
  sort = excluded.sort;

with c as (select id from public.categories where title = 'Sistem Tasarımı')
insert into public.tracks (category_id, title, description, level, sort)
select c.id, v.title, v.description, v.level, v.sort
from c
cross join (values
  ('Rate Limiting', 'Token/Leaky bucket, window stratejileri', 'Başlangıç', 1),
  ('Caching', 'Cache stratejileri ve invalidation', 'Başlangıç', 2),
  ('Pagination', 'Akıcı listeleme ve cursor tasarımı', 'Başlangıç', 3)
) as v(title, description, level, sort)
on conflict (category_id, title) do update set
  description = excluded.description,
  level = excluded.level,
  sort = excluded.sort;

with c as (select id from public.categories where title = 'Swift Temelleri')
insert into public.tracks (category_id, title, description, level, sort)
select c.id, v.title, v.description, v.level, v.sort
from c
cross join (values
  ('Swift Sözdizimi', 'Değişkenler, fonksiyonlar, optionals', 'Başlangıç', 1),
  ('SwiftUI', 'View, State, Navigation, Layout', 'Başlangıç', 2)
) as v(title, description, level, sort)
on conflict (category_id, title) do update set
  description = excluded.description,
  level = excluded.level,
  sort = excluded.sort;

with c as (select id from public.categories where title = 'Git')
insert into public.tracks (category_id, title, description, level, sort)
select c.id, v.title, v.description, v.level, v.sort
from c
cross join (values
  ('Güvenli Geri Alma', 'revert vs reset vs force push', 'Başlangıç', 1),
  ('Branch Stratejileri', 'feature branch, PR, rebase', 'Orta', 2)
) as v(title, description, level, sort)
on conflict (category_id, title) do update set
  description = excluded.description,
  level = excluded.level,
  sort = excluded.sort;

-- Lessons + Questions helper
do $$
declare
  t_id uuid;
  l_id uuid;
  q_id uuid;
begin
  -- Algoritmalar / Big‑O ve Analiz
  select id into t_id from public.tracks where title = 'Big‑O ve Analiz' limit 1;
  if t_id is not null then
    insert into public.lessons (track_id, title, content_md, est_minutes, sort)
    values (
      t_id,
      'Big‑O Temelleri',
      '# Big‑O Temelleri\n\nBig‑O, bir algoritmanın girdi büyüdükçe (**n arttıkça**) ne kadar yavaşladığını anlatır.\n\nBu, “hangi çözüm daha ölçeklenebilir?” sorusunun cevabıdır.\n\n---\n\n## En yaygın karmaşıklıklar\n\n- **O(1)**: sabit süre (ör. dizide index ile erişim)\n- **O(log n)**: yarıya bölerek arama (ör. binary search)\n- **O(n)**: tek geçiş (ör. for döngüsü)\n- **O(n log n)**: verimli sıralamalar (merge/quick ortalama)\n- **O(n²)**: iç içe döngü\n\n---\n\n## Baskın terim (dominant term)\n\nBig‑O’da genellikle:\n- sabit katsayıları (2n → n)\n- küçük terimleri (n + 10 → n)\n\ngöz ardı ederiz.\n\nÖrn: `3n + 20` → **O(n)**.\n\n---\n\n## Hızlı kontrol\n\nKendine sor:\n1) Kaç döngü var?\n2) Döngü içinde başka döngü var mı?\n3) Her adımda problem yarıya iniyor mu?\n\nİpucu: Büyük n’de baskın terim önemlidir.',
      6,
      1
    )
    on conflict (track_id, title) do update set content_md = excluded.content_md, est_minutes = excluded.est_minutes, sort = excluded.sort
    returning id into l_id;

    -- Q1
    insert into public.questions (lesson_id, type, prompt, explanation, difficulty, xp_reward, sort)
    values (
      l_id,
      'single_choice',
      'Aşağıdakilerden hangisi genellikle en hızlı büyür?',
      'n büyüdükçe n^2, n ve log n gibi terimlerden daha hızlı büyür.',
      1,
      10,
      1
    )
    on conflict (lesson_id, sort) do update set prompt = excluded.prompt, explanation = excluded.explanation, difficulty = excluded.difficulty, xp_reward = excluded.xp_reward
    returning id into q_id;

    insert into public.question_options (question_id, text, is_correct, sort)
    values
      (q_id, 'O(1)', false, 1),
      (q_id, 'O(log n)', false, 2),
      (q_id, 'O(n)', false, 3),
      (q_id, 'O(n^2)', true, 4)
    on conflict (question_id, sort) do update set text = excluded.text, is_correct = excluded.is_correct;

    -- Q2
    insert into public.questions (lesson_id, type, prompt, explanation, difficulty, xp_reward, sort)
    values (
      l_id,
      'single_choice',
      'Bir döngü içinde sabit iş yapan kodun karmaşıklığı genellikle nedir?',
      'Tek döngü çoğunlukla O(n) olur (n = eleman sayısı).',
      1,
      10,
      2
    )
    on conflict (lesson_id, sort) do update set prompt = excluded.prompt, explanation = excluded.explanation, difficulty = excluded.difficulty, xp_reward = excluded.xp_reward
    returning id into q_id;

    insert into public.question_options (question_id, text, is_correct, sort)
    values
      (q_id, 'O(1)', false, 1),
      (q_id, 'O(n)', true, 2),
      (q_id, 'O(n^2)', false, 3)
    on conflict (question_id, sort) do update set text = excluded.text, is_correct = excluded.is_correct;

    -- Q3 (true/false)
    insert into public.questions (lesson_id, type, prompt, explanation, difficulty, xp_reward, sort)
    values (
      l_id,
      'true_false',
      'Big‑O analizinde genellikle sabit katsayılar (2n vs n) göz ardı edilir.',
      'Doğru. Büyük n’de baskın terim önemlidir; sabit katsayılar çoğu zaman ihmal edilir.',
      1,
      8,
      3
    )
    on conflict (lesson_id, sort) do update set prompt = excluded.prompt, explanation = excluded.explanation, difficulty = excluded.difficulty, xp_reward = excluded.xp_reward
    returning id into q_id;

    insert into public.question_options (question_id, text, is_correct, sort)
    values
      (q_id, 'Doğru', true, 1),
      (q_id, 'Yanlış', false, 2)
    on conflict (question_id, sort) do update set text = excluded.text, is_correct = excluded.is_correct;

    -- Q4 (multi)
    insert into public.questions (lesson_id, type, prompt, explanation, difficulty, xp_reward, sort)
    values (
      l_id,
      'multi_choice',
      'Aşağıdakilerden hangileri “doğrusal” büyümeye örnektir?',
      'O(n) doğrusal büyümedir. O(1) sabittir; O(n log n) ve O(n^2) daha hızlı büyür.',
      1,
      12,
      4
    )
    on conflict (lesson_id, sort) do update set prompt = excluded.prompt, explanation = excluded.explanation, difficulty = excluded.difficulty, xp_reward = excluded.xp_reward
    returning id into q_id;

    insert into public.question_options (question_id, text, is_correct, sort)
    values
      (q_id, 'O(n)', true, 1),
      (q_id, 'O(1)', false, 2),
      (q_id, 'O(n log n)', false, 3),
      (q_id, 'O(n^2)', false, 4)
    on conflict (question_id, sort) do update set text = excluded.text, is_correct = excluded.is_correct;
  end if;

  -- Sistem Tasarımı / Rate Limiting
  select id into t_id from public.tracks where title = 'Rate Limiting' limit 1;
  if t_id is not null then
    insert into public.lessons (track_id, title, content_md, est_minutes, sort)
    values (
      t_id,
      'Rate Limiting Nedir?',
      '# Rate Limiting\n\nRate limiting, bir istemcinin belirli bir zaman aralığında yapabileceği istek sayısını sınırlar.\n\nAmaç: sistemi korumak ve adil kullanım sağlamak.\n\n---\n\n## Ne zaman gerekir?\n\n- Abuse / bot trafiği artınca\n- Ani trafik patlamalarında\n- Ücretli planlarda kota yönetiminde\n\n---\n\n## Yaygın stratejiler\n\n- **Fixed Window**: basit ama pencere geçişlerinde spike üretebilir.\n- **Sliding Window**: daha yumuşak geçiş.\n- **Token Bucket**: token biriktirir, burst trafiğe toleranslıdır.\n- **Leaky Bucket**: daha sabit akış sağlar.\n\n---\n\n## Pratik ipucu\n\nAPI için tipik cevap:\n- `429 Too Many Requests`\n- `Retry-After` header\n\nKüçük hedef: bugün Token Bucket ile Fixed Window farkını öğren, sonra quiz’e geç.',
      7,
      1
    )
    on conflict (track_id, title) do update set content_md = excluded.content_md, est_minutes = excluded.est_minutes, sort = excluded.sort
    returning id into l_id;

    insert into public.questions (lesson_id, type, prompt, explanation, difficulty, xp_reward, sort)
    values (
      l_id,
      'single_choice',
      'Rate limiting’in temel amacı nedir?',
      'Amaç, kaynakları korumak ve adil kullanım sağlamak için istekleri sınırlamaktır.',
      1,
      10,
      1
    )
    on conflict (lesson_id, sort) do update set prompt = excluded.prompt, explanation = excluded.explanation, difficulty = excluded.difficulty, xp_reward = excluded.xp_reward
    returning id into q_id;

    insert into public.question_options (question_id, text, is_correct, sort)
    values
      (q_id, 'Daha fazla log üretmek', false, 1),
      (q_id, 'İstekleri sınırlayarak servisleri korumak', true, 2),
      (q_id, 'Veritabanını tamamen kapatmak', false, 3)
    on conflict (question_id, sort) do update set text = excluded.text, is_correct = excluded.is_correct;

    -- Q2
    insert into public.questions (lesson_id, type, prompt, explanation, difficulty, xp_reward, sort)
    values (
      l_id,
      'single_choice',
      'Token Bucket hangi davranışı daha iyi destekler?',
      'Token Bucket, token biriktirdiği için kısa süreli trafik patlamalarına (burst) daha toleranslıdır.',
      1,
      10,
      2
    )
    on conflict (lesson_id, sort) do update set prompt = excluded.prompt, explanation = excluded.explanation, difficulty = excluded.difficulty, xp_reward = excluded.xp_reward
    returning id into q_id;

    insert into public.question_options (question_id, text, is_correct, sort)
    values
      (q_id, 'Burst trafiği', true, 1),
      (q_id, 'Sadece sabit hız', false, 2),
      (q_id, 'Sıfır gecikme', false, 3)
    on conflict (question_id, sort) do update set text = excluded.text, is_correct = excluded.is_correct;

    -- Q3 (true/false)
    insert into public.questions (lesson_id, type, prompt, explanation, difficulty, xp_reward, sort)
    values (
      l_id,
      'true_false',
      'Fixed Window algoritması sınır geçişlerinde “spike” (ani sıçrama) üretebilir.',
      'Doğru. Pencere değişimlerinde iki pencere arasında toplam istek sayısı kısa sürede artabilir.',
      1,
      8,
      3
    )
    on conflict (lesson_id, sort) do update set prompt = excluded.prompt, explanation = excluded.explanation, difficulty = excluded.difficulty, xp_reward = excluded.xp_reward
    returning id into q_id;

    insert into public.question_options (question_id, text, is_correct, sort)
    values
      (q_id, 'Doğru', true, 1),
      (q_id, 'Yanlış', false, 2)
    on conflict (question_id, sort) do update set text = excluded.text, is_correct = excluded.is_correct;

    -- Q4 (multi)
    insert into public.questions (lesson_id, type, prompt, explanation, difficulty, xp_reward, sort)
    values (
      l_id,
      'multi_choice',
      'Rate limiting neden uygulanır? (Birden fazla seç)',
      'Adil kullanım, servis koruması ve abuse azaltma en yaygın amaçlardır.',
      1,
      12,
      4
    )
    on conflict (lesson_id, sort) do update set prompt = excluded.prompt, explanation = excluded.explanation, difficulty = excluded.difficulty, xp_reward = excluded.xp_reward
    returning id into q_id;

    insert into public.question_options (question_id, text, is_correct, sort)
    values
      (q_id, 'Adil kullanım sağlamak', true, 1),
      (q_id, 'Abuse/DDOS etkisini azaltmak', true, 2),
      (q_id, 'Servisleri korumak', true, 3),
      (q_id, 'Her isteği her zaman kabul etmek', false, 4)
    on conflict (question_id, sort) do update set text = excluded.text, is_correct = excluded.is_correct;
  end if;
end $$;

-- Daha fazla içerik (Duolingo benzeri hızlı dersler + quiz)
do $$
declare
  t_id uuid;
  l_id uuid;
  q_id uuid;
begin
  -- Algoritmalar / Diziler ve HashMap
  select id into t_id from public.tracks where title = 'Diziler ve HashMap' limit 1;
  if t_id is not null then
    insert into public.lessons (track_id, title, content_md, est_minutes, sort)
    values (
      t_id,
      'HashMap ile Frekans Sayımı',
      '# HashMap ile Frekans Sayımı\n\nHashMap (Dictionary), anahtar→değer eşlemesi yapar.\n\nEn yaygın kullanım: **frekans sayımı**\n- Bir dizide her elemandan kaç tane var?\n- En sık tekrar eden eleman?\n\nGenel pratik:\n```swift\nvar freq: [Int: Int] = [:]\nfor x in arr { freq[x, default: 0] += 1 }\n```\n\nOrtalama erişim: **O(1)** (hash).\n\nNot: Kötü hash / çok çakışma durumunda performans düşebilir.',
      6,
      1
    )
    on conflict (track_id, title) do update set content_md = excluded.content_md, est_minutes = excluded.est_minutes, sort = excluded.sort
    returning id into l_id;

    -- Q1
    insert into public.questions (lesson_id, type, prompt, explanation, difficulty, xp_reward, sort)
    values (
      l_id,
      'single_choice',
      'HashMap’te bir anahtarın değerini bulmanın ortalama karmaşıklığı nedir?',
      'İyi bir hash dağılımında lookup işlemi ortalama O(1) kabul edilir.',
      1,
      10,
      1
    )
    on conflict (lesson_id, sort) do update set prompt = excluded.prompt, explanation = excluded.explanation, difficulty = excluded.difficulty, xp_reward = excluded.xp_reward
    returning id into q_id;

    insert into public.question_options (question_id, text, is_correct, sort)
    values
      (q_id, 'O(1)', true, 1),
      (q_id, 'O(log n)', false, 2),
      (q_id, 'O(n)', false, 3)
    on conflict (question_id, sort) do update set text = excluded.text, is_correct = excluded.is_correct;

    -- Q2 (multi)
    insert into public.questions (lesson_id, type, prompt, explanation, difficulty, xp_reward, sort)
    values (
      l_id,
      'multi_choice',
      'HashMap en çok hangi durumlarda işe yarar?',
      'Arama (key lookup), sayma (frekans) ve cache gibi senaryolarda HashMap çok kullanışlıdır.',
      1,
      12,
      2
    )
    on conflict (lesson_id, sort) do update set prompt = excluded.prompt, explanation = excluded.explanation, difficulty = excluded.difficulty, xp_reward = excluded.xp_reward
    returning id into q_id;

    insert into public.question_options (question_id, text, is_correct, sort)
    values
      (q_id, 'Bir anahtarla hızlı arama', true, 1),
      (q_id, 'Elemanları sıralı tutma', false, 2),
      (q_id, 'Frekans/kaç kere tekrar ettiğini sayma', true, 3),
      (q_id, 'Cache (önbellek) tutma', true, 4)
    on conflict (question_id, sort) do update set text = excluded.text, is_correct = excluded.is_correct;

    -- Lesson 2
    insert into public.lessons (track_id, title, content_md, est_minutes, sort)
    values (
      t_id,
      'Two Sum (İpucu: HashMap)',
      '# Two Sum\n\nHedef: dizideki iki sayının toplamı `target` olsun.\n\nKlasik yaklaşım:\n- Dizi üzerinde ilerle\n- Her `x` için `need = target - x`\n- `need` daha önce görüldüyse çözüm bulundu\n- Yoksa `x`’i HashMap’e ekle\n\nBu sayede iki döngü yerine tek geçiş: **O(n)**.',
      7,
      2
    )
    on conflict (track_id, title) do update set content_md = excluded.content_md, est_minutes = excluded.est_minutes, sort = excluded.sort
    returning id into l_id;

    insert into public.questions (lesson_id, type, prompt, explanation, difficulty, xp_reward, sort)
    values (
      l_id,
      'single_choice',
      'HashMap ile Two Sum çözümünün zaman karmaşıklığı genellikle nedir?',
      'Tek geçiş + HashMap lookup sayesinde ortalama O(n).',
      1,
      10,
      1
    )
    on conflict (lesson_id, sort) do update set prompt = excluded.prompt, explanation = excluded.explanation, difficulty = excluded.difficulty, xp_reward = excluded.xp_reward
    returning id into q_id;

    insert into public.question_options (question_id, text, is_correct, sort)
    values
      (q_id, 'O(n)', true, 1),
      (q_id, 'O(n^2)', false, 2),
      (q_id, 'O(log n)', false, 3)
    on conflict (question_id, sort) do update set text = excluded.text, is_correct = excluded.is_correct;
  end if;

  -- Algoritmalar / Sıralama ve Arama
  select id into t_id from public.tracks where title = 'Sıralama ve Arama' limit 1;
  if t_id is not null then
    insert into public.lessons (track_id, title, content_md, est_minutes, sort)
    values (
      t_id,
      'Binary Search',
      '# Binary Search\n\nBinary search, **sıralı** bir dizide arama yapar.\n\nFikir:\n- Ortayı kontrol et\n- Hedef daha küçükse sol yarıya, büyükse sağ yarıya git\n- Her adımda arama alanı yarıya iner\n\nKarmaşıklık: **O(log n)**.',
      6,
      1
    )
    on conflict (track_id, title) do update set content_md = excluded.content_md, est_minutes = excluded.est_minutes, sort = excluded.sort
    returning id into l_id;

    -- Q1 true/false
    insert into public.questions (lesson_id, type, prompt, explanation, difficulty, xp_reward, sort)
    values (
      l_id,
      'true_false',
      'Binary search çalışması için dizi sıralı olmalıdır.',
      'Evet. Binary search, arama alanını yarıya indirmek için sıralı olma varsayımına ihtiyaç duyar.',
      1,
      8,
      1
    )
    on conflict (lesson_id, sort) do update set prompt = excluded.prompt, explanation = excluded.explanation, difficulty = excluded.difficulty, xp_reward = excluded.xp_reward
    returning id into q_id;

    insert into public.question_options (question_id, text, is_correct, sort)
    values
      (q_id, 'Doğru', true, 1),
      (q_id, 'Yanlış', false, 2)
    on conflict (question_id, sort) do update set text = excluded.text, is_correct = excluded.is_correct;

    -- Q2
    insert into public.questions (lesson_id, type, prompt, explanation, difficulty, xp_reward, sort)
    values (
      l_id,
      'single_choice',
      'Binary search’in zaman karmaşıklığı nedir?',
      'Her adımda arama alanı yarıya indiği için O(log n).',
      1,
      10,
      2
    )
    on conflict (lesson_id, sort) do update set prompt = excluded.prompt, explanation = excluded.explanation, difficulty = excluded.difficulty, xp_reward = excluded.xp_reward
    returning id into q_id;

    insert into public.question_options (question_id, text, is_correct, sort)
    values
      (q_id, 'O(1)', false, 1),
      (q_id, 'O(log n)', true, 2),
      (q_id, 'O(n)', false, 3)
    on conflict (question_id, sort) do update set text = excluded.text, is_correct = excluded.is_correct;
  end if;

  -- Sistem Tasarımı / Caching
  select id into t_id from public.tracks where title = 'Caching' limit 1;
  if t_id is not null then
    insert into public.lessons (track_id, title, content_md, est_minutes, sort)
    values (
      t_id,
      'Cache Temelleri',
      '# Cache Temelleri\n\nCache, sık erişilen veriyi daha hızlı bir katmanda tutarak gecikmeyi düşürür.\n\nKavramlar:\n- **Cache hit** / **miss**\n- **TTL** (yaşam süresi)\n- **Eviction** (LRU/LFU)\n\nZor kısım: **invalidation** (cache tutarlılığı).',
      7,
      1
    )
    on conflict (track_id, title) do update set content_md = excluded.content_md, est_minutes = excluded.est_minutes, sort = excluded.sort
    returning id into l_id;

    insert into public.questions (lesson_id, type, prompt, explanation, difficulty, xp_reward, sort)
    values (
      l_id,
      'multi_choice',
      'Cache invalidation için yaygın yaklaşımlar hangileridir?',
      'TTL, explicit purge/invalidate ve write-through/write-behind stratejileri yaygındır.',
      1,
      12,
      1
    )
    on conflict (lesson_id, sort) do update set prompt = excluded.prompt, explanation = excluded.explanation, difficulty = excluded.difficulty, xp_reward = excluded.xp_reward
    returning id into q_id;

    insert into public.question_options (question_id, text, is_correct, sort)
    values
      (q_id, 'TTL kullanmak', true, 1),
      (q_id, 'Veriyi asla güncellememek', false, 2),
      (q_id, 'Güncellemede cache’i temizlemek (invalidate)', true, 3),
      (q_id, 'Write-through stratejisi', true, 4)
    on conflict (question_id, sort) do update set text = excluded.text, is_correct = excluded.is_correct;
  end if;

  -- Sistem Tasarımı / Pagination
  select id into t_id from public.tracks where title = 'Pagination' limit 1;
  if t_id is not null then
    insert into public.lessons (track_id, title, content_md, est_minutes, sort)
    values (
      t_id,
      'Cursor Pagination',
      '# Cursor Pagination\n\nBüyük listelerde performanslı sayfalama için **cursor** yaklaşımı kullanılır.\n\n- `limit`: sayfa boyutu\n- `cursor`: son görülen kaydın anahtarı (ör. created_at + id)\n\nAvantaj:\n- Offset’e göre daha stabil\n- Yeni kayıtlar eklense bile kayma daha az\n\nİpucu: Cursor alanı **sıralama** ile tutarlı olmalı.',
      6,
      1
    )
    on conflict (track_id, title) do update set content_md = excluded.content_md, est_minutes = excluded.est_minutes, sort = excluded.sort
    returning id into l_id;

    insert into public.questions (lesson_id, type, prompt, explanation, difficulty, xp_reward, sort)
    values (
      l_id,
      'single_choice',
      'Offset pagination’a göre cursor pagination’ın önemli avantajı nedir?',
      'Cursor, veri değişse bile daha stabil sonuçlar verir; offset ile sayfa kayması yaşanabilir.',
      1,
      10,
      1
    )
    on conflict (lesson_id, sort) do update set prompt = excluded.prompt, explanation = excluded.explanation, difficulty = excluded.difficulty, xp_reward = excluded.xp_reward
    returning id into q_id;

    insert into public.question_options (question_id, text, is_correct, sort)
    values
      (q_id, 'Daha stabil ve performanslı sayfalama', true, 1),
      (q_id, 'Her zaman daha az kod', false, 2),
      (q_id, 'Sıralama gerektirmez', false, 3)
    on conflict (question_id, sort) do update set text = excluded.text, is_correct = excluded.is_correct;
  end if;

  -- Swift Temelleri / Swift Sözdizimi
  select id into t_id from public.tracks where title = 'Swift Sözdizimi' limit 1;
  if t_id is not null then
    insert into public.lessons (track_id, title, content_md, est_minutes, sort)
    values (
      t_id,
      'Optionals',
      '# Optional’lar\n\nSwift’te `Optional`, bir değerin **olabileceğini veya nil** olabileceğini ifade eder.\n\nBasit örnek:\n```swift\nvar name: String? = nil\n```\n\n---\n\n## Güvenli açma yöntemleri\n\n- `if let`\n- `guard let`\n- `??` (nil coalescing)\n\n```swift\nlet title = user.title ?? \"Misafir\"\n```\n\n---\n\n## Force unwrap (`!`) neden riskli?\n\n```swift\nlet x: Int? = nil\nprint(x!) // crash\n```\n\nKural: `!` yerine önce güvenli açmayı dene.\n\n---\n\n## Mini alıştırma\n\nŞu ifadeyi yorumla:\n\n`let label = text ?? \"(boş)\"`\n\n- `text` doluysa → `label = text`\n- `text` nil ise → `label = \"(boş)\"`',
      6,
      1
    )
    on conflict (track_id, title) do update set content_md = excluded.content_md, est_minutes = excluded.est_minutes, sort = excluded.sort
    returning id into l_id;

    insert into public.questions (lesson_id, type, prompt, explanation, difficulty, xp_reward, sort)
    values (
      l_id,
      'multi_choice',
      'Optional açmak için hangileri güvenli yaklaşımlardır?',
      '`if let`, `guard let` ve `??` güvenli yaklaşımlardır. `!` force unwrap risklidir.',
      1,
      12,
      1
    )
    on conflict (lesson_id, sort) do update set prompt = excluded.prompt, explanation = excluded.explanation, difficulty = excluded.difficulty, xp_reward = excluded.xp_reward
    returning id into q_id;

    insert into public.question_options (question_id, text, is_correct, sort)
    values
      (q_id, 'if let', true, 1),
      (q_id, 'guard let', true, 2),
      (q_id, '!', false, 3),
      (q_id, '??', true, 4)
    on conflict (question_id, sort) do update set text = excluded.text, is_correct = excluded.is_correct;

    -- Q2 (true/false)
    insert into public.questions (lesson_id, type, prompt, explanation, difficulty, xp_reward, sort)
    values (
      l_id,
      'true_false',
      'Force unwrap (`!`) her zaman güvenlidir.',
      'Yanlış. Değer `nil` ise uygulama crash olur.',
      1,
      8,
      2
    )
    on conflict (lesson_id, sort) do update set prompt = excluded.prompt, explanation = excluded.explanation, difficulty = excluded.difficulty, xp_reward = excluded.xp_reward
    returning id into q_id;

    insert into public.question_options (question_id, text, is_correct, sort)
    values
      (q_id, 'Doğru', false, 1),
      (q_id, 'Yanlış', true, 2)
    on conflict (question_id, sort) do update set text = excluded.text, is_correct = excluded.is_correct;

    -- Q3
    insert into public.questions (lesson_id, type, prompt, explanation, difficulty, xp_reward, sort)
    values (
      l_id,
      'single_choice',
      '`a ?? b` ifadesi ne yapar?',
      '`a` nil değilse `a` döner; nil ise `b` döner.',
      1,
      10,
      3
    )
    on conflict (lesson_id, sort) do update set prompt = excluded.prompt, explanation = excluded.explanation, difficulty = excluded.difficulty, xp_reward = excluded.xp_reward
    returning id into q_id;

    insert into public.question_options (question_id, text, is_correct, sort)
    values
      (q_id, '`a` nil ise crash eder', false, 1),
      (q_id, '`a` nil değilse a, nil ise b döner', true, 2),
      (q_id, 'Her zaman b döner', false, 3)
    on conflict (question_id, sort) do update set text = excluded.text, is_correct = excluded.is_correct;
  end if;

  -- Swift Temelleri / SwiftUI
  select id into t_id from public.tracks where title = 'SwiftUI' limit 1;
  if t_id is not null then
    insert into public.lessons (track_id, title, content_md, est_minutes, sort)
    values (
      t_id,
      '@State ve @Binding',
      '# @State ve @Binding\n\nSwiftUI’da UI, **state** değiştikçe yeniden çizilir.\n\n---\n\n## @State\n\n`@State`, view’in **kendi** yerel state’idir.\n\n```swift\n@State private var count = 0\n```\n\n---\n\n## @Binding\n\n`@Binding`, bir üst view’deki state’i alt view’e **iki yönlü** taşır.\n\n```swift\nstruct Counter: View {\n  @Binding var count: Int\n}\n```\n\n---\n\n## @EnvironmentObject\n\nUygulama genelinde paylaşılan observable state için kullanılır.\n\nİpucu: “Bu veri birçok ekranda ortak mı?” → EnvironmentObject düşün.\n\n---\n\n## Mini kontrol\n\n- Local state → `@State`\n- Parent → Child parametre → `@Binding`\n- Global app state → `@EnvironmentObject`',
      7,
      1
    )
    on conflict (track_id, title) do update set content_md = excluded.content_md, est_minutes = excluded.est_minutes, sort = excluded.sort
    returning id into l_id;

    insert into public.questions (lesson_id, type, prompt, explanation, difficulty, xp_reward, sort)
    values (
      l_id,
      'true_false',
      '@Binding, bir üst view’deki state’i alt view’de güncellemeyi sağlar.',
      'Doğru. @Binding, state’in değerine iki yönlü erişim sağlar.',
      1,
      8,
      1
    )
    on conflict (lesson_id, sort) do update set prompt = excluded.prompt, explanation = excluded.explanation, difficulty = excluded.difficulty, xp_reward = excluded.xp_reward
    returning id into q_id;

    insert into public.question_options (question_id, text, is_correct, sort)
    values
      (q_id, 'Doğru', true, 1),
      (q_id, 'Yanlış', false, 2)
    on conflict (question_id, sort) do update set text = excluded.text, is_correct = excluded.is_correct;

    -- Q2
    insert into public.questions (lesson_id, type, prompt, explanation, difficulty, xp_reward, sort)
    values (
      l_id,
      'single_choice',
      'SwiftUI’da bir view neden yeniden çizilir?',
      'State değişince SwiftUI view’i yeniden hesaplar (re-render).',
      1,
      10,
      2
    )
    on conflict (lesson_id, sort) do update set prompt = excluded.prompt, explanation = excluded.explanation, difficulty = excluded.difficulty, xp_reward = excluded.xp_reward
    returning id into q_id;

    insert into public.question_options (question_id, text, is_correct, sort)
    values
      (q_id, 'State değiştiğinde', true, 1),
      (q_id, 'Sadece uygulama açılışında', false, 2),
      (q_id, 'Hiçbir zaman', false, 3)
    on conflict (question_id, sort) do update set text = excluded.text, is_correct = excluded.is_correct;

    -- Q3 (multi)
    insert into public.questions (lesson_id, type, prompt, explanation, difficulty, xp_reward, sort)
    values (
      l_id,
      'multi_choice',
      'Hangileri SwiftUI property wrapper’dır?',
      'SwiftUI’da state yönetimi için @State, @Binding, @EnvironmentObject gibi wrapper’lar kullanılır.',
      1,
      12,
      3
    )
    on conflict (lesson_id, sort) do update set prompt = excluded.prompt, explanation = excluded.explanation, difficulty = excluded.difficulty, xp_reward = excluded.xp_reward
    returning id into q_id;

    insert into public.question_options (question_id, text, is_correct, sort)
    values
      (q_id, '@State', true, 1),
      (q_id, '@Binding', true, 2),
      (q_id, '@EnvironmentObject', true, 3),
      (q_id, '@Override', false, 4)
    on conflict (question_id, sort) do update set text = excluded.text, is_correct = excluded.is_correct;
  end if;

  -- Git / Güvenli Geri Alma
  select id into t_id from public.tracks where title = 'Güvenli Geri Alma' limit 1;
  if t_id is not null then
    insert into public.lessons (track_id, title, content_md, est_minutes, sort)
    values (
      t_id,
      'revert vs reset',
      '# revert vs reset\n\nGit’te “geri alma” iki ana gruptur:\n- **Geçmişi koruyarak düzeltmek** (takım için güvenli)\n- **Geçmişi değiştirerek düzeltmek** (yerelde dikkatli)\n\n---\n\n## 1) `git revert`\n\n- Yeni bir commit üretir\n- Eski commit’i “tersine çevirir”\n- **Paylaşılan branch için en güvenli seçenek**\n\nÖrn:\n```bash\ngit revert HEAD\n```\n\n---\n\n## 2) `git reset --hard`\n\n- Branch’i eski bir commit’e geri taşır\n- Çalışma dizinini de geri alır\n- **Yerelde dikkatli** (commit’i kaybedebilirsin)\n\n---\n\n## 3) `git push --force`\n\n- Remote geçmişi değiştirir\n- Takımda başkalarının commit’leriyle çakışma yaratır\n- Sadece çok iyi biliyorsan ve anlaşarak kullan\n\n---\n\n## Hızlı kural\n\nRemote’da paylaşılan branch → **revert**\n\nYerelde, pushlamadıysan → reset düşünülebilir',
      6,
      1
    )
    on conflict (track_id, title) do update set content_md = excluded.content_md, est_minutes = excluded.est_minutes, sort = excluded.sort
    returning id into l_id;

    insert into public.questions (lesson_id, type, prompt, explanation, difficulty, xp_reward, sort)
    values (
      l_id,
      'single_choice',
      'Paylaşılan (remote) bir branch’te en güvenli geri alma komutu genellikle hangisidir?',
      '`git revert` geçmişi koruyarak geri alır; takım için en güvenli seçenektir.',
      1,
      10,
      1
    )
    on conflict (lesson_id, sort) do update set prompt = excluded.prompt, explanation = excluded.explanation, difficulty = excluded.difficulty, xp_reward = excluded.xp_reward
    returning id into q_id;

    insert into public.question_options (question_id, text, is_correct, sort)
    values
      (q_id, 'git revert HEAD', true, 1),
      (q_id, 'git reset --hard', false, 2),
      (q_id, 'git push --force', false, 3)
    on conflict (question_id, sort) do update set text = excluded.text, is_correct = excluded.is_correct;

    -- Q2 (true/false)
    insert into public.questions (lesson_id, type, prompt, explanation, difficulty, xp_reward, sort)
    values (
      l_id,
      'true_false',
      '`git reset --hard` geçmişi değiştirir ve geri alınması zor olabilir.',
      'Doğru. Reset, commit geçmişini yerelde değiştirir; dikkatli kullanılmalıdır.',
      1,
      8,
      2
    )
    on conflict (lesson_id, sort) do update set prompt = excluded.prompt, explanation = excluded.explanation, difficulty = excluded.difficulty, xp_reward = excluded.xp_reward
    returning id into q_id;

    insert into public.question_options (question_id, text, is_correct, sort)
    values
      (q_id, 'Doğru', true, 1),
      (q_id, 'Yanlış', false, 2)
    on conflict (question_id, sort) do update set text = excluded.text, is_correct = excluded.is_correct;

    -- Q3
    insert into public.questions (lesson_id, type, prompt, explanation, difficulty, xp_reward, sort)
    values (
      l_id,
      'single_choice',
      '`git push --force` neden tehlikelidir?',
      'Remote geçmişi değiştirir; ekipteki diğer kişilerin commit’leri kaybolabilir/çatışabilir.',
      1,
      10,
      3
    )
    on conflict (lesson_id, sort) do update set prompt = excluded.prompt, explanation = excluded.explanation, difficulty = excluded.difficulty, xp_reward = excluded.xp_reward
    returning id into q_id;

    insert into public.question_options (question_id, text, is_correct, sort)
    values
      (q_id, 'Remote geçmişi değiştirebildiği için', true, 1),
      (q_id, 'Local branch’i hızlandırdığı için', false, 2),
      (q_id, 'Disk alanını azalttığı için', false, 3)
    on conflict (question_id, sort) do update set text = excluded.text, is_correct = excluded.is_correct;

    -- Q4 (multi)
    insert into public.questions (lesson_id, type, prompt, explanation, difficulty, xp_reward, sort)
    values (
      l_id,
      'multi_choice',
      'Paylaşılan bir branch’te güvenli yaklaşım hangileridir?',
      '`revert` gibi geçmişi koruyan yaklaşımlar daha güvenlidir; force push takımda risklidir.',
      1,
      12,
      4
    )
    on conflict (lesson_id, sort) do update set prompt = excluded.prompt, explanation = excluded.explanation, difficulty = excluded.difficulty, xp_reward = excluded.xp_reward
    returning id into q_id;

    insert into public.question_options (question_id, text, is_correct, sort)
    values
      (q_id, 'git revert ile geri almak', true, 1),
      (q_id, 'PR/Review ile ilerlemek', true, 2),
      (q_id, 'git push --force ile overwrite etmek', false, 3),
      (q_id, 'Reset yapıp history’yi değiştirmek', false, 4)
    on conflict (question_id, sort) do update set text = excluded.text, is_correct = excluded.is_correct;
  end if;
end $$;

commit;
