# 팔방: 부동산 매물관리 애플리케이션

## 1. 프로젝트 개요

### 1-1. 프로젝트 소개
팔방은 부동산 중개사가 등록한 매물을 체계적으로 관리할 수 있도록 돕는 모바일 애플리케이션입니다.  
중개사가 부동산 매물 목록을 쉽게 정리할 수 있도록 하고,  
지도 위에 매물 목록을 시각화하여 보다 직관적으로 매물 위치를 파악하고자 합니다.

### 1-2. 주요 기능
- 회원가입 • 로그인
- 매물 리스트 조회 • 매물 상세정보 조회
- 매물 등록 • 수정 • 삭제
- 매물 검색 • 필터링
- 매물 수정 • 삭제

## 2. 시스템 아키텍처

### 2-1. 전체 구성

    [사용자]  
    ⇅  
    [모바일 앱 (Flutter)]  
    ⇅  
    [백엔드 서버 (Dart)]  
    ⇅                 ⇅  
    [DB (MongoDB)]   [지도 API (Naver)]

### 2-2. 기능 흐름
1. 사용자가 로그인을 통해 앱에 접속합니다.
2. 로그인한 사용자는 매물 목록을 조회하고, 매물을 탭하여 상세 정보를 조회합니다.
3. 특히 검색 및 필터링 기능을 이용하여 원하는 매물을 편리하게 조회합니다.
4. 매물 상세 정보 탭에서 매물 정보를 등록 • 수정 • 삭제합니다.
5. 지도 탭에서 매물 위치를 지도 위에 핀으로 표시하고, 도로명 주소 검색을 통해 화면을 이동합니다.

## 3. 프로젝트 구조

### 3-1. 디렉토리 구조
```
palbang/
├── client/                      # Flutter 기반 모바일 앱
│   ├── lib/                     # 소스 코드
│   │   ├── main.dart            # 앱 진입점
│   │   ├── screens/             # 화면 구현
│   │   ├── widgets/             # 재사용 가능한 위젯
│   │   ├── models/              # 데이터 모델
│   │   ├── services/            # API 통신 및 비즈니스 로직
│   ├── assets/                  # 이미지, 폰트 등 리소스
│   └── pubspec.yaml             # Flutter 의존성 관리
│
└── server/                      # Dart 기반 백엔드 서버
    ├── bin/
    │   └── server.dart          # 서버 실행 진입점
    ├── lib/                     # 소스 코드
    │   ├── server.dart          # 앱 진입점
    │   ├── routes/              # API 라우트 정의
    │   ├── controllers/         # 비즈니스 로직 처리
    │   ├── models/              # 데이터 모델
    │   ├── services/            # 외부 서비스 연동
    │   └── utils/               # 유틸리티 함수
    └── pubspec.yaml             # Dart 의존성 관리
```

### 3-2. 주요 디렉토리 설명
- **client/**
  - `lib/screens/`: 각 화면의 UI 구현
  - `lib/widgets/`: 재사용 가능한 UI 컴포넌트
  - `lib/models/`: 데이터 모델 정의
  - `lib/services/`: API 통신 및 비즈니스 로직 처리

- **server/**
  - `lib/routes/`: API 엔드포인트 정의
  - `lib/controllers/`: 비즈니스 로직 처리
  - `lib/models/`: 데이터베이스 모델 정의
  - `lib/services/`: 외부 서비스(지도 API 등) 연동

### 3-3. 기술 스택
- Frontend: Flutter
- Backend: Dart
- Database: MongoDB
- Map API: Naver Maps API

## 4. 개발 환경 설정

### 4-1. 필수 요구사항
- Flutter SDK
- Dart SDK
- MongoDB
- Naver Maps API 키

### 4-2. 설치 방법
1. Flutter와 Dart SDK 설치
2. MongoDB 설치 및 설정
3. Naver Maps API 키 발급
4. 프로젝트 클론
5. 의존성 패키지 설치 (client와 server 각각의 pubspec.yaml 참조)

## 5. 프로젝트 상태

### 5-1. 현재 상태
- 개발 진행 중
- 단일 클라이언트 지원

### 5-2. 향후 계획
- MVVM 아키텍처 패턴 적용 검토
- 다중 클라이언트 지원 구현
- 배포 및 CI/CD 파이프라인 구축

## 6. 라이선스
- MIT License
- 외부 라이브러리 사용 제약 없음

## 7. 문서
- 화면별 상세 요구사항: `server/README.md` 참조