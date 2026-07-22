-- 피드 좋아요/댓글 테이블 (docs/dev-logs/menlog_v2.md 4.1 참고)
create table public.visit_likes (
  id uuid primary key default gen_random_uuid(),
  visit_id uuid references public.visits(id) on delete cascade not null,
  user_id uuid references public.users(id) on delete cascade not null,
  created_at timestamptz default now() not null,
  unique (visit_id, user_id)
);

create table public.visit_comments (
  id uuid primary key default gen_random_uuid(),
  visit_id uuid references public.visits(id) on delete cascade not null,
  user_id uuid references public.users(id) on delete cascade not null,
  content text not null,
  created_at timestamptz default now() not null
);

alter table public.visit_likes enable row level security;
alter table public.visit_comments enable row level security;

grant select, insert, update, delete on public.visit_likes to authenticated;
grant select, insert, update, delete on public.visit_comments to authenticated;

-- RLS: visit_likes
create policy "그룹 멤버만 좋아요 조회 가능" on public.visit_likes
  for select using (
    exists (
      select 1 from public.visits v
      join public.group_members gm on gm.group_id = v.group_id
      where v.id = visit_likes.visit_id and gm.user_id = auth.uid()
    )
  );

create policy "본인만 좋아요 추가 가능" on public.visit_likes
  for insert with check (auth.uid() = user_id);

create policy "본인만 좋아요 취소 가능" on public.visit_likes
  for delete using (auth.uid() = user_id);

-- RLS: visit_comments
create policy "그룹 멤버만 댓글 조회 가능" on public.visit_comments
  for select using (
    exists (
      select 1 from public.visits v
      join public.group_members gm on gm.group_id = v.group_id
      where v.id = visit_comments.visit_id and gm.user_id = auth.uid()
    )
  );

create policy "본인만 댓글 작성 가능" on public.visit_comments
  for insert with check (auth.uid() = user_id);

create policy "본인만 댓글 수정 가능" on public.visit_comments
  for update using (auth.uid() = user_id);

create policy "본인만 댓글 삭제 가능" on public.visit_comments
  for delete using (auth.uid() = user_id);

-- 회원탈퇴: 본인 프로필 삭제를 허용한다.
-- users 행을 지우면 CASCADE로 visits → visit_likes/visit_comments까지
-- DB 레벨에서 원자적으로 함께 삭제된다 (탈퇴 시 완전 삭제 정책).
create policy "본인 프로필 삭제 가능" on public.users
  for delete using (auth.uid() = id);

-- visits.user_id FK가 실제로 CASCADE인지 로컬에서 확정할 수 없어 안전하게 재생성한다.
alter table public.visits drop constraint if exists visits_user_id_fkey;
alter table public.visits
  add constraint visits_user_id_fkey
  foreign key (user_id) references public.users(id) on delete cascade;
