import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menlog/data/repositories/geocoding_repository.dart';
import 'package:menlog/data/repositories/visit_repository.dart';

final visitRepositoryProvider = Provider<VisitRepository>((ref) {
  return visitRepository;
});

final geocodingRepositoryProvider = Provider<GeocodingRepository>((ref) {
  final repository = GeocodingRepository();
  ref.onDispose(repository.dispose);
  return repository;
});
