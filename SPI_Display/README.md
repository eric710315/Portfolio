# 📺 SPI Display Controller IP

## 📌 Project Overview
디스플레이 모듈에 영상 및 텍스트 데이터를 고속으로 전송하기 위한 SPI 기반 디스플레이 제어기 RTL 설계 프로젝트입니다. 데이터를 순차적으로 읽어와 디스플레이의 특정 픽셀 좌표(Address)에 매핑하여 출력하는 로직을 구현했습니다.

* **사용 언어 및 툴:** Verilog HDL, Xilinx Vivado (ILA Debugging)
* **핵심 기술:** SPI Protocol, 순차 제어 로직(Sequential Logic), Datasheet Analysis, Memory Addressing

<br>

## ⚙️ Key Features
* **Data Transmission Engine:** 디스플레이 모듈이 요구하는 Command와 Data 포맷(C/D 신호 제어)을 구분하여 전송하는 순차 제어 로직 구현
* **Display Initialization & Clear:** 화면 초기화 시퀀스 및 프레임 렌더링을 위한 포인터 제어 회로 설계

<br>

## 🛠️ Troubleshooting & Root Cause Analysis (핵심 문제 해결)

💡 **Issue: 초기화(Clear) 후 데이터 출력 좌표 밀림 현상**
화면을 한 번 Clear 한 이후에 새로운 프레임 데이터를 띄울 때, 데이터가 시작점(0,0)이 아닌 엉뚱한 위치(예: `70h`)부터 밀려서 렌더링되는 치명적인 오동작이 발생했습니다.

💡 **Hypothesis & Testing (가설 수립 및 검증)**
1. **초기화 사이클 부족 가설:** 포인터가 끝까지 도달하지 못했다고 판단하여 초기화 횟수를 1~5회 늘려보았으나 증상이 동일했습니다. 50회 이상 늘렸을 때 정상 동작하는 것처럼 보였으나, **현상만 덮을 뿐 근본적인 원인이 아님을 직감하고 ILA로 파형 분석을 시작했습니다.**
2. **포인터 자동 증가 가설:** 데이터를 보내지 않는 유휴(Idle) 상태에서도 포인터가 증가할 수 있다는 가설을

https://github.com/user-attachments/assets/0a4c984c-3dc5-441c-9a42-2e2d613050e2

