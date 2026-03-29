# AMBA 3 APB Slave IP

## Overview
AMBA 3 APB(Advanced Peripheral Bus) 프로토콜을 기반으로 동작하는 Slave IP 설계 및 검증 프로젝트입니다. 
APB Master는 Testbench 내부에 구현하여 Slave IP의 Read/Write Transaction 및 Error 응답 처리를 검증했습니다.

## Key Features
* **Protocol:** AMBA 3 APB (APB3)
* **Memory Space:** 64 Bytes
* **Base Address:** `0x10002000`
* **AMBA 3 Specific Features:**
  * **`PSLVERR` (Slave Error): Supported.** 할당된 64 Byte 레지스터 영역 외의 유효하지 않은 주소(Invalid Address)로 엑세스 시 에러 신호를 발생시키도록 설계하였습니다.

## Memory Map
| Start Address | End Address | Size | Description |
| :--- | :--- | :--- | :--- |
| `0x10002000` | `0x1000203F` | 64 Bytes | Slave IP Register Space |

## Verification (Testbench)
Testbench 내에 APB Master를 구현하여 아래의 시나리오를 바탕으로 Slave IP의 동작을 검증했습니다.

1. **Normal Read / Write Access**
   * Base Address(`0x10002000`)부터 64 Byte 영역 내에서의 정상적인 레지스터 Read/Write 동작을 검증했습니다.
2. **Error Response Test (`PSLVERR`)**
   * Memory Map 범위를 벗어난 유효하지 않은 주소에 접근을 시도할 때, Slave IP가 이를 인지하고 `PSLVERR` 신호를 정상적으로 출력하는지 검증했습니다.
