# 📡 SPI Master IP for MCP3004 ADC

## 📌 Project Overview
본 프로젝트는 Xilinx Zynq-7015 보드 환경에서 아날로그-디지털 변환기(MCP3004)와 통신하기 위한 **SPI Master IP를 RTL(Verilog)로 직접 설계** 한 결과물

## ⚙️ Key Features
* **SPI Protocol Implementation:** SCLK, MOSI, MISO, CS 신호를 제어하여 Standard SPI 통신 규격 구현
* **Datasheet-Driven Design:** MCP3004 칩의 데이터시트를 분석하여, Start 비트, 동작 모드(Single/Diff), 채널 선택을 위한 5-bit Control Word 전송 로직 구현
* **Data Shift & Latch:** Slave(MCP3004)로부터 들어오는 10-bit ADC 결과값을 SCLK에 맞춰 정확한 타이밍에 Shift 및 수신하는 회로 설계

## 🛠️ Troubleshooting & Hardware Debugging
**Issue: 시뮬레이션과 실제 보드 테스트 간의 타이밍 불일치 및 데이터 수신 오류**
RTL 시뮬레이션 상에서는 타이밍 딜레이가 요구사항에 맞게 출력되었으나, 실제 Zynq-7015 보드에 비트스트림을 올려 테스트했을 때 ADC 값이 정상적으로 수신되지 않는 문제가 발생. Slave 칩의 응답을 직접 눈으로 확인할 수 없어 원인 파악에 어려움을 겪음.

**Resolution: Vivado ILA(Integrated Logic Analyzer)를 활용한 디버깅**
소프트웨어적인 추측을 멈추고, 실제 하드웨어 레벨의 신호를 눈으로 확인하기 위해 **Vivado ILA 코어**를 설계에 추가
보드 동작 중 실시간으로 SCLK, MOSI, MISO 파형을 캡처하여 분석한 결과, Master에서 Control Word(5-bit)를 전송한 직후 데이터를 수신하는 타이밍(Sampling Edge)이 데이터시트의 스펙과 미세하게 어긋나 있는 것을 발견. 파형을 기반으로 State Machine의 Shift 타이밍을 교정하여 SPI 통신을 안정화


https://github.com/user-attachments/assets/e9bdac62-d5db-42da-a4e0-0915fcdbf9bf

