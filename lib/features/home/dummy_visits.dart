class DummyVisit {
  const DummyVisit({required this.shopName, required this.visitedDate});

  final String shopName;
  final String visitedDate;
}

const List<DummyVisit> dummyVisits = [
  DummyVisit(shopName: '멘야 무사시', visitedDate: '2026.07.01'),
  DummyVisit(shopName: '이치란 라멘', visitedDate: '2026.06.28'),
];
