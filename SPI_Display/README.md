# 📺 SPI Display Controller IP

## 📌 Project Overview
본 프로젝트는 디스플레이 모듈에 영상 및 텍스트 데이터를 고속으로 전송하기 위한 SPI 기반 디스플레이 제어기 RTL 설계입니다. 데이터를 순차적으로 읽어와 디스플레이의 특정 픽셀 좌표(Address)에 매핑하여 출력하는 순차 제어 로직(Sequential Control Logic) 구현 및 데이터시트 분석 역량을 검증하기 위해 진행되었습니다.

## ⚙️ Key Features
* **Data Transmission Engine:** 디스플레이 모듈이 요구하는 Command와 Data 포맷(C/D 신호 제어)을 구분하여 전송하는 순차 제어 로직 구현
* **Display Initialization & Clear:** 화면 초기화 시퀀스 및 프레임 렌더링을 위한 메모리 포인터 제어 회로 설계
* **Datasheet-Driven Design:** 디스플레이 칩의 데이터시트를 분석하여 정확한 명령어(Command) 스펙과 타이밍 요구사항 도출 및 적용

## 🛠️ Troubleshooting & Hardware Optimization

**1. 디스플레이 초기화(Clear) 후 좌표 밀림 현상 분석 및 해결**
* **Issue:** 화면을 한 번 초기화(Clear) 한 이후 새로운 프레임 데이터를 띄울 때, 시작점(0,0)이 아닌 엉뚱한 위치(예: 70h)부터 렌더링되는 치명적인 오동작이 발생했습니다. 초기화 사이클이 부족하다는 가설을 세우고 횟수를 1~5회 늘려보았으나, 여전히 똑같은 주소(70h)부터 밀리는 현상이 발생했습니다.
* **Resolution:** 단순한 횟수 조절(임시방편)을 멈추고 Vivado ILA를 통해 파형을 정밀 분석했습니다. 그 결과, 초기화 시퀀스 종료 직후 C/D(Command/Data) 제어 신호가 `1(Command)`로 유지된 상태에서 데이터 버스에 기본값인 `00h`가 인가되고 있음을 확인했습니다. 데이터시트를 샅샅이 뒤져 `00h`가 '포인터 주소의 하위 4비트를 0h로 강제 초기화'하는 명령어임을 밝혀냈습니다. 이를 바탕으로 초기화 완료 직후 C/D 신호와 데이터 버스의 인가 타이밍을 엄격하게 분리하여 의도치 않은 커맨드 인입을 원천 차단, 포인터 오동작을 완벽하게 해결했습니다.


https://github.com/user-attachments/assets/0a4c984c-3dc5-441c-9a42-2e2d613050e2

