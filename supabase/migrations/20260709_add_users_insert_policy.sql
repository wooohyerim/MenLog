create policy "본인 프로필 생성 가능" on public.users
  for insert with check (auth.uid() = id);
