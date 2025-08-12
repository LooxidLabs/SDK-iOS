import Foundation
import CoreBluetooth

// MARK: - SensorDataParser (Pure Business Logic)

/// 센서 데이터 패킷을 구조화된 읽기값으로 파싱하는 순수 비즈니스 로직 클래스입니다.
///
/// 이 클래스는 UI 프레임워크와 완전히 독립적으로 작동하며, Bluetooth 센서로부터 수신된
/// 바이너리 데이터를 구조화된 Swift 타입으로 변환합니다. 모든 파싱 매개변수는
/// `SensorConfiguration`을 통해 설정 가능하여 다양한 센서 하드웨어를 지원합니다.
/// 
/// **주요 특징:**
/// - UI 프레임워크 의존성 없음 (순수 비즈니스 로직)
/// - 바이너리 데이터 파싱 전문화
/// - 설정 가능한 센서 매개변수 지원
/// - 엄격한 데이터 검증 및 오류 처리
/// - 타임스탬프 처리 및 샘플링 레이트 계산
/// - 멀티 샘플 패킷 지원
///
/// **지원 센서 타입:**
/// - EEG (뇌전도): 2채널, 24비트 해상도, lead-off 감지
/// - PPG (광전 용적 맥파): Red/IR LED, 심박수 모니터링용
/// - 가속도계: 3축, 모션 감지용
/// - 배터리: 배터리 레벨 모니터링
///
/// **사용법:**
/// ```swift
/// let parser = SensorDataParser(configuration: .default)
/// let eegReadings = try parser.parseEEGData(rawData)
/// let ppgReadings = try parser.parsePPGData(rawData)
/// ```
internal class SensorDataParser: @unchecked Sendable {
    private let configuration: SensorConfiguration
    
    internal init(configuration: SensorConfiguration = .default) {
        self.configuration = configuration
    }
    
    // MARK: - EEG Data Parsing
    
    /// 원시 EEG 데이터 패킷을 구조화된 읽기값으로 파싱합니다.
    ///
    /// - Parameter data: EEG 특성으로부터 수신된 원시 바이너리 데이터
    /// - Returns: 패킷에서 추출된 EEG 읽기값 배열
    /// - Throws: 패킷 형식이 잘못된 경우 `BluetoothKitError.dataParsingFailed`
    internal func parseEEGData(_ data: Data) throws -> [EEGReading] {
        let bytes = [UInt8](data)
        
        // 최소 패킷 크기 확인 (헤더 + 최소 하나의 샘플)
        let headerSize = 4
        guard bytes.count >= headerSize + configuration.eegSampleSize else {
            throw BluetoothKitError.dataParsingFailed("EEG 패킷이 너무 짧습니다: \(bytes.count) bytes (최소: \(headerSize + configuration.eegSampleSize))")
        }
        
        // 실제 이용 가능한 샘플 수 계산
        let dataWithoutHeader = bytes.count - headerSize
        let actualSampleCount = dataWithoutHeader / configuration.eegSampleSize
        let expectedSampleCount = (configuration.eegPacketSize - headerSize) / configuration.eegSampleSize
        
        // 패킷 크기가 예상과 다른 경우 로그 출력
        if bytes.count != configuration.eegPacketSize {
            print("⚠️ EEG 패킷 크기: \(bytes.count) bytes (예상: \(configuration.eegPacketSize)), \(actualSampleCount) 샘플 처리 중 (예상: \(expectedSampleCount))")
        }
        
        // 패킷 헤더에서 타임스탬프 추출
        let timeRaw = UInt32(bytes[3]) << 24 | UInt32(bytes[2]) << 16 | UInt32(bytes[1]) << 8 | UInt32(bytes[0])
        var timestamp = Double(timeRaw) / configuration.timestampDivisor / configuration.millisecondsToSeconds
        
        var readings: [EEGReading] = []
        
        // 이용 가능한 샘플만 파싱
        for sampleIndex in 0..<actualSampleCount {
            let i = headerSize + (sampleIndex * configuration.eegSampleSize)
            
            // 배열 경계를 넘지 않도록 확인
            guard i + configuration.eegSampleSize <= bytes.count else {
                print("⚠️ EEG 샘플 \(sampleIndex + 1) 불완전, 나머지 샘플 건너뜀")
                break
            }
            
            // lead-off (1 바이트) - 센서 연결 상태
            let leadOffRaw = bytes[i]
            let leadOffNormalized = leadOffRaw > 0  // 리드가 연결 해제된 경우 true
            
            // CH1: 3 바이트 (Big Endian)
            var ch1Raw = Int32(bytes[i+1]) << 16 | Int32(bytes[i+2]) << 8 | Int32(bytes[i+3])
            
            // CH2: 3 바이트 (Big Endian)  
            var ch2Raw = Int32(bytes[i+4]) << 16 | Int32(bytes[i+5]) << 8 | Int32(bytes[i+6])
            
            // 24비트 부호 있는 값 처리 (MSB 부호 확장)
            if (ch1Raw & 0x800000) != 0 {
                ch1Raw -= 0x1000000
            }
            if (ch2Raw & 0x800000) != 0 {
                ch2Raw -= 0x1000000
            }
            
            // 설정 매개변수를 사용하여 전압으로 변환
            let ch1uV = Double(ch1Raw) * configuration.eegVoltageReference / configuration.eegGain / configuration.eegResolution * configuration.microVoltMultiplier
            let ch2uV = Double(ch2Raw) * configuration.eegVoltageReference / configuration.eegGain / configuration.eegResolution * configuration.microVoltMultiplier
            
            let reading = EEGReading(
                channel1: ch1uV,
                channel2: ch2uV,
                ch1Raw: ch1Raw,
                ch2Raw: ch2Raw,
                leadOff: leadOffNormalized,
                timestamp: Date(timeIntervalSince1970: timestamp)
            )
            
            readings.append(reading)
            
            // 다음 샘플을 위해 타임스탬프 증가
            timestamp += 1.0 / configuration.eegSampleRate
        }
        
        return readings
    }
    
    // MARK: - PPG Data Parsing
    
    /// 원시 PPG 데이터 패킷을 구조화된 읽기값으로 파싱합니다.
    ///
    /// - Parameter data: PPG 특성으로부터 수신된 원시 바이너리 데이터
    /// - Returns: 패킷에서 추출된 PPG 읽기값 배열
    /// - Throws: 패킷 형식이 잘못된 경우 `BluetoothKitError.dataParsingFailed`
    internal func parsePPGData(_ data: Data) throws -> [PPGReading] {
        let bytes = [UInt8](data)
        
        // 최소 패킷 크기 확인 (헤더 + 최소 하나의 샘플)
        let headerSize = 4
        guard bytes.count >= headerSize + configuration.ppgSampleSize else {
            throw BluetoothKitError.dataParsingFailed("PPG 패킷이 너무 짧습니다: \(bytes.count) bytes (최소: \(headerSize + configuration.ppgSampleSize))")
        }
        
        // 실제 이용 가능한 샘플 수 계산
        let dataWithoutHeader = bytes.count - headerSize
        let actualSampleCount = dataWithoutHeader / configuration.ppgSampleSize
        let expectedSampleCount = (configuration.ppgPacketSize - headerSize) / configuration.ppgSampleSize
        
        // 패킷 크기가 예상과 다른 경우 로그 출력
        if bytes.count != configuration.ppgPacketSize {
            print("⚠️ PPG 패킷 크기: \(bytes.count) bytes (예상: \(configuration.ppgPacketSize)), \(actualSampleCount) 샘플 처리 중 (예상: \(expectedSampleCount))")
        }

        // 패킷 헤더에서 타임스탬프 추출
        let timeRaw = UInt32(bytes[3]) << 24 | UInt32(bytes[2]) << 16 | UInt32(bytes[1]) << 8 | UInt32(bytes[0])
        var timestamp = Double(timeRaw) / configuration.timestampDivisor / configuration.millisecondsToSeconds

        var readings: [PPGReading] = []

        // 이용 가능한 샘플만 파싱
        for sampleIndex in 0..<actualSampleCount {
            let i = headerSize + (sampleIndex * configuration.ppgSampleSize)
            
            // 배열 경계를 넘지 않도록 확인
            guard i + configuration.ppgSampleSize <= bytes.count else {
                print("⚠️ PPG 샘플 \(sampleIndex + 1) 불완전, 나머지 샘플 건너뜀")
                break
            }
            
            let red = Int(bytes[i]) << 16 | Int(bytes[i+1]) << 8 | Int(bytes[i+2])
            let ir  = Int(bytes[i+3]) << 16 | Int(bytes[i+4]) << 8 | Int(bytes[i+5])
            
            let reading = PPGReading(
                red: red,
                ir: ir,
                timestamp: Date(timeIntervalSince1970: timestamp)
            )
            
            readings.append(reading)
            
            // 다음 샘플을 위해 타임스탬프 증가
            timestamp += 1.0 / configuration.ppgSampleRate
        }
        
        return readings
    }
    
    // MARK: - Accelerometer Data Parsing
    
    /// 원시 가속도계 데이터 패킷을 구조화된 읽기값으로 파싱합니다.
    ///
    /// - Parameter data: 가속도계 특성으로부터 수신된 원시 바이너리 데이터
    /// - Returns: 패킷에서 추출된 가속도계 읽기값 배열
    /// - Throws: 패킷 형식이 잘못된 경우 `BluetoothKitError.dataParsingFailed`
    internal func parseAccelerometerData(_ data: Data) throws -> [AccelerometerReading] {
        let bytes = [UInt8](data)
        
        let headerSize = 4
        let sampleSize = configuration.accelerometerSampleSize
        
        // 최소 패킷 크기 확인 (헤더 + 최소 하나의 샘플)
        guard bytes.count >= headerSize + sampleSize else {
            throw BluetoothKitError.dataParsingFailed("ACCEL 패킷이 너무 짧습니다: \(bytes.count) bytes (최소: \(headerSize + sampleSize))")
        }
        
        // 실제 이용 가능한 샘플 수 계산
        let dataWithoutHeader = bytes.count - headerSize
        let actualSampleCount = dataWithoutHeader / sampleSize
        let expectedSampleCount = (configuration.accelerometerPacketSize - headerSize) / sampleSize
        
        // 패킷 크기가 예상과 다른 경우 로그 출력 (EEG/PPG와 동일한 패턴)
        if bytes.count != configuration.accelerometerPacketSize {
            print("⚠️ ACCEL 패킷 크기: \(bytes.count) bytes (예상: \(configuration.accelerometerPacketSize)), \(actualSampleCount) 샘플 처리 중 (예상: \(expectedSampleCount))")
        }
        
        // 패킷 헤더에서 타임스탬프 추출
        let timeRaw = UInt32(bytes[3]) << 24 | UInt32(bytes[2]) << 16 | UInt32(bytes[1]) << 8 | UInt32(bytes[0])
        var timestamp = Double(timeRaw) / configuration.timestampDivisor / configuration.millisecondsToSeconds

        var readings: [AccelerometerReading] = []
        readings.reserveCapacity(min(actualSampleCount, expectedSampleCount))  // 성능 최적화

        // 이용 가능한 샘플만 파싱 (파이썬과 동일한 방식)
        for sampleIndex in 0..<actualSampleCount {
            let i = headerSize + (sampleIndex * sampleSize)
            
            // 배열 경계를 넘지 않도록 확인
            guard i + sampleSize <= bytes.count else {
                print("⚠️ ACCEL 샘플 \(sampleIndex + 1) 불완전, 나머지 샘플 건너뜀")
                break
            }
            
            // 파이썬과 동일한 방식: 홀수 번째 바이트만 사용 (1바이트 값)
            let x = Int16(bytes[i + 1])  // data[i+1]
            let y = Int16(bytes[i + 3])  // data[i+3] 
            let z = Int16(bytes[i + 5])  // data[i+5]
            
            let reading = AccelerometerReading(
                x: x,
                y: y,
                z: z,
                timestamp: Date(timeIntervalSince1970: timestamp)
            )
            
            readings.append(reading)
            
            // 다음 샘플을 위해 타임스탬프 증가
            timestamp += 1.0 / configuration.accelerometerSampleRate
        }
        
        return readings
    }
    
    // MARK: - Battery Data Parsing
    
    /// 원시 배터리 데이터를 구조화된 읽기값으로 파싱합니다.
    ///
    /// - Parameter data: 배터리 특성으로부터 수신된 원시 바이너리 데이터
    /// - Returns: 현재 배터리 레벨을 포함한 배터리 읽기값
    /// - Throws: 데이터가 유효하지 않은 경우 `BluetoothKitError.dataParsingFailed`
    internal func parseBatteryData(_ data: Data) throws -> BatteryReading {
        guard let level = data.first else {
            throw BluetoothKitError.dataParsingFailed("배터리 데이터가 비어있습니다")
        }
        
        return BatteryReading(level: level)
    }
} 
