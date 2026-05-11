using UnityEngine;
using UnityEngine.InputSystem;

public class PlayerInputHandler : MonoBehaviour
{
    [SerializeField] private PlayerController _playerController;

    private Vector2 _moveInput;

    private void Awake()
    {
        _playerController ??= GetComponent<PlayerController>();
    }

    private void Update()
    {
        _playerController.OnMove(_moveInput);
    }

    public void OnMove(InputAction.CallbackContext context)
    {
        _moveInput = context.ReadValue<Vector2>();
    }

    public void OnJump(InputAction.CallbackContext context)
    {
        if (context.started)
        {
            _playerController.OnJump();
        }
    }

    public void OnRun(InputAction.CallbackContext context)
    {
        _playerController.OnRun(context.ReadValueAsButton());
    }
}
