# BluetoothKit SDK & SDK Adapter

LooxidLabs LinkBand 디바이스와의 Bluetooth 연결 및 센서 데이터 수집을 위한 iOS SDK 및 SwiftUI 어댑터입니다.

## 프로젝트 구성

이 프로젝트는 두 개의 주요 컴포넌트로 구성됩니다:

### 📦 BluetoothKit SDK
- **위치**: `Sources/BluetoothKit/`
- **역할**: LinkBand 디바이스와의 BLE 통신 및 데이터 처리
- **특징**: UI 프레임워크에 의존하지 않는 순수 비즈니스 로직

### 🎨 SDK Adapter
- **위치**: `SDKAdapter/`
- **역할**: SDK를 SwiftUI에서 사용할 수 있도록 하는 어댑터 레이어
- **특징**: MVVM 패턴 기반의 SwiftUI 바인딩 제공

## 🤔 왜 SDK Adapter를 사용해야 할까요?

### **권장 사용법**: SDK Adapter 우선 사용
대부분의 iOS 개발자는 **SDK를 직접 사용하지 말고 SDK Adapter를 사용하는 것을 권장**합니다.

### 어댑터의 핵심 장점

#### 1. **SwiftUI 최적화**
- `@Published` 프로퍼티로 자동 UI 업데이트
- Delegate 패턴을 ObservableObject로 변환
- SwiftUI 바인딩 완벽 지원

#### 2. **개발 생산성 향상**
- 복잡한 SDK 메서드를 간단한 UI 메서드로 변환
- UI 친화적 데이터 타입 제공
- 에러 처리 및 유효성 검사 자동화

#### 3. **유지보수 용이성**
- SDK 업데이트 시 UI 코드 변경 불필요
- 타입 안전성 보장
- 계층별 독립적 개발 및 테스트 가능


## 주요 기능

### 📡 Bluetooth 연결
- LinkBand 디바이스 자동 스캔 및 연결
- 자동 재연결 기능
- 연결 상태 실시간 모니터링
- 디바이스 검색 및 연결 관리

### 📊 센서 데이터 수집

#### EEG (뇌전도)
- 2채널 원시 신호(raw data)
- 전압 변환값 (µV 단위)
- 전극 접촉 상태 정보
- 24비트 ADC 원시값 제공

#### PPG (광전 용적 맥파)
- 적외선(IR) 및 적색(RED) 신호
- 심박수 및 혈류량 모니터링 지원

#### ACC (가속도계)
- 3축(x, y, z) 원시값
- 움직임 모드 전환 기능 지원
- Raw/Motion 모드 선택 가능

#### 배터리
- 잔량 모니터링 기능
- 실시간 배터리 상태 업데이트

### 📈 배치 데이터 수집
- 샘플 수 기반 수집
- 시간 기반 수집 (초/분)
- 센서별 개별 설정
- 실시간 모니터링
- 설정 가능한 수집 모드

### 💾 데이터 관리
- CSV 형식으로 센서 데이터 저장
- 기록된 파일 관리 및 공유
- 자동 파일 생성 및 저장

## 기술 스택

- **언어**: Swift 6.1+
- **최소 지원 버전**: iOS 13.0+, macOS 10.15+
- **패키지 관리**: Swift Package Manager
- **아키텍처**: 
  - SDK: 순수 비즈니스 로직 (UI 독립적)
  - Adapter: MVVM + Delegate Pattern
- **Bluetooth**: Core Bluetooth Framework

## 프로젝트 구조

```
BluetoothKit-SDK/
├── Package.swift                          # Swift Package 설정
├── Sources/BluetoothKit/                  # SDK 코어
│   ├── BluetoothKit.swift                # 메인 SDK 인터페이스
│   ├── Models.swift                      # 데이터 모델 및 타입 정의
│   ├── BluetoothManager.swift            # Bluetooth 연결 관리
│   ├── SensorDataParser.swift            # 센서 데이터 파싱
│   ├── DataRecorder.swift                # 데이터 기록 관리
│   └── BatchDataConfigurationManager.swift # 배치 데이터 설정 관리
└── SDKAdapter/                           # SwiftUI 어댑터
    ├── BluetoothKitViewModel.swift       # 메인 ViewModel
    ├── BatchDataConfigurationViewModel.swift # 배치 설정 ViewModel
    └── ViewModelTypes.swift              # UI 바인딩용 타입 정의
```

## 설치 및 사용

### Swift Package Manager 통합
프로젝트의 Package.swift 파일에 종속성을 추가하거나 Xcode에서 Package Manager를 통해 추가할 수 있습니다.

### 기본 사용법
1. **✅ 권장: SDK Adapter 사용**: SwiftUI 프로젝트에서 ViewModel을 통한 바인딩 사용
2. **배치 데이터 설정**: BatchDataConfigurationViewModel을 통한 고급 데이터 수집 설정
3. **고급 사용: SDK 직접 사용**: UIKit 프로젝트에서 BluetoothKit 클래스와 델리게이트 패턴 사용

## 개발 및 테스트

### 요구사항
- Xcode 15.0 이상
- iOS 13.0+ 디바이스 (Bluetooth 기능 필요)
- Swift 6.1+

### 빌드 및 실행
1. 프로젝트를 Xcode에서 열기
2. 타겟을 실제 iOS 디바이스로 설정 (시뮬레이터는 Bluetooth 미지원)
3. 빌드 및 실행

## API 문서

### 주요 클래스

#### BluetoothKit
메인 SDK 인터페이스. 모든 핵심 기능에 대한 접근점을 제공합니다.

#### BluetoothKitDelegate
SDK 상태 변화를 받기 위한 델리게이트 프로토콜입니다.

#### BatchDataConfigurationManager
배치 데이터 수집 설정을 관리하는 클래스입니다.

### 데이터 모델

#### EEGReading
2채널 EEG 데이터와 메타데이터를 포함합니다.

#### PPGReading
적색 및 적외선 PPG 센서 데이터를 포함합니다.

#### AccelerometerReading
3축 가속도계 데이터를 포함합니다.

#### BatteryReading
배터리 잔량 정보를 포함합니다.

---

Copyright ⓒ 룩시드랩스 All rights reserved.
