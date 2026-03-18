# 📺 SPI Display Controller IP

## 📌 Project Overview
디스플레이 모듈에 영상 및 텍스트 데이터를 고속으로 전송하기 위한 SPI 기반 디스플레이 제어기 RTL 설계 프로젝트입니다. 데이터를 순차적으로 읽어와 디스플레이의 특정 픽셀 좌표(Address)에 매핑하여 출력하는 로직을 구현했습니다.

## ⚙️ Key Features
* **Data Transmission Engine:** 디스플레이 모듈이 요구하는 Command와 Data 포맷을 구분하여 전송하는 제어 로직 구현
* **Memory Addressing:** 출력할 데이터(Frame buffer 또는 Character ROM)를 순차적으로 읽어오기 위한 메모리 주소 연산기(Address Generator) 구현

## 🛠️ Troubleshooting
**Issue: 데이터 밀림 및 Pointer 할당 오류 해결**
화면에 데이터를 출력할 때 특정 픽셀 위치가 밀리거나 엉뚱한 값이 출력되는 현상이 발생했습니다. 
디버깅 결과, 내부 메모리에서 데이터를 읽어올 때 사용하는 Address Pointer의 업데이트 타이밍과 SPI 전송 시작 타이밍 간의 클럭 도메인/동기화 불일치로 인해 잘못된 데이터를 샘플링하는 것이 원인이었습니다. Pointer 값이 완전히 업데이트된 후(Setup time 확보) 전송 State로 넘어가도록 FSM 타이밍을 교정하여 데이터 깨짐 현상을 해결했습니다.
