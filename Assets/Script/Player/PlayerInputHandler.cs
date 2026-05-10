using UnityEngine;
using UnityEngine.InputSystem;

public class PlayerInputHandler : MonoBehaviour
{
    /// <summary>플레이어의 이동을 제어하는 스크립트</summary>
    [SerializeField] private PlayerController _playerController;

    private Vector2 _moveInput;
    void Awake()
    {
        _playerController ??= GetComponent<PlayerController>();
    }

    void Update()
    {
        _playerController.OnMove(_moveInput);
    }

    /// <summary>
    /// 인풋 시스템을 이용해서 이동 방향 입력을 받음
    /// </summary>
    public void OnMove(InputAction.CallbackContext context)
    {
        _moveInput = context.ReadValue<Vector2>();
    }

    /// <summary>
    /// 인풋 시스템을 이용해서 W의 입력을 받음
    /// </summary>
    public void OnJump(InputAction.CallbackContext context)
    {
        if (context.started)
            _playerController.OnJump();
    }

    /// <summary>
    /// 인풋 시스템을 이용해서 대쉬 입력을 받음
    /// </summary>
    public void OnDash(InputAction.CallbackContext context)
    {
        if (context.started)
            _playerController.OnDash();
    }
}
