# sig_boundaries.geojson 출처

- **원본**: [vuski/admdongkor](https://github.com/vuski/admdongkor) —
  `parquet/simplified/sgg_20260701_light.parquet` (2026-07-01 기준, EPSG:4326)
- **데이터 출처**: 통계청 통계지리정보서비스(SGIS) 공개 행정동/시군구 경계
- **라이선스**: CC BY 4.0 (원본 저장소 `LICENSE-DATA` 기준) — 출처 표시 시
  상업적 이용 포함 자유 이용 가능. 공공누리 1유형 출처표시 의무 승계.
  앱/화면 어딘가에 "vuski/admdongkor" 출처 표기 유지할 것.
- **가공 내역**(이 프로젝트에서 수행):
  - Parquet → GeoJSON 변환, `sggcd`/`sggnm`/`sidocd`/`sidonm`만 남기고
    `area` 등 불필요 속성 제거
  - Douglas-Peucker 단순화(tolerance=0.002도, 약 220m) — 정밀 경계가 아닌
    앱 내 정복맵 배경용이라 정밀도를 낮춤
  - 각 시/군/구(MultiPolygon)에서 가장 큰 파트 대비 면적 3% 미만인 소규모
    부속 도서(작은 섬)는 제외
  - 좌표 소수점 4자리(약 11m)로 반올림
  - 원본 256개 피처, 62,522개 좌표점 → 256개 피처, 24,778개 좌표점,
    507KB (원본 파케이 1MB, 무압축 GeoJSON 1.34MB 대비 축소)
