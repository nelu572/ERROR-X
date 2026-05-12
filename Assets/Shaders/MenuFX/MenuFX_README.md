# MenuFX Shader System

Unity 6 URP용 메인 메뉴 전용 모노크롬 셰이더 세트입니다. 전반적인 방향은 과장된 사이버펑크가 아니라, 저강도 CRT/디지털 오류/산업적 흑백 UI에 맞춰져 있습니다.

## Included shaders

- `ERROR-X/MenuFX/UI Noise`
- `ERROR-X/MenuFX/Glitch Strip`
- `ERROR-X/MenuFX/Pixel Dither`
- `ERROR-X/MenuFX/UI Shake`
- `ERROR-X/MenuFX/Dissolve Fade`
- `ERROR-X/MenuFX/Text Glitch`
- `ERROR-X/MenuFX/CRT Scanline`
- `ERROR-X/MenuFX/Distortion`

## Recommended usage

- `UI Noise`: 배경 패널, 일러스트, 어두운 오버레이에 약하게 적용
- `Glitch Strip`: 메뉴 타이틀, 경고 패널, 선택 전환 순간에만 사용
- `Pixel Dither`: 안개 낀 배경 스프라이트, 실루엣 레이어, 서브 패널
- `UI Shake`: 전체 캔버스보다 개별 텍스트 또는 경고 아이콘에 소량 적용
- `Dissolve Fade`: 메뉴 등장/퇴장, 저장 로드 전환
- `Text Glitch`: TMP가 아닌 일반 UI 텍스트/비트맵 텍스트/아틀라스 기반 그래픽 텍스트에 적합
- `CRT Scanline`: 카메라 전체 후처리
- `Distortion`: 이벤트성 풀스크린 펄스

## Fullscreen setup

1. `CRT Scanline` 또는 `Distortion` 셰이더로 머티리얼을 생성합니다.
2. URP Renderer Asset의 Renderer Features에 `Full Screen Pass Renderer Feature`를 추가합니다.
3. 해당 머티리얼을 할당합니다.
4. Injection Point는 보통 `After Rendering Post Processing` 또는 `Before Rendering Post Processing`이 무난합니다.

## Distortion trigger

- 씬 오브젝트에 [MenuDistortionController.cs](/C:/unity/ERROR-X/Assets/Script/Rendering/MenuDistortionController.cs)를 붙입니다.
- `Distortion` 머티리얼을 연결합니다.
- 메뉴 선택, 경고 점멸, 전환 시작 시 `TriggerPulse()` 또는 `TriggerPulse(float strength)`를 호출합니다.
- 필요 시 `SetCenter()`로 왜곡 중심을 바꿀 수 있습니다.

## Tuning notes

- 대부분의 효과는 `0.02 ~ 0.08` 수준의 낮은 강도에서 시작하는 편이 좋습니다.
- 메뉴 기본 상태에는 `UI Noise + CRT` 정도만 상시 적용하고, `Glitch Strip`, `Distortion`, `Text Glitch`는 이벤트 순간에만 켜는 구성이 가장 안정적입니다.
- 픽셀 퍼펙트 씬에서는 `UI Shake`의 `Snap Step`을 아주 작게 유지하거나 0으로 두고, 필요한 경우에만 켭니다.
