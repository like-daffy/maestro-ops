# Maestro Ops - Your Test Companion

## Maestro Ops란?

[Maestro](https://maestro.dev/)로 작성한 Flow를 손쉽게 실행할 수 있는 프로그램으로, 운영(Operation) 단계에서 주기적인 자동화 검증을 수행하기 위한 도구입니다.

또한, 이슈를 빠르게 파악할 수 있도록 결과 리포트를 기존 Maestro의 Look & Feel에 가깝게 작업하였습니다. Google Sheets를 활용 중이라면 결과를 손쉽게 복사해올 수 있습니다.

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

---

## Quick Start

1. **Java 설치:** [How to install Maestro CLI](https://docs.maestro.dev/maestro-cli/how-to-install-maestro-cli) 문서를 참조하여 설치합니다. 호환성을 고려하여 **OpenJDK 17** 버전을 권장합니다.
2. **Maestro CLI 설치:** [Maestro Installation 가이드](https://docs.maestro.dev/maestro-cli/how-to-install-maestro-cli#installation)를 참조하여 Maestro CLI 설치를 완료합니다.
3. **앱 다운로드:** [Releases](https://github.com/like-daffy/maestro-ops/releases) 페이지에서 본인의 OS에 맞는 파일을 다운로드합니다.
4. **환경 변수 설정 (Optional):** 바로 사용하셔도 무방하나, 반복 테스트 시 동일한 변수 값을 자동으로 입력하고 싶다면 `.env` 파일을 활용해 주세요. `.env.template` 파일의 이름을 `.env`로 변경한 뒤, 필요한 파라미터를 수정하여 사용하시면 됩니다.

## 🛠️ Tech Stack

| Category                 | Tools & Technologies                                                   |
| :----------------------- | :--------------------------------------------------------------------- |
| **Language**             | Python 3.12, Shell Scripting (Zsh, PowerShell)                         |
| **GUI Framework**        | PySide6                                                                |
| **Build & Distribution** | Nuitka                                                                 |
| **Core Integrations**    | Maestro CLI, ADB, Xcode CLI (simctl, devicectl), libimobiledevice      |
| **Data & Reporting**     | PyYAML, HTML/CSS Report Generation                                     |
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
