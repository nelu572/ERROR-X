using UnityEngine;
using UnityEngine.InputSystem;

public class PlayerInputHandler : MonoBehaviour
{
    /// <summary>플레이어의 이동을 제어하는 스크립트</summary>
    [SerializeField] private PlayerController _playerController;

    private float _moveInput;
    void Awake()
    {
        _playerController ??= GetComponent<PlayerController>();
    }

    void Update()
    {
        _playerController.OnMove(_moveInput);
    }

    /// <summary>
    /// 인풋 시스템을 이용해서 A, D의 입력을 받음
    /// </summary>
    public void OnMove(InputAction.CallbackContext context)
    {
        _moveInput = context.ReadValue<float>();
    }

    /// <summary>
    /// 인풋 시스템을 이용해서 W의 입력을 받음
    /// </summary>
    public void OnJump(InputAction.CallbackContext context)
    {
        if (context.started)
            _playerController.OnJump();
    }
}
