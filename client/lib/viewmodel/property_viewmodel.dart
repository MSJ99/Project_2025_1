import 'package:flutter/material.dart';
import '../data/models/property.dart';
import '../data/repositories/property_repository.dart';
import '../data/repositories/match_repository.dart';
import 'dart:developer';
import 'package:flutter_naver_map/flutter_naver_map.dart';

class PropertyViewModel extends ChangeNotifier {
  final PropertyRepository repository;
  final MatchRepository matchRepository;

  List<Property> _properties = [];
  List<Property> get properties => _properties;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Map<String, int> matchedDemandCountByPropertyId = {};

  List<NMarker> _markers = [];
  List<NMarker> get markers => _markers;
  Map<String, Property> _markerIdToProperty = {};
  Map<String, Property> get markerIdToProperty => _markerIdToProperty;

  PropertyViewModel(this.repository, this.matchRepository);

  Future<void> fetchProperties() async {
    log('[PropertyViewModel] fetchProperties() called');
    _isLoading = true;
    notifyListeners();
    _properties = await repository.getProperties();
    log(
      '[PropertyViewModel] fetchProperties() result: ' +
          _properties.length.toString() +
          '개',
    );
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchPropertiesAndMatches(MatchRepository matchRepo) async {
    _isLoading = true;
    notifyListeners();
    _properties = await repository.getProperties();
    matchedDemandCountByPropertyId.clear();
    for (final property in _properties) {
      if (property.id != null) {
        final result = await matchRepo.fetchMatchedDemandsForProperty(
          property.id!,
        );
        matchedDemandCountByPropertyId[property.id!] = result['count'] ?? 0;
      }
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addProperty(Property property, {String? imagePath}) async {
    final result = await repository.addProperty(property, imagePath: imagePath);
    await fetchPropertiesAndMatches(matchRepository);
    return result;
  }

  Future<bool> updateProperty(
    String id,
    Property property, {
    String? imagePath,
  }) async {
    final result = await repository.updateProperty(
      id,
      property,
      imagePath: imagePath,
    );
    await fetchPropertiesAndMatches(matchRepository);
    return result;
  }

  void generateMarkers({
    List<String>? matchedPropertyIds,
    String? matchedCustomerName,
  }) {
    _markers.clear();
    _markerIdToProperty.clear();
    for (var property in _properties) {
      final lat = property.lat;
      final lng = property.lng;
      if (lat == null || lng == null) continue;
      final markerId = property.address + property.contact;
      final isMatched = matchedPropertyIds?.contains(property.id) ?? false;
      final matchedCount = matchedDemandCountByPropertyId[property.id] ?? 0;
      final marker = NMarker(
        id: markerId,
        position: NLatLng(lat, lng),
        caption:
            isMatched && matchedCustomerName != null
                ? NOverlayCaption(text: '${matchedCustomerName}님 요구사항 만족')
                : (isMatched && matchedCount > 1
                    ? NOverlayCaption(text: '${matchedCount}개의 요구사항 만족')
                    : (matchedCount > 0
                        ? NOverlayCaption(text: '${matchedCount}개의 요구사항 만족')
                        : NOverlayCaption(text: ''))),
      );
      _markers.add(marker);
      _markerIdToProperty[markerId] = property;
    }
    notifyListeners();
  }
}
