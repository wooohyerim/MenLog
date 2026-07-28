-- group_members SELECT 정책이 자기 자신(group_members)을 서브쿼리로 다시
-- 조회하는 구조라 RLS가 그 서브쿼리에도 같은 정책을 적용하려다 무한
-- 재귀에 빠진다(Postgres 42P17: infinite recursion detected in policy).
--
-- SECURITY DEFINER 함수로 멤버십 체크를 감싸면, 함수 내부 쿼리는 RLS를
-- 우회하고 실행되므로 재귀 고리가 끊긴다. Supabase에서 자기참조 RLS를
-- 다룰 때 표준적으로 쓰는 패턴이다.
create or replace function public.is_group_member(p_group_id uuid, p_user_id uuid)
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select exists (
    select 1 from public.group_members
    where group_id = p_group_id and user_id = p_user_id
  );
$$;

drop policy if exists "그룹 멤버만 멤버 목록 조회 가능" on public.group_members;

create policy "그룹 멤버만 멤버 목록 조회 가능" on public.group_members
  for select using (public.is_group_member(group_id, auth.uid()));

-- groups/visits 정책도 group_members를 서브쿼리로 참조하고 있었다.
-- group_members 자체는 이제 재귀가 없지만, 매번 group_members SELECT
-- 정책을 다시 타는 대신 같은 SECURITY DEFINER 함수를 직접 쓰도록
-- 통일해서 불필요한 정책 재평가를 줄인다.
drop policy if exists "그룹 멤버만 조회 가능" on public.groups;

create policy "그룹 멤버만 조회 가능" on public.groups
  for select using (public.is_group_member(id, auth.uid()));

drop policy if exists "그룹 멤버만 방문 기록 조회 가능" on public.visits;

create policy "그룹 멤버만 방문 기록 조회 가능" on public.visits
  for select using (public.is_group_member(group_id, auth.uid()));
