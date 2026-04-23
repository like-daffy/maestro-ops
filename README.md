# Maestro Ops - Your Test Companion

## Maestro Ops란?

[Maestro](https://maestro.dev/)로 작성한 Flow를 손쉽게 실행할 수 있는 프로그램으로, 운영(Operation) 단계에서 주기적인 자동화 검증을 수행하기 위한 도구입니다.

또한, 이슈를 빠르게 파악할 수 있도록 결과 리포트를 기존 Maestro의 Look & Feel에 가깝게 작업하였습니다. Google Sheets를 활용 중이라면 결과를 손쉽게 복사해올 수 있습니다.

#### 2.0 Preview 버전은 여기서 [다운](https://github.com/like-daffy/maestro-ops/releases/tag/v2.0-beta1) 받으실 수 있습니다.

You can download v2.0 preview version [here](https://github.com/like-daffy/maestro-ops/releases/tag/v2.0-beta1).

**[Click here for the English guide](#-maestro-multi-verification-new-in-v20)**

---

### AS-IS vs TO-BE

**AS-IS (기존 CLI 방식)**

```bash
maestro test \
  --app-file app.apk \
  -e TEST_ID=bod@example.com \
  -e TEST_PWD=10203040 \
  -e TEST_CITY=Seoul \
  -e TEST_CARD_NUMBER=1000200030004000 \
  -e TEST_EXPIRATION=0328 \
  ...
  --udid 00000000-FFFF-FFFF-FFFF-000000000000 \
  --device-model="iPhone 17" \
  --flows flow.yaml
```

### TO-BE (Maestro Ops 활용)

![maestro-mov-sample](https://github.com/user-attachments/assets/fc0f2a37-7b41-4ff0-bdd2-8a1e914863d3)

CLI로도 충분히 실행할 수 있지만, 동일한 시나리오에서 디바이스나 변수 값을 바꿔가며 테스트하기에는 CLI 환경이 다소 번거로울 수 있습니다. **Maestro Ops**는 이러한 불편함을 해결하고 테스트 생산성을 높여줍니다.

## Quick Start

1. **Java 설치:** [How to install Maestro CLI](https://docs.maestro.dev/maestro-cli/how-to-install-maestro-cli) 문서를 참조하여 설치합니다. 호환성을 고려하여 **OpenJDK 17** 버전을 권장합니다.
2. **Maestro CLI 설치:** [Maestro Installation 가이드](https://docs.maestro.dev/maestro-cli/how-to-install-maestro-cli#installation)를 참조하여 Maestro CLI 설치를 완료합니다.
3. **앱 다운로드:** [Releases](https://github.com/like-daffy/maestro-ops/releases) 페이지에서 본인의 OS에 맞는 파일을 다운로드합니다.
4. **환경 변수 설정 (Optional):** 바로 사용하셔도 무방하나, 반복 테스트 시 동일한 변수 값을 자동으로 입력하고 싶다면 `.env` 파일을 활용해 주세요. `.env.template` 파일의 이름을 `.env`로 변경한 뒤, 필요한 파라미터를 수정하여 사용하시면 됩니다.

---

## 🚀 Maestro 멀티 검증 (v2.0 신기능)

<img width="944" height="526" alt="main_pc_original" src="https://github.com/user-attachments/assets/e804c24e-3eaf-4a28-af5c-94667bb82539" />

여러 환경에서 동시에 테스트를 수행하고 싶으신가요? **Multi Test** 기능을 이용하면 여러 대의 PC를 연결하여 병렬 테스트를 진행할 수 있습니다. 

* **Main PC (Orchestrator):** 테스트를 설계하고 전체 리스너들을 제어하는 '컨트롤 타워' 역할을 합니다.
* **Listener PC:** 실제 테스트 스크립트가 실행되는 '실행기' 역할을 합니다.
  * *Tip: Main PC에서도 리스너 창을 띄우면 스스로 리스너 역할을 수행할 수 있습니다.*

### 📋 사전 준비 사항

멀티 검증을 시작하기 전, 각 PC에 아래 도구들을 먼저 설치해 주세요.

#### **1. Main PC 세팅**

* **Docker Desktop:** [다운로드 바로가기](https://www.docker.com/products/docker-desktop/) (실행 필수)
* **Maestro CLI:** [설치 가이드](https://docs.maestro.dev/maestro-cli/how-to-install-maestro-cli)
* **Android SDK (ADB, 선택사항):** [플랫폼 도구 다운로드](https://developer.android.com/tools/releases/platform-tools#downloads)
* **Xcode (iOS 테스트용, 선택사항):** App Store에서 설치

#### **2. Listener PC 세팅**

* **Maestro CLI:** [설치 가이드](https://docs.maestro.dev/maestro-cli/how-to-install-maestro-cli)
* **Android SDK (ADB, 선택사항):** [플랫폼 도구 다운로드](https://developer.android.com/tools/releases/platform-tools#downloads) Emulator로 테스트를 원할 시에는 [Android Studio](https://developer.android.com/studio) 를 설치하는 걸 권장합니다. (Studio 설치 시 SDK 도 같이 설치하실 수 있습니다)
* **Xcode (iOS 테스트용, 선택사항):** App Store에서 설치

---

### 🛠️ 실행 및 연결 방법

#### **Step 1. Main PC 설정**

1. **Docker Desktop**을 실행합니다.

2. 다른 PC가 접속할 수 있도록 **방화벽 규칙**을 추가합니다. (Terminal, Powershell 에서 실행)

   ##### MacOS

   1. ```sudo ./setup_mac.sh``` 실행
   2. `Open Maestro Ops.command` 와 `Maestro Ops.app` 을 동일한 폴더에 복사
   3. (최초 1회에 한해) `Open Maestro Ops.command` 을 실행, 이후는 `Maestro Ops.app` 로 실행 가능

   ##### Windows OS

   1. PowerShell 에서 `./setup_win.ps1` 을 실행
   2. 원하는 폴더에 실행 파일을 옮겨둔뒤 사용

3. 실행 시 Main PC 모드를 선택합니다. 그런 뒤`Settings > Main PC Settings` 창에서 **[GET IP]** 를 클릭하여 현재 PC의 IP를 확인한 후 **Save** 버튼을 클릭합니다.

#### **Step 2. Listener PC 설정**

1.  우측 상단의 **Settings**를 클릭합니다.
2.  `Main PC Address` 항목에 **Main PC 에서 세팅했던 IP 주소**를 동일하게 입력합니다.

#### **Step 3. 연결 상태 확인**

각 PC에서 **Refresh**를 클릭했을 때 아래 상태여야 정상입니다.

* **Connection Status:** `Connected` 표시 확인
* **Connected PC Summary:** 연결된 PC 리스트에 해당 PC가 보여야 함
* **Listener Log:** 하단 Live Worker Log에 `Celery worker started (queue: listener.고유ID)` 메시지 확인

---

### 📱 디바이스 연결 가이드

- [ ] **Web Test:** 별도 디바이스 없이 바로 진행 가능합니다.
- [ ] **Android:** 실물 기기를 USB로 연결하거나, Android Studio에서 에뮬레이터를 실행해 주세요. ([Emulator 가 어디있나요?](#android-emulator-위치))
- [ ] **iOS:** 현재 Simulator 테스트만 지원합니다. (실물 기기 테스트가 필요하다면 [Maestro Cloud](https://maestro.dev/cloud)를 이용해 주세요.) ([Simulator 실행은 어떻게 하나요?](#simulator-실행))

---

### 🏁 테스트 시작하기

<img width="600" height="338" alt="maestro-ops-v2-preview" src="https://github.com/user-attachments/assets/25188e36-deb2-44cd-8de1-8fd075d2095c" />


1.  **Main PC**에서 연결된 각 **Listener PC**의 **[Edit]** 버튼을 클릭합니다.
2.  해당 환경에 필요한 환경변수 정보를 입력한 후 **[Apply]** 를 클릭합니다.
3.  세팅이 완료되면 **[START]** 버튼이 활성화됩니다.
4.  **[START]** 를 클릭하면 검증이 시작되며, 완료 후 결과 리포트를 확인할 수 있습니다.

---

### ❓ FAQ

#### **Android Emulator 위치**

Android Studio 실행 후, 좌측 상단의 **3선 메뉴(전체 메뉴) > Tools > Device Manager**를 선택하세요. 생성된 가상 기기의 **재생(▶️) 버튼**을 누르면 에뮬레이터가 실행됩니다.

#### **Simulator 실행**

Mac에서 `Cmd + Space`를 눌러 스포트라이트를 켠 뒤, **"Simulator.app"** 을 입력하여 실행하세요.

#### 장소를 이동했는데 작동이 안될 경우

다음 명령어로 Docker 를 재시작해줍니다.

```bash
docker restart maestro-ops-redis
```

그런뒤 Main PC 에서 Get IP 를 클릭하면 바뀐 IP 로 보일겁니다. 그 IP를 동일하게 Listener PC 에 입력하시면 사용이 가능합니다.

---

### 🐛 이슈 제보 및 문의

사용 중 문제나 버그를 발견하셨다면, 아래 링크를 통해 언제든 리포트를 남겨주세요!

👉 [Maestro Ops Issue Report](https://github.com/like-daffy/maestro-ops/issues/new?template=bug_report.yml)

❗ [Maestro Ops 제안/건의](https://github.com/like-daffy/maestro-ops/issues/new?template=improvement_request.yml)

### 🚀 Maestro Multi-Verification (New in v2.0)

Looking to run tests across multiple environments simultaneously? With the **Multi-Test** feature, you can connect multiple PCs to perform parallel testing.

* **Main PC (Orchestrator):** Acts as the 'Control Tower' to design tests and manage all Listeners.
* **Listener PC:** Acts as the 'Runner' where the actual test scripts are executed.
  * *Tip: By opening a Listener window on the Main PC, it can also function as a Runner itself.*

---

### 📋 Prerequisites

Before starting multi-verification, please install the following tools on each PC.

#### **1. Main PC Setup**

* **Docker Desktop:** [Download Here](https://www.docker.com/products/docker-desktop/) (Must be running)
* **Maestro CLI:** [Installation Guide](https://docs.maestro.dev/maestro-cli/how-to-install-maestro-cli)
* **Android SDK (ADB, Optional):** [Download Platform Tools](https://developer.android.com/tools/releases/platform-tools#downloads)
* **Xcode (Optional, for iOS testing):** Install via the App Store

#### **2. Listener PC Setup**

* **Maestro CLI:** [Installation Guide](https://docs.maestro.dev/maestro-cli/how-to-install-maestro-cli)
* **Android SDK (ADB, Optional):** [Download Platform Tools](https://developer.android.com/tools/releases/platform-tools#downloads). If you intend to test via emulator, installing [Android Studio](https://developer.android.com/studio) is recommended (the SDK is included with the Studio installation).
* **Xcode (Optional, for iOS testing):** Install via the App Store

---

### 🛠️ Setup and Connection

#### **Step 1. Main PC Configuration**

1. Launch **Docker Desktop**.

2. Add **Firewall Rules** to allow access from other PCs (Run via Terminal or PowerShell).

   ##### MacOS

   1. Run ```sudo ./setup_mac.sh```.
   2. Copy `Open Maestro Ops.command` and `Maestro Ops.app` into the same folder.
   3. Execute `Open Maestro Ops.command` (first time only); subsequently, you can launch via `Maestro Ops.app`.

   ##### Windows OS

   1. Run `./setup_win.ps1` in PowerShell 7.
   2. Move the executable file to your desired folder and launch.

3. Select **Main PC Mode** upon execution. Then, navigate to `Settings > Main PC Settings`, click **[GET IP]** to identify your current IP, and click the **Save** button.

#### **Step 2. Listener PC Configuration**

1.  Click **Settings** in the top right corner.
2.  In the `Main PC Address` field, enter the **exact IP address** configured on the Main PC.

#### **Step 3. Verifying Connection Status**

When you click **Refresh** on each PC, the status should be as follows:

* **Connection Status:** Displays `Connected`.
* **Connected PC Summary:** The PC should appear in the list of connected devices.
* **Listener Log:** The message `Celery worker started (queue: listener.Unique_ID)` should appear in the Live Worker Log at the bottom.

---

### 📱 Device Connection Guide

- [ ] **Web Test:** Ready to go without additional device setup.
- [ ] **Android:** Connect a physical device via USB or launch an emulator from Android Studio. ([Where is the Emulator?](#android-emulator-location))
- [ ] **iOS:** Currently supports Simulator testing only. (For physical device testing, please use [Maestro Cloud](https://maestro.dev/cloud)). ([How to run the Simulator?](#launching-the-simulator))

---

### 🏁 Starting the Test

1.  On the **Main PC**, click the **[Edit]** button for each connected **Listener PC**.
2.  Enter the required environment variables for that specific environment and click **[Apply]**.
3.  Once the setup is complete, the **[START]** button will be activated.
4.  Click **[START]** to begin verification. You can view the result reports once finished.

---

### ❓ FAQ

#### **Android Emulator Location**

After launching Android Studio, go to the **Hamburger Menu (Top Left) > Tools > Device Manager**. Click the **Play (▶️) button** on your virtual device to start the emulator.

#### **Launching the Simulator**

Press `Cmd + Space` on your Mac to open Spotlight, type **"Simulator.app"**, and press Enter.

#### **What if it stops working after changing locations?**

Restart Docker using the following command:

```bash
docker restart maestro-ops-redis
```

## 🛠️ Tech Stack

| Category                 | Tools & Technologies                                         |
| :----------------------- | :----------------------------------------------------------- |
| **Language**             | Python 3.12, Shell Scripting (Zsh, PowerShell)               |
| **GUI Framework**        | PySide6                                                      |
| **Build & Distribution** | Nuitka                                                       |
| **Core Integrations**    | Maestro CLI, ADB, Xcode CLI (simctl, devicectl), libimobiledevice |
| **Data & Reporting**     | PyYAML, HTML/CSS Report Generation                           |
| **CI/CD & DevOps**       | **GitHub Actions (Self-hosted Runner)**, macOS/Windows Build Pipelines |

---

## ✨ Core Features

- OS 환경에 따라 실제 기기 및 에뮬레이터/시뮬레이터를 자동으로 감지하고 연결하여 설정에 소요되는 리소스를 최소화 합니다.
- 결과 로그를 구조화된 JSON 및 Styled HTML로 변환하여, 테스트 소요 시간과 스크린샷이 포함된 직관적인 검증 결과를 제공합니다.
- **Single-Binary Distribution:** 사용자 환경의 **파이썬 설치 유무와 상관없이** 단일 실행 파일(`.app`, `.exe`)만으로 즉시 구동되는 배포 시스템을 구축했습니다.
- GitHub Actions를 통해 빌드 및 릴리즈 과정을 자동화했습니다. **Self-hosted Runner**를 운용하여 빌드 속도를 최적화하고, macOS(Apple Sillicon, Intel Mac) 그리고 Windows 간의 교차 빌드 프로세스를 자동화했습니다.

---

## 🧠 Engineering Notes

### 1. Python 3.12: 성능과 운영 안정성의 균형

여러 테스트 로그를 실시간으로 파싱(Parsing)할 때 발생하는 오버헤드를 줄이기 위해 PEP 659(Specializing Adaptive Interpreter)가 도입된 Python 3.12를 기반으로 설계했습니다.

> 최신 런타임 최적화 기술을 제공할 뿐만 아니라, 현시점 기준으로 성숙도와 유지보수 안정성을 고려하여 3.12 버전으로 선택했습니다.

### 2. Nuitka: AOT(Ahead-Of-Time) 컴파일러 채택

전통적인 번들링 방식 대신, 파이썬 코드를 C 수준으로 변환하여 네이티브 바이너리를 생성하는 Nuitka를 사용함으로써 다음과 같은 엔지니어링 이점을 확보했습니다.

- 실행 시 압축을 푸는 과정이 없어 초기 구동 속도가 매우 빠르며, 런타임 의존성 문제 없이 빌드됩니다.
- 로직이 기계어 형태로 컴파일되어 **리버스 엔지니어링을 방지**하고, 내부 운영 로직에 대한 보안성을 강화됩니다.

---

## 📄 License

This project is licensed under the **MIT License**.  
자세한 내용은 [LICENSE](./LICENSE) 파일을 확인해 주세요.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
