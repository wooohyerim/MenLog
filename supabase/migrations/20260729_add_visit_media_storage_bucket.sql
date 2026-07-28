-- 기록하기(+) 화면의 사진/영상 업로드용 스토리지 버킷 (docs/dev-logs/menlog_v2.md 3.3 참고).
-- 경로 규칙: {user_id}/{파일명} — 업로드 정책은 본인 폴더에만 쓰기를 허용한다.
insert into storage.buckets (id, name, public)
values ('visit-media', 'visit-media', true)
on conflict (id) do nothing;

create policy "본인 폴더에만 방문 미디어 업로드 가능" on storage.objects
  for insert with check (
    bucket_id = 'visit-media'
    and auth.role() = 'authenticated'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy "방문 미디어는 공개 조회 가능" on storage.objects
  for select using (bucket_id = 'visit-media');

-- ramen_shops는 SELECT/INSERT 정책만 있고 UPDATE 정책이 없어서, 기록하기
-- 화면이 이미 등록된 매장(google_place_id 중복)에 upsert할 때
-- `ON CONFLICT DO UPDATE` 구문이 RLS에 막혀 0 rows로 조용히 실패한다.
create policy "인증 유저는 가게 정보 수정 가능" on public.ramen_shops
  for update using (auth.role() = 'authenticated')
  with check (auth.role() = 'authenticated');
