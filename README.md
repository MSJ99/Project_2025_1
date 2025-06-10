# 팔방: 부동산 매물관리 애플리케이션

## 0. 데모 영상

## 1. 프로젝트 개요

### 1-1. 프로젝트 소개
팔방은 부동산 중개인이 등록한 매물을 체계적으로 관리할 수 있도록 돕는 모바일 애플리케이션입니다.  
팔방을 통해 부동산 중개인은 부동산 매물 목록을 쉽게 정리할 수 있고,  
고객의 요구사항에 부합하는 매물이 존재하면 자동으로 해당 매물을 추천할 수 있습니다.  
이 모든 기능이 지도 위에서 시각화되어 고객에게 직관적이고 편리하게 설명할 수 있습니다.

### 1-2. 주요 기능
- 매물 등록 • 수정 • 삭제
- 매물 리스트 • 상세정보 조회 • 검색
- 지도에서 매물 위치 시각화
- 고객 요구사항 등록 • 수정 • 삭제
- 고객 요구사항 리스트 • 상세정보 조회 • 검색
- 고객 요구사항에 부합하는 매물 추천

## 2. 시스템 아키텍처

### 2-1. 전체 구성

```
[사용자]
   ⇅
[View (Flutter UI 화면)]
   ⇅
[ViewModel (상태/로직 관리)]
   ⇅
[Model (Repository, DataSource)]
   ⇅
───────────────────────────── (HTTP 통신) ─────────────────────────────
   ⇅
[REST API (백엔드 서버, Dart)]
   ├── 사용자 인증/권한 관리 (구글 OAuth API 연동)
   ├── 매물/고객 요구사항/매칭 비즈니스 로직
   ├── 파일 업로드/다운로드 처리
   ⇅
[DB (MongoDB)]
   ⇅
[외부 API]
   ├── 지도 API (Naver)
   └── 구글 OAuth API (인증)
```

#### 설명
- **View**: Flutter로 구현된 UI. ViewModel과만 직접 통신.
- **ViewModel**: UI 상태 및 비즈니스 로직 관리. Model(Repository)와 통신하여 데이터를 가져오고, View에 전달.
- **Model**: Repository/DataSource 계층. REST API를 통해 서버와 통신.
- **REST API**: Dart로 구현된 백엔드 서버. 클라이언트의 요청을 받아 DB 및 외부 API와 연동.
- **DB**: MongoDB. 서버에서 직접 접근하여 데이터 관리.
- **외부 API**: 지도 API(네이버), 구글 OAuth API(인증).

### 2-2. 기능 흐름
1. 사용자가 앱에 접속하여 로그인 또는 회원가입을 진행합니다.
2. 로그인한 사용자는 매물 목록을 조회할 수 있습니다.
3. 검색 기능을 통해 원하는 매물을 쉽게 찾을 수 있습니다.
4. 매물 항목을 선택하면 상세 정보를 확인할 수 있습니다.
5. 매물 상세 정보 화면에서 매물 등록, 수정, 삭제가 가능합니다.
6. 지도 탭에서는 매물 위치가 지도 위에 핀으로 표시되며, 도로명 주소 검색을 통해 지도 위치를 이동할 수 있습니다.
7. 고객 요구사항을 등록, 수정, 삭제할 수 있으며, 요구사항에 맞는 매물 추천을 받을 수 있습니다.

## 3. 프로젝트 구조

### 3-1. 디렉토리 구조
```
palbang
├── client/                      # 클라이언트(Flutter)
│   ├── lib/
│   │   ├── main.dart
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── view/
│   │   │   ├── demand/
│   │   │   ├── map/
│   │   │   ├── property/
│   │   │   └── sign/
│   │   ├── viewmodel/
│   │   │   ├── demand_viewmodel.dart
│   │   │   └── property_viewmodel.dart
│   │   ├── widgets/
│   │   │   ├── demand_card.dart
│   │   │   └── property_card.dart
│   ├── assets/
│   ├── android/
│   ├── ios/
│   ├── linux/
│   ├── macos/
│   ├── web/
│   ├── windows/
│   ├── pubspec.yaml
│   └── pubspec.lock
│
└── server/                      # 서버(Dart)
    ├── bin/
    │   └── main.dart
    ├── lib/
    │   ├── main.dart
    │   ├── controllers/
    │   │   ├── auth_controller.dart
    │   │   ├── demand_controller.dart
    │   │   ├── match_controller.dart
    │   │   ├── property_controller.dart
    │   │   └── static_controller.dart
    │   ├── models/
    │   │   ├── demand_model.dart
    │   │   ├── listing_model.dart
    │   │   ├── property_model.dart
    │   │   └── user_model.dart
    │   ├── repositories/
    │   │   ├── demand_repository.dart
    │   │   ├── property_repository.dart
    │   │   └── user_repository.dart
    │   ├── routes/
    │   │   ├── auth_routes.dart
    │   │   ├── demand_routes.dart
    │   │   ├── match_routes.dart
    │   │   └── property_routes.dart
    │   ├── services/
    │   │   ├── auth_service.dart
    │   │   └── property_service.dart
    │   └── utils/
    │       ├── db.dart
    │       ├── jwt.dart
    │       └── match.dart
    ├── uploads/
    ├── test/
    ├── pubspec.yaml
    └── pubspec.lock
```

### 3-2.
- **client**가 관리하는 정보
  - 사용자 인증 상태(로그인/로그아웃)
  - 매물 목록, 매물 상세 정보
  - 고객 요구사항 목록, 상세 정보
  - 지도에서 표시할 매물 위치 정보
  - 검색 및 필터 조건, UI 상태(선택된 탭 등)
  - 사용자 입력값(폼 데이터 등)

- **server**가 관리하는 정보
  - 사용자 계정 정보(아이디, 비밀번호 해시, 권한 등)
  - 매물 데이터(주소, 가격, 면적, 옵션, 이미지 등)
  - 고객 요구사항 데이터(희망 지역, 가격대, 면적 등)
  - 매물-고객 매칭 결과
  - 데이터베이스 연결 및 관리 정보
  - 업로드된 파일(이미지 등)

- **client**와 **server**가 송수신하는 정보
  - 로그인/회원가입 요청 및 응답
  - 매물 등록/수정/삭제 요청 및 응답
  - 매물 목록/상세 정보 조회 요청 및 응답
  - 고객 요구사항 등록/수정/삭제 요청 및 응답
  - 고객 요구사항 목록/상세 정보 조회 요청 및 응답
  - 매물 추천 결과
  - 지도에서 사용할 매물 위치 데이터
  - 이미지 파일 업로드 및 다운로드

- **server**와 **server**가 송수신하는 정보
  - (본 프로젝트는 단일 서버 구조로, 서버 간 직접 통신은 없음)
  - 단, 외부 API(네이버 지도 API)와의 통신이 존재함
    - 주소-좌표 변환(Geocoding)
    - 지도 위 매물 위치 표시를 위한 지도 데이터 요청

## 4. 개발 환경 설정
- pubspec.yaml
```
# pwd: .../palbang

cd client \
&& flutter pub get \
&& cd ../server \
&& dart pub get
```