import '../datasources/property_api.dart';
import '../models/property.dart';

class PropertyRepository {
  final PropertyApi api;

  PropertyRepository(this.api);

  Future<List<Property>> getProperties() => api.fetchProperties();

  Future<bool> addProperty(Property property, {String? imagePath}) =>
      api.addProperty(property, imagePath);
  Future<bool> updateProperty(
    String id,
    Property property, {
    String? imagePath,
  }) => api.updateProperty(id, property, imagePath);
}
