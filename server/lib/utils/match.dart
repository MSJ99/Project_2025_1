import '../models/demand_model.dart';
import '../models/property_model.dart';

bool isMatchedDemandToProperty(DemandModel demand, PropertyModel property) {
  print(
      '[매칭시도] Demand: \\${demand.customerName}, Property: \\${property.address}');
  // 1. 평수 비교
  if (demand.area != null && property.area < demand.area!) {
    print(
        '  [불일치] 평수: property.area=\\${property.area} < demand.area=\\${demand.area}');
    return false;
  }
  // 2. 거래종류 비교
  if (demand.tradeType != property.tradeType) {
    print(
        '  [불일치] 거래종류: property=\\${property.tradeType}, demand=\\${demand.tradeType}');
    return false;
  }
  // 3. 건물 유형 비교
  if (demand.propertyType.isNotEmpty &&
      property.propertyType != demand.propertyType) {
    print(
        '  [불일치] 건물유형: property=\\${property.propertyType}, demand=\\${demand.propertyType}');
    return false;
  }
  // 4. 방 개수 비교
  if (demand.roomCount != null && property.roomCount < demand.roomCount!) {
    print(
        '  [불일치] 방개수: property=\\${property.roomCount} < demand=\\${demand.roomCount}');
    return false;
  }
  // 5. 입주 가능일 비교
  if (demand.moveInDate != null && property.moveInDate != null) {
    print(
        '  [비교] 입주일: property=\\${property.moveInDate}, demand=\\${demand.moveInDate}');
    if (!property.moveInDate!.isBefore(demand.moveInDate!)) {
      print(
          '  [불일치] 입주일: property=\\${property.moveInDate} !< demand=\\${demand.moveInDate}');
      return false;
    }
  } else if (demand.moveInDate != null && property.moveInDate == null) {
    print('  [불일치] Demand는 입주일 요구, Property는 없음');
    return false;
  }
  // 6. 층수 비교
  if (demand.floor != null && demand.floor!.isNotEmpty) {
    final demandFloor = demand.floor!;
    final propertyFloor = property.floor;
    final demandFloorNum = int.tryParse(demandFloor);
    final propertyFloorNum = int.tryParse(propertyFloor);
    if (demandFloorNum != null && propertyFloorNum != null) {
      if (propertyFloorNum != demandFloorNum) {
        print(
            '  [불일치] 층수: property=\\${propertyFloorNum}, demand=\\${demandFloorNum}');
        return false;
      }
    } else if (_isFloorType(demandFloor) && _isFloorType(propertyFloor)) {
      if (!_isFloorTypeMatch(demandFloor, propertyFloor)) {
        print(
            '  [불일치] 층수타입: property=\\${propertyFloor}, demand=\\${demandFloor}');
        return false;
      }
    } else if (_isFloorType(demandFloor)) {
      if (!_isFloorTypeMatch(demandFloor, propertyFloor)) {
        print(
            '  [불일치] 층수타입: property=\\${propertyFloor}, demand=\\${demandFloor}');
        return false;
      }
    } else if (_isFloorType(propertyFloor)) {
      if (!_isFloorTypeMatch(propertyFloor, demandFloor)) {
        print(
            '  [불일치] 층수타입: property=\\${propertyFloor}, demand=\\${demandFloor}');
        return false;
      }
    } else {
      print('  [불일치] 층수: 둘 다 숫자/문자열 아님');
      return false;
    }
  }
  // 7. 가격 비교
  if (demand.tradeType == '월세') {
    if (demand.price != null && property.price > demand.price) {
      print(
          '  [불일치] 보증금: property=\\${property.price} > demand=\\${demand.price}');
      return false;
    }
    if (demand.monthlyRent != null &&
        (property.monthlyRent == null ||
            property.monthlyRent! > demand.monthlyRent!)) {
      print(
          '  [불일치] 월세: property=\\${property.monthlyRent} > demand=\\${demand.monthlyRent}');
      return false;
    }
  } else {
    if (demand.price != null && property.price > demand.price) {
      print(
          '  [불일치] 보증금: property=\\${property.price} > demand=\\${demand.price}');
      return false;
    }
  }
  // 8. 옵션 비교
  if (demand.options != null && demand.options!.isNotEmpty) {
    final propertyOptions = property.options is String
        ? (property.options as String)
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList()
        : (property.options as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [];
    print(
        '  [비교] 옵션: property=\\${propertyOptions}, demand=\\${demand.options}');
    if (!demand.options!.every((opt) => propertyOptions.contains(opt))) {
      print(
          '  [불일치] 옵션: property=\\${propertyOptions}, demand=\\${demand.options}');
      return false;
    }
  }
  print(
      '  [매칭성공] Demand: \\${demand.customerName}, Property: \\${property.address}');
  return true;
}

bool _isFloorType(String value) {
  return value == '저층' || value == '중층' || value == '고층';
}

bool _isFloorTypeMatch(String demandFloor, String propertyFloor) {
  // demandFloor, propertyFloor 둘 중 하나라도 '저층/중층/고층'이면 매핑
  int? floorNum = int.tryParse(propertyFloor);
  if (floorNum == null) floorNum = int.tryParse(demandFloor);
  if (demandFloor == '저층') {
    return _isLowFloor(propertyFloor);
  } else if (demandFloor == '중층') {
    return _isMidFloor(propertyFloor);
  } else if (demandFloor == '고층') {
    return _isHighFloor(propertyFloor);
  }
  return false;
}

bool _isLowFloor(String floor) {
  final num = int.tryParse(floor);
  return num != null && num <= 9;
}

bool _isMidFloor(String floor) {
  final num = int.tryParse(floor);
  return num != null && num >= 10 && num <= 19;
}

bool _isHighFloor(String floor) {
  final num = int.tryParse(floor);
  return num != null && num >= 20;
}
