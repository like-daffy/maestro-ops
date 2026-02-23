### 앱 준비 가이드

Maestro 시나리오(Flow) 실행을 위해 테스트 대상 애플리케이션을 준비하는 단계입니다. 원활한 자동화 테스트를 위해 아래 절차를 따라 주시기 바랍니다.

1. 샘플 애플리케이션 다운로드
   각 플랫폼별 최신 릴리즈 페이지에서 테스트용 앱 패키지를 다운로드합니다.

- Android (.apk): https://github.com/saucelabs/sample-app-android/releases
- iOS Simulator (.zip): https://github.com/saucelabs/sample-app-ios/releases

2. 패키지 디렉토리 배치
   다운로드한 파일을 프로젝트 내 apps/ 디렉토리에 위치시킵니다. 플랫폼별 권장 파일명은 다음과 같습니다.

- Android: mda-2.2.0-25.apk
- iOS (Simulator): SauceLabs-Demo-App.Simulator.zip

**iOS 실제 기기 미지원 안내**
Maestro 2.3.0 버전은 iOS 23.x 버전의 실제 기기(Physical Device) 테스트를 지원하지 않습니다. 향후 업데이트를 통해 지원될 경우 해당 가이드를 업데이트 할 예정입니다.

3. 환경 변수(.env) 설정
   준비된 앱 경로를 프로젝트 루트의 .env 파일에 명시하여 활성화합니다.

```
# Application Path Configuration
APK_PATH=apps/mda-2.2.0-25.apk
IOS_APP_ZIP=apps/SauceLabs-Demo-App.Simulator.zip
IOS_IPA_PATH=apps/SauceLabs-Demo-App-resigned.ipa
```

### Application Preparation Guide

This guide outlines the steps required to prepare target applications for executing Maestro flows. Please follow these instructions to ensure consistent test execution.

1. Download Sample Applications
   Download the appropriate application packages from the official Sauce Labs release pages:

- Android (.apk): https://github.com/saucelabs/sample-app-android/releases
- iOS Simulator (.zip): https://github.com/saucelabs/sample-app-ios/releases

2. File Placement
   Place the downloaded packages into the apps/ directory. The standard filenames are as follows:

- For Android: mda-2.2.0-25.apk
- For iOS (Simulator): SauceLabs-Demo-App.Simulator.zip

[Notice] iOS Physical Device Support
Please note that Maestro v2.3.0 currently does not support testing on iOS Physical Devices. This guide will be updated as future releases introduce this capability.

3. Environment Configuration (.env)
   Configure the application paths in your .env file located in the project root:

```
# Application Path Configuration
APK_PATH=apps/mda-2.2.0-25.apk
IOS_APP_ZIP=apps/SauceLabs-Demo-App.Simulator.zip
IOS_IPA_PATH=apps/SauceLabs-Demo-App-resigned.ipa
```
