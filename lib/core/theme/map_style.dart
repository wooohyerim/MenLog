/// 멘로그 크래프트지 감성에 맞춘 구글맵 커스텀 스타일.
/// [MenlogColors]의 팔레트를 기준으로 제작한 JSON 스타일 문자열입니다.
class MapStyle {
  const MapStyle._();

  static const String craftPaper = '''
[
  {"elementType": "geometry", "stylers": [{"color": "#EDE0CC"}]},
  {"elementType": "labels.text.fill", "stylers": [{"color": "#6B3E26"}]},
  {"elementType": "labels.text.stroke", "stylers": [{"color": "#F5D9B8"}, {"weight": 2}]},
  {"elementType": "labels.icon", "stylers": [{"visibility": "off"}]},
  {"featureType": "administrative.country", "elementType": "geometry", "stylers": [{"visibility": "off"}]},
  {"featureType": "administrative.province", "elementType": "geometry.stroke", "stylers": [{"visibility": "on"}, {"color": "#6B3E26"}, {"weight": 0.5}]},
  {"featureType": "administrative.locality", "elementType": "geometry", "stylers": [{"visibility": "off"}]},
  {"featureType": "administrative.neighborhood", "elementType": "geometry", "stylers": [{"visibility": "off"}]},
  {"featureType": "administrative.land_parcel", "stylers": [{"visibility": "off"}]},
  {"featureType": "poi", "stylers": [{"visibility": "off"}]},
  {"featureType": "road", "stylers": [{"visibility": "off"}]},
  {"featureType": "transit", "stylers": [{"visibility": "off"}]},
  {"featureType": "water", "elementType": "geometry", "stylers": [{"color": "#B9C8C2"}]}
]
''';
}
