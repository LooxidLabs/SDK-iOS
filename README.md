# BluetoothKit SDK & SDK Adapter

LooxidLabs LinkBand 디바이스와의 Bluetooth 연결 및 센서 데이터 수집을 위한 iOS SDK 및 SwiftUI 어댑터입니다.

> [!NOTE]
> 데모 앱을 사용해보고 싶다면 아래 링크를 참고하세요:  
> 🔗 https://github.com/LooxidLabs/iOS-LinkBandDemoApp.git  

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

> [!IMPORTANT]
> **권장 사용법**: SDK Adapter 우선 사용
> 대부분의 iOS 개발자는 **SDK를 직접 사용하지 말고 SDK Adapter를 사용하는 것을 권장**합니다.

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

### 📊 센서 데이터 수집

#### EEG (뇌전도)
- 2채널 eeg원시값(raw data)
- 전압 변환값 (µV 단위)
- 전극 접촉 상태 정보

#### PPG (광전 용적 맥파)
- 적외선(IR) 및 적색(RED) 신호

#### ACC (가속도계)
- 3축(x, y, z)
- Raw(원시값)/Motion(순수 변화량) 모드 선택 가능

#### 배터리
- 실시간 배터리 상태 업데이트

### 📈 배치 데이터 수집
- 샘플 수 기반 수집
- 시간 기반 수집 (초/분)
- 센서별 개별 설정

### 💾 데이터 관리
- CSV 형식으로 센서 데이터 저장
- JSON 형식으로 센서 데이터 저장

## 기술 스택

- **언어**: Swift 5+
- **최소 지원 버전**: Xcode 16.4+, iOS 18.4+, macOS 15.5+
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

---

## LinkBand SDK 함수 설명

> [!TIP]
> LinkBand SDK를 사용하기 위한 핵심 함수들을 카테고리별로 정리했습니다. 각 함수의 용도와 사용 시점을 명확하게 설명합니다.

### 1. 기본 연결 관리

#### 📡 블루투스 스캔
- **`bluetoothKit.startScan()`**
  - 용도: LinkBand 디바이스 검색 시작
  - 사용 시점: 연결할 디바이스를 찾고 싶을 때
  - 결과: `scannedDevices`에 발견된 디바이스 목록 업데이트

- **`bluetoothKit.stopScan()`**
  - 용도: 디바이스 검색 중지
  - 사용 시점: 원하는 디바이스를 찾았거나 스캔을 멈추고 싶을 때

- **`bluetoothKit.isScanning`**
  - 용도: 현재 스캔 중인지 확인
  - 타입: `@Published var Bool`
  - 사용 시점: UI에서 스캔 상태를 표시할 때

#### 🔗 디바이스 연결
- **`bluetoothKit.connect(to: DeviceInfo)`**
  - 용도: 특정 LinkBand 디바이스에 연결
  - 사용 시점: 스캔으로 찾은 디바이스에 연결하고 싶을 때
  - 파라미터: `DeviceInfo` - 연결할 디바이스 정보 객체

- **`bluetoothKit.disconnect()`**
  - 용도: 현재 연결된 디바이스와의 연결 해제
  - 사용 시점: 연결을 끊고 싶을 때

- **`bluetoothKit.isConnected`**
  - 용도: 디바이스 연결 상태 확인
  - 타입: `@Published var Bool`
  - 사용 시점: UI에서 연결 상태를 표시할 때

- **`bluetoothKit.connectionState`**
  - 용도: 상세한 연결 상태 확인
  - 타입: `@Published var DeviceConnectionState`
  - 상태: disconnected, scanning, connecting, connected, reconnecting, failed

### 2. 센서 데이터 수집

#### 🎯 센서 선택 (배치 모드용)
- **`batchViewModel.selectSensor(SensorKind)`**
  - 용도: 배치 수집할 센서 선택
  - 파라미터: `.eeg`, `.ppg`, `.accelerometer` 중 선택
  - 사용 시점: 배치 단위로 데이터를 수집하고 싶은 센서를 지정할 때

- **`batchViewModel.deselectSensor(SensorKind)`**
  - 용도: 선택된 센서 해제
  - 사용 시점: 특정 센서의 배치 수집을 중단하고 싶을 때

#### ▶️ 센서 활성화
- **`bluetoothKit.startSelectedSensors()`**
  - 용도: 실시간 센서 데이터 수신 시작
  - 사용 시점: 실시간으로 센서 데이터를 받기 시작하고 싶을 때

- **`batchViewModel.startSelectedSensors()`**
  - 용도: 배치 모드로 센서 데이터 수집 시작
  - 사용 시점: 설정된 조건에 따라 배치 단위로 데이터를 수집하고 싶을 때

- **`bluetoothKit.stopSelectedSensors()`**
  - 용도: 실시간 센서 데이터 수신 중지
  - 사용 시점: 실시간 데이터 수집을 멈추고 싶을 때

- **`batchViewModel.stopSelectedSensors()`**
  - 용도: 배치 센서 데이터 수집 중지
  - 사용 시점: 배치 데이터 수집을 멈추고 싶을 때

#### 📊 실시간 센서 데이터 수신
- **`bluetoothKit.latestEEGReading`**
  - 용도: 최신 EEG(뇌파) 데이터 수신
  - 타입: `@Published var EEGData?`
  - 포함 정보: 타임스탬프, 채널1/2 전압값(µV), 전극 접촉 상태

- **`bluetoothKit.latestPPGReading`**
  - 용도: 최신 PPG(맥파) 데이터 수신
  - 타입: `@Published var PPGData?`
  - 포함 정보: 타임스탬프, 적색광(red), 적외선(ir) 신호값

- **`bluetoothKit.latestAccelerometerReading`**
  - 용도: 최신 가속도계 데이터 수신
  - 타입: `@Published var AccelerometerData?`
  - 포함 정보: 타임스탬프, X/Y/Z축 가속도 값

- **`bluetoothKit.latestBatteryReading`**
  - 용도: 최신 배터리 상태 정보 수신
  - 타입: `@Published var BatteryData?`
  - 포함 정보: 배터리 레벨(0-100%)

#### 🎛️ 가속도계 모드 설정
- **`bluetoothKit.accelerometerMode`**
  - 용도: 가속도계 동작 모드 설정
  - 타입: `@Published var AccelMode`
  - 모드: `.raw`(원시값, 중력 포함), `.motion`(순수 움직임, 중력 제거)

### 3. 데이터 기록

#### 💾 CSV 및 JSON 파일 저장
- **`bluetoothKit.startRecording()`**
  - 용도: 센서 데이터를 CSV 및 JSON 파일로 저장 시작
  - 사용 시점: 데이터를 파일로 기록하고 싶을 때
  - 저장 위치: 앱 Documents 폴더
  - 저장 형식: CSV (표 형태), JSON (구조화된 데이터)

- **`bluetoothKit.stopRecording()`**
  - 용도: 중지 시점까지의 센서 데이터를 CSV 및 JSON 파일로 저장 완료
  - 사용 시점: 데이터 수집을 완료하고 파일로 저장하고 싶을 때
  - 동작: 중지 버튼을 누른 시점까지 수집된 모든 데이터를 파일에 저장 후 기록 종료

- **`bluetoothKit.isRecording`**
  - 용도: 현재 기록 중인지 확인
  - 타입: `@Published var Bool`
  - 사용 시점: UI에서 기록 상태를 표시할 때

#### 📁 파일 관리
- **`bluetoothKit.recordedFiles`**
  - 용도: 기록된 파일 목록 조회
  - 타입: `@Published var [URL]`
  - 사용 시점: 저장된 파일들을 확인하고 싶을 때

- **`bluetoothKit.recordingsDirectory`**
  - 용도: 기록 파일이 저장되는 디렉토리 경로
  - 타입: `@Published var URL?`
  - 사용 시점: 파일 저장 위치를 확인하고 싶을 때

### 4. 고급 기능 (배치 데이터 수집)

#### ⚙️ 수집 모드 설정
- **`batchViewModel.setCollectionMode(CollectionModeKind)`**
  - 용도: 배치 데이터 수집 방식 변경
  - 파라미터: `.sampleCount`(샘플 수), `.seconds`(초), `.minutes`(분)
  - 사용 시점: 배치 단위로 데이터를 수집하고 싶을 때

- **`batchViewModel.selectedCollectionMode`**
  - 용도: 현재 선택된 수집 모드 확인
  - 타입: `@Published var CollectionModeKind`

#### 📈 센서별 배치 설정 (샘플 수 기반)
- **`batchViewModel.updateSensorSampleCount(sensor, count, text)`**
  - 용도: 센서별 목표 샘플 수 설정
  - 사용 시점: 특정 개수만큼 데이터를 모아서 처리하고 싶을 때

- **`batchViewModel.getSampleCount(for: SensorKind)`**
  - 용도: 현재 설정된 샘플 수 조회
  - 반환값: `Int`

#### ⏱️ 센서별 배치 설정 (시간 기반)
- **`batchViewModel.updateSensorSeconds(sensor, seconds, text)`**
  - 용도: 센서별 수집 시간(초) 설정
  - 사용 시점: 일정 시간 동안의 데이터를 모아서 처리하고 싶을 때

- **`batchViewModel.updateSensorMinutes(sensor, minutes, text)`**
  - 용도: 센서별 수집 시간(분) 설정
  - 사용 시점: 장시간 데이터를 모아서 처리하고 싶을 때

- **`batchViewModel.getSeconds(for: SensorKind)`**
  - 용도: 현재 설정된 시간(초) 조회
  - 반환값: `Int`

- **`batchViewModel.getMinutes(for: SensorKind)`**
  - 용도: 현재 설정된 시간(분) 조회
  - 반환값: `Int`

#### 🔍 유효성 검증
- **`batchViewModel.validateSampleCount(String, for: SensorKind)`**
  - 용도: 입력된 샘플 수 값이 유효한지 검증
  - 반환값: `Bool`

- **`batchViewModel.validateSeconds(String, for: SensorKind)`**
  - 용도: 입력된 시간(초) 값이 유효한지 검증
  - 반환값: `Bool`

- **`batchViewModel.validateMinutes(String, for: SensorKind)`**
  - 용도: 입력된 시간(분) 값이 유효한지 검증
  - 반환값: `Bool`

#### 📊 예상 값 계산
- **`batchViewModel.getExpectedTime(for: SensorKind, sampleCount: Int)`**
  - 용도: 샘플 수 기반 예상 수집 시간 계산
  - 반환값: `Double` (초 단위)

- **`batchViewModel.getExpectedSamples(for: SensorKind, seconds: Int)`**
  - 용도: 시간 기반 예상 샘플 수 계산
  - 반환값: `Int`

### 5. 상태 정보

#### ℹ️ 실시간 상태 확인
- **`bluetoothKit.scannedDevices`**
  - 용도: 스캔으로 발견된 디바이스 목록
  - 타입: `@Published var [DeviceInfo]`

- **`bluetoothKit.connectionStatusDescription`**
  - 용도: 현재 연결 상태를 문자열로 표시
  - 타입: `@Published var String`

- **`batchViewModel.selectedSensors`**
  - 용도: 배치 수집용으로 선택된 센서 목록
  - 타입: `@Published var Set<SensorKind>`

- **`batchViewModel.isMonitoringActive`**
  - 용도: 배치 모니터링 활성화 상태
  - 타입: `@Published var Bool`

- **`batchViewModel.showValidationError`**
  - 용도: 유효성 검증 오류 표시 상태
  - 타입: `@Published var Bool`

> [!TIP]
> **사용 팁**
> 1. **기본 워크플로우**: 스캔 → 연결 → 센서 활성화 → 데이터 수신 → 기록 시작 → 데이터 수집 → 기록 중지(데이터 저장 완료) → 연결 해제
> 2. **실시간 vs 배치**: 실시간 데이터는 `BluetoothKitViewModel`, 배치 데이터는 `BatchDataConfigurationViewModel` 사용
> 3. **가속도계 모드**: 용도에 따라 원시값(중력 포함) 또는 순수 움직임(중력 제거) 선택
> 4. **파일 관리**: 기록된 csv/json파일은 '파일'앱의 [나의 iPhone]->[프로젝트명] 폴더에서 확인 가능
> 5. **데이터 기록**: `stopRecording()`은 데이터 수집을 중지하는 것이 아니라, 수집된 모든 데이터를 파일에 저장 완료하는 기능

---

# 링크밴드 SDK 어댑터 기능 가이드

> [!NOTE]
> LooxidLabs 링크밴드 디바이스와의 Bluetooth 연결 및 센서 데이터 수집과 기록을 위한 iOS SDK 어댑터 기능 가이드입니다.

## Overview

이 문서는 링크밴드 디바이스와 상호작용하기 위한 핵심 기능들을 설명합니다. 
모든 기능은 ``BluetoothKitViewModel``과 ``BatchDataConfigurationViewModel``을 통해 제공되며, UI와 SDK 사이의 어댑터 역할을 합니다.

## 설정 가이드

### 아이폰 설정 가이드 (실제 기기에서 진행 필요)

#### 1단계: 개발자 모드 활성화

- `설정` → `개인정보 보호 및 보안` → `개발자 모드`
- 개발자 모드를 **활성화**합니다.

> [!WARNING]
> **참고:**  
> Xcode에서 빌드를 시작한 후,  
> **"개발자 앱을 신뢰할 수 없습니다"** 또는 이와 유사한 **경고 메시지**가 나타나는 경우, 아래 2단계를 추가로 진행하세요.

#### 2단계: 개발자 앱 신뢰 설정

- `설정` → `일반` → `VPN 및 기기 관리`
- **개발자 앱** 항목에서 **본인의 Apple ID 이메일 주소**를 선택
- 하단에 표시되는 **신뢰** 버튼을 눌러 앱을 인증합니다.

### 링크밴드 SDK 어댑터 다운받기

1. 터미널을 열고 Xcode 프로젝트 루트 폴더(Assets.xcassets파일이 있는 폴더)로 이동합니다.
2. 아래 커맨드를 복사해 붙여넣으면 SDK 어댑터가 Xcode 프로젝트 안에 자동으로 생성되고 다운로드됩니다.

```bash
git init
git remote add origin https://github.com/LooxidLabs/SDK-iOS.git
git config core.sparseCheckout true
echo "SDKAdapter/" >> .git/info/sparse-checkout
git pull origin develop
```

### Xcode: 링크밴드 SDK 추가 및 권한 설정 가이드

#### 링크밴드 SDK 추가
1. File → Add Package Dependencies...
2. 레포지토리 URL 입력 (https://github.com/LooxidLabs/SDK-iOS.git)
3. Add Package 누르기
4. [프로젝트명] → Targets → [프로젝트명] → General → Frameworks, Libraries, and Embedded Content
5. "+" 선택 → BluetoothKit Package → BluetoothKit 선택 → Add 누르기

#### info.plist 권한 설정
1. [프로젝트명] → Targets → [프로젝트명] → Info → Custom iOS Target Properties
2. Key 목록 중 아무 항목 위에 커서를 올리면 나타나는 '+' 버튼을 클릭한 후, 아래의 키를 추가합니다.
   - Privacy - Bluetooth Always Usage Description
   - Privacy - Bluetooth Peripheral Usage Description
   - Application supports iTunes file sharing -> Yes로 설정
   - Supports opening documents in place -> Yes로 설정

## 기본 설정 - 코드 예시

> [!TIP]
> 아래 코드 예시들은 실제 프로젝트에서 바로 사용할 수 있는 완전한 구현체입니다. 각 섹션별로 필요한 기능만 선택하여 사용하세요.

### ContentView.swift 파일 설정

```swift
import SwiftUI
import Foundation

struct ContentView: View {
    @StateObject private var bluetoothKit = BluetoothKitViewModel()
    
    var body: some View {
        ScrollView {
            VStack {
                ScanControlView(bluetoothKit: bluetoothKit)
                DeviceListView(bluetoothKit: bluetoothKit)
                ConnectionStatusView(bluetoothKit: bluetoothKit)
                SensorActivationSampleView(bluetoothKit: bluetoothKit)
                SensorDataView(bluetoothKit: bluetoothKit)
                RecordingControlView(bluetoothKit: bluetoothKit)
            }
            .padding()
        }
    }
}
```

### 1. 링크밴드 디바이스 Bluetooth 스캔

> [!NOTE]
> 스캔 기능은 Bluetooth 권한이 필요하며, 실제 기기에서만 정상 작동합니다.

```swift
struct ScanControlView: View {
    @ObservedObject var bluetoothKit: BluetoothKitViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            if bluetoothKit.isScanning {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                
                Button("스캔 중지") {
                    bluetoothKit.stopScan()
                }
                .buttonStyle(.bordered)
                .tint(.red)
            } else {
                Button("스캔 시작") {
                    bluetoothKit.startScan()
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
            }
        }
    }
}
```

### 2. 스캔된 링크밴드 디바이스 목록 표시 및 연결
```swift
struct DeviceListView: View {
    @ObservedObject var bluetoothKit: BluetoothKitViewModel
    
    var body: some View {
        if !bluetoothKit.scannedDevices.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text("발견된 디바이스")
                    .font(.headline)
                
                ForEach(bluetoothKit.scannedDevices, id: \.id) { device in
                    DeviceRow(device: device, bluetoothKit: bluetoothKit)
                }
            }
        }
    }
}

struct DeviceRow: View {
    let device: DeviceInfo
    @ObservedObject var bluetoothKit: BluetoothKitViewModel
    
    var body: some View {
        HStack {
            Text(device.name)
                .font(.subheadline)
                .fontWeight(.medium)
            
            Spacer()
            
            Button("연결") {
                bluetoothKit.connect(to: device)
            }
            .buttonStyle(.bordered)
            .tint(.blue)
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(8)
    }
}
```

### 3. 블루투스 연결 상태 확인 및 연결 해제

```swift
struct ConnectionStatusView: View {
    @ObservedObject var bluetoothKit: BluetoothKitViewModel
    
    var body: some View {
        HStack {
            Image(systemName: connectionIcon)
                .foregroundColor(connectionColor)
                .font(.title2)
            
            VStack(alignment: .leading) {
                Text("연결 상태")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(bluetoothKit.connectionStatusDescription)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            
            Spacer()
            
            if bluetoothKit.isConnected {
                Button("연결 해제") {
                    bluetoothKit.disconnect()
                }
                .buttonStyle(.bordered)
                .tint(.red)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var connectionIcon: String {
        switch bluetoothKit.connectionState {
        case .disconnected: return "wave.3.right.circle"
        case .scanning: return "magnifyingglass.circle"
        case .connecting: return "arrow.triangle.2.circlepath.circle"
        case .connected: return "wave.3.right.circle.fill"
        case .reconnecting: return "arrow.clockwise.circle"
        case .failed: return "exclamationmark.triangle.fill"
        }
    }
    
    private var connectionColor: Color {
        switch bluetoothKit.connectionState {
        case .disconnected: return .gray
        case .scanning: return .blue
        case .connecting, .reconnecting: return .orange
        case .connected: return .green
        case .failed: return .red
        }
    }
}
```

### 4. 센서 활성화 후, 수신 데이터를 콘솔에 실시간 출력
```swift
struct SensorActivationSampleView: View {
    @ObservedObject var bluetoothKit: BluetoothKitViewModel
    // 1. BatchDataConfigurationViewModel을 사용하여 센서 제어
    @StateObject private var viewModel: BatchDataConfigurationViewModel
    
    init(bluetoothKit: BluetoothKitViewModel) {
        self.bluetoothKit = bluetoothKit
        self._viewModel = StateObject(wrappedValue: BatchDataConfigurationViewModel(bluetoothKit: bluetoothKit.bluetoothKit))
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("센서 활성화 샘플")
                .font(.title2)
                .fontWeight(.bold)
            
            controlButtonsSection
        }
        .padding()
    }
    
    // 2. 센서 선택 + 활성화 버튼 섹션
    private var controlButtonsSection: some View {
        VStack(spacing: 16) {
            
            // --- 센서 선택 부분 ---
            VStack(alignment: .leading, spacing: 8) {
                Text("센서 선택")
                    .font(.headline)
                
                HStack(spacing: 12) {
                    // EEG 센서 토글
                    SensorToggleButton(
                        title: "EEG",
                        isSelected: viewModel.selectedSensors.contains(.eeg),
                        color: .purple
                    ) {
                        toggleSensor(.eeg)
                    }
                    
                    // PPG 센서 토글
                    SensorToggleButton(
                        title: "PPG", 
                        isSelected: viewModel.selectedSensors.contains(.ppg),
                        color: .red
                    ) {
                        toggleSensor(.ppg)
                    }
                    
                    // ACC 센서 토글
                    SensorToggleButton(
                        title: "ACC",
                        isSelected: viewModel.selectedSensors.contains(.accelerometer),
                        color: .blue
                    ) {
                        toggleSensor(.accelerometer)
                    }
                }
            }
            
            // --- 모니터링 제어 버튼 ---
            HStack(spacing: 12) {
                if viewModel.isMonitoringActive {
                    // 센서 비활성화 버튼
                    Button("센서 비활성화") {
                        viewModel.stopSelectedSensors()  // ✅ 센서 비활성화
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                } else {
                    // 센서 활성화 버튼
                    Button("센서 활성화") {
                        viewModel.startSelectedSensors()  // ✅ 선택된 센서들 활성화!
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(viewModel.selectedSensors.isEmpty)  // 센서가 선택되지 않으면 비활성화
                }
                
                Spacer()
                
                // 현재 상태 표시
                if viewModel.isMonitoringActive {
                    HStack {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                        Text("활성화됨")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
            }
            
            // --- 선택된 센서 정보 표시 ---
            if !viewModel.selectedSensors.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("선택된 센서:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(viewModel.selectedSensors.map { $0.displayName }.joined(separator: ", "))
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 8)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
        )
    }
    
    // 3. 센서 토글 헬퍼 함수
    private func toggleSensor(_ sensor: SensorKind) {
        if viewModel.selectedSensors.contains(sensor) {
            viewModel.deselectSensor(sensor)  // 이미 선택된 센서면 해제
        } else {
            viewModel.selectSensor(sensor)  // 선택되지 않은 센서면 추가
        }
    }
}

// 4. 센서 토글 버튼 컴포넌트
struct SensorToggleButton: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? color : .gray)
                Text(title)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? color : .primary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? color.opacity(0.1) : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isSelected ? color : Color.gray.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}
```

### 5. 수신된 센서 데이터를 카드 형태로 앱 인터페이스에 실시간 출력

> [!TIP]
> 센서 데이터는 실시간으로 업데이트되며, 각 센서별로 독립적인 카드로 표시됩니다. 데이터가 없는 경우 해당 카드는 자동으로 숨겨집니다.

```swift
struct SensorDataView: View {
    @ObservedObject var bluetoothKit: BluetoothKitViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            // EEG 데이터 표시
            if let eegReading = bluetoothKit.latestEEGReading {
                EEGDataCard(reading: eegReading)
            }
            
            // PPG 데이터 표시
            if let ppgReading = bluetoothKit.latestPPGReading {
                PPGDataCard(reading: ppgReading)
            }
            
            // 가속도계 데이터 표시
            if let accelReading = bluetoothKit.latestAccelerometerReading {
                AccelerometerDataCard(reading: accelReading, bluetoothKit: bluetoothKit)
            }
            
            // 배터리 데이터 표시
            if let batteryReading = bluetoothKit.latestBatteryReading {
                BatteryDataCard(reading: batteryReading)
            }
        }
    }
}

struct EEGDataCard: View {
    let reading: EEGData
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "brain")
                    .foregroundColor(.purple)
                    .font(.title2)
                Text("EEG 데이터")
                    .font(.headline)
                    .foregroundColor(.purple)
                Spacer()
                Image(systemName: reading.leadOff ? "exclamationmark.triangle.fill" : "checkmark.circle.fill")
                    .foregroundColor(reading.leadOff ? .red : .green)
            }
            .frame(maxWidth: .infinity)
            
            HStack(spacing: 20) {
                VStack {
                    Text("CH1")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(String(format: "%.1f µV", reading.channel1))
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                
                VStack {
                    Text("CH2")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(String(format: "%.1f µV", reading.channel2))
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                
                VStack {
                    Text("센서 접촉 상태")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(reading.leadOff ? "접촉 안됨" : "접촉됨")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(reading.leadOff ? .red : .green)
                }
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.purple.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.purple.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct PPGDataCard: View {
    let reading: PPGData
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
                    .font(.title2)
                Text("PPG 데이터")
                    .font(.headline)
                    .foregroundColor(.red)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            
            HStack(spacing: 30) {
                VStack {
                    Text("RED")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("\(reading.red)")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                
                VStack {
                    Text("IR")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("\(reading.ir)")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.red.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.red.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct AccelerometerDataCard: View {
    let reading: AccelerometerData
    @ObservedObject var bluetoothKit: BluetoothKitViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            // 헤더 섹션
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "arrow.up.and.down.and.arrow.left.and.right")
                        .foregroundColor(.blue)
                        .font(.title2)
                    Text("ACC")
                        .font(.headline)
                        .foregroundColor(.blue)
                    Spacer()
                }
                
                // 세그먼트 컨트롤 스타일의 토글
                HStack(spacing: 0) {
                    // 원시값 버튼
                    Button(action: {
                        bluetoothKit.accelerometerMode = .raw
                    }) {
                        Text("원시값")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(bluetoothKit.accelerometerMode == .raw ? Color.blue : Color.clear)
                            )
                            .foregroundColor(bluetoothKit.accelerometerMode == .raw ? .white : .blue)
                    }
                    
                    // 움직임 버튼
                    Button(action: {
                        bluetoothKit.accelerometerMode = .motion
                    }) {
                        Text("움직임")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(bluetoothKit.accelerometerMode == .motion ? Color.blue : Color.clear)
                            )
                            .foregroundColor(bluetoothKit.accelerometerMode == .motion ? .white : .blue)
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.blue, lineWidth: 1)
                )
                
                // 설명 텍스트
                HStack {
                    Text(bluetoothKit.accelerometerMode.description)
                        .font(.caption)
                        .foregroundColor(.gray)
                    Spacer()
                }
            }
            
            // 데이터 표시 섹션
            // BluetoothKit에서 이미 모드에 따라 처리된 데이터를 그대로 표시
            HStack(spacing: 20) {
                VStack {
                    Text("X축")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("\(reading.x)")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity)
                
                VStack {
                    Text("Y축")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("\(reading.y)")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity)
                
                VStack {
                    Text("Z축")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("\(reading.z)")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.blue.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct BatteryDataCard: View {
    let reading: BatteryData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "battery.75")
                    .foregroundColor(batteryColor)
                Text("배터리 레벨")
                    .font(.headline)
                Spacer()
                Text("\(reading.level)%")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(batteryColor)
            }
            .frame(maxWidth: .infinity)
            
            ProgressView(value: Double(reading.level), total: 100.0)
                .progressViewStyle(LinearProgressViewStyle(tint: batteryColor))
                .frame(maxWidth: .infinity)
            
            Text("마지막 업데이트: \(timeFormatter.string(from: reading.timestamp))")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(batteryColor.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        return formatter
    }
    
    private var batteryColor: Color {
        if reading.level > 50 {
            return .green
        } else if reading.level > 20 {
            return .orange
        } else {
            return .red
        }
    }
}
```

### 6. 데이터 기록 (CSV 및 JSON 저장) 구현

> [!IMPORTANT]
> 데이터 기록은 센서가 활성화된 상태에서만 가능합니다. 기록된 파일은 '파일'앱의 [나의 iPhone]->[프로젝트명] 폴더에 저장됩니다.
> 
> **저장 형식**: 
> - **CSV**: 표 형태로 데이터를 정리하여 Excel 등에서 쉽게 분석 가능
> - **JSON**: 구조화된 데이터로 프로그래밍 언어에서 쉽게 파싱 가능

```swift
struct RecordingControlView: View {
    @ObservedObject var bluetoothKit: BluetoothKitViewModel
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 12) {
            // 헤더 섹션
            HStack {
                Image(systemName: bluetoothKit.isRecording ? "stop.circle.fill" : "record.circle")
                    .foregroundColor(bluetoothKit.isRecording ? .red : .blue)
                    .font(.title2)
                
                Text(bluetoothKit.isRecording ? "기록 중지" : "기록 시작")
                    .font(.headline)
                    .foregroundColor(bluetoothKit.isRecording ? .red : .blue)
                
                Spacer()
                
                if bluetoothKit.isRecording {
                    Image(systemName: "circle.fill")
                        .foregroundColor(.red)
                        .opacity(isAnimating ? 0.3 : 1.0)
                        .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isAnimating)
                        .onAppear { isAnimating = true }
                        .onDisappear { isAnimating = false }
                }
            }
            
            // 기록 시작/중지 버튼
            Button(action: {
                if bluetoothKit.isRecording {
                    bluetoothKit.stopRecording()
                } else {
                    bluetoothKit.startRecording()
                }
            }) {
                Text(bluetoothKit.isRecording ? "중지" : "시작")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(bluetoothKit.isRecording ? Color.red : Color.blue)
                    .cornerRadius(8)
            }
            .disabled(!bluetoothKit.isConnected)
            .opacity(bluetoothKit.isConnected ? 1.0 : 0.5)
            
            
            // 기록된 파일 목록
            if !bluetoothKit.recordedFiles.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("기록된 파일")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Spacer()
                        Text("저장 경로:파일->나의 iPhone->[프로젝트명]")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    // 최근 파일 3개만 표시
                    ForEach(Array(bluetoothKit.recordedFiles.prefix(3).filter { $0.pathExtension.lowercased() == "csv" }), id: \.self) { file in
                        HStack {
                            Image(systemName: "doc.text")
                                .foregroundColor(.blue)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(file.lastPathComponent)
                                    .font(.caption)
                                    .lineLimit(1)
                                Text(formatFileDate(file))
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(4)
                    }
                }
            }
        }
        .padding()
        .background(
            Color(bluetoothKit.isRecording ? .red : .blue)
                .opacity(0.1)
        )
        .cornerRadius(12)
    }
    
    private func formatFileDate(_ file: URL) -> String {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: file.path)
            if let creationDate = attributes[.creationDate] as? Date {
                let formatter = DateFormatter()
                formatter.dateStyle = .short
                formatter.timeStyle = .short
                return formatter.string(from: creationDate)
            }
        } catch {
            print("파일 날짜 가져오기 실패: \(error)")
        }
        return "날짜 없음"
    }
}
```

---

Copyright ⓒ 룩시드랩스 All rights reserved.
