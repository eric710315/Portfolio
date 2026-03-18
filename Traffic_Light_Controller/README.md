# 🚦 4-Way Traffic Light Controller (FSM Design)


<img width="580" height="886" alt="image" src="https://github.com/user-attachments/assets/7de7338c-f99d-4f63-8254-f628aef09413" />


software code : https://colab.research.google.com/drive/1AAwphIjrhSx4UKOWA7Uh_FRjBM1mspcp?usp=sharing

## 📌 Project Overview
본 프로젝트는 시스템 반도체 설계 실무 교육(대한민국 반도체 아카데미) 과정의 일환으로 진행된 **4거리 교차로 신호등 제어기 설계**입니다. Zynq-7015 보드를 활용하였으며, 복잡한 순차 논리(Sequential Logic)를 제어하기 위한 유한 상태 머신(Finite State Machine, FSM) 설계 역량을 검증하기 위해 진행되었습니다.

## ⚙️ Key Features
* **FSM-Based Architecture:** 교차로의 각 방향별 신호 상태(Green, Yellow, Red, Left-turn 등)를 정의하고, 조건에 따라 전이되는 FSM(`traffic_fsm.v`) 설계
* **Hierarchical Design:** 최상위 모듈(`top.v`)에서 하위 모듈(`traffic.v`, `traffic_fsm.v`)을 인스턴시에이션(Instantiation)하여 구조적이고 재사용 가능한 설계 적용
* **Tick(Enable) Generator:** 시스템 클럭을 기반으로 타이머 동작에 필요한 `100us`, `1us` 및 `0.5s` 단위의 Tick(Enable) 펄스 발생기 구현

<br>

## 🛠️ Troubleshooting & Hardware Optimization (핵심 문제 해결 경험)

**1. Clock Domain 및 동기 회로(Synchronous Circuit) 설계 원칙 준수**
초기 설계에서는 시뮬레이션의 편의를 위해 `1 클럭 = 1 사이클`로 검증을 마친 후, 실제 보드 동작을 위해 0.5초 주기의 클럭(Derived Clock)을 새로 생성하여 FSM의 Sensitivity List(`always @(posedge clk_0_5s)`)에 직접 인가했습니다. 
하지만 이로 인해 클럭 트리가 분리되면서 비동기 Reset 신호가 누락되거나 Metastability(준안정 상태)가 발생하는 치명적인 하드웨어 이슈를 겪었습니다.
이를 통해 **FPGA 내의 모든 플립플롭은 단일 메인 시스템 클럭에 동기화되어야 한다**는 동기 설계의 대원칙을 깨달았습니다. 즉시 구조를 전면 수정하여, 별도의 클럭을 생성하는 대신 메인 클럭을 그대로 유지하면서 0.5초마다 단 1-클럭 동안만 High가 되는 **`clk_enable` (Tick Pulse) 신호**를 생성해 상태 전이 조건(Condition)으로 활용하는 안정적인 구조로 아키텍처를 개선했습니다.

**2. FSM 상태 전이 타이밍(Edge/Pulse) 제어 및 동기화**
`clk_enable` 방식으로 구조를 변경한 후, 0.5초 동안 유지되어야 할 신호등 상태가 의도와 달리 1클럭 만에 다음 상태로 넘어가 버리는(Skip) 현상이 발생했습니다. 
원인을 분석한 결과, Enable 신호나 카운터 조건이 유지되는 여러 클럭 동안 FSM이 매 시스템 클럭마다 연속으로 상태를 전이해 버리기 때문임을 파악했습니다. 이를 해결하기 위해 0.5초를 세는 카운터의 **가장 마지막 클럭(Terminal Count)에서만 펄스가 발생하도록 로직을 정교하게 수정**하였고, FSM이 이 단발성 펄스(Tick)를 포착했을 때만 다음 상태로 넘어가도록 제어하여 정확한 시간 동안 상태가 유지되도록 완벽히 동기화했습니다.

**3. Unintended Latch 제거 (Combinational Logic 최적화)**
초기 FSM 설계 중, Combinational block(`always @(*)`) 내에서 일부 조건의 default 처리가 누락되어 원치 않는 Latch가 추론되는 현상을 발견했습니다. 상태 전이 및 출력 결정 로직의 모든 분기점(if-else, case)을 분석하고 완전한 할당(Complete Assignment)을 보장하도록 코드를 수정하여 Latch를 완벽히 제거하고 글리치(Glitch) 없는 안정적인 회로를 구성했습니다.


Play



https://github.com/user-attachments/assets/7234b53a-2e94-4894-9c2a-256ebb5d9bb6



