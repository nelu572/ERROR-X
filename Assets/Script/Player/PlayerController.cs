using UnityEngine;

[RequireComponent(typeof(Rigidbody2D))]
[RequireComponent(typeof(Collider2D))]
public class PlayerController : MonoBehaviour
{
    [SerializeField] private Rigidbody2D _rigidbody;
    [SerializeField] private Collider2D _collider;

    [Header("이동/점프")]
    [SerializeField] private PlayerMotor _motor = new();

    [Header("감지")]
    [SerializeField] private PlayerSensor _sensor = new();

    private Vector2 _moveInput;
    private float _facingDir = 1f;
    private bool _jumpRequested;
    private bool _isRunHeld;
    private bool _wasGrounded;
    private bool _isAirDashing;
    private float _airDashTimer;
    private int _jumpCount;

    [Header("공중 대쉬")]
    [SerializeField] private float _airDashDuration = 0.12f;

    private void Awake()
    {
        _rigidbody ??= GetComponent<Rigidbody2D>();
        _collider ??= GetComponent<Collider2D>();

        _motor.Initialize(_rigidbody);
        _sensor.Initialize(_collider);
    }

    private void FixedUpdate()
    {
        _wasGrounded = _sensor.IsGrounded;
        _sensor.UpdateContacts();
        RefreshJumpState();

        HandleMove();
        HandleJump();
        UpdateAirDash();
    }

    private void HandleMove()
    {
        if (_isAirDashing)
        {
            return;
        }

        _motor.MoveHorizontally(_moveInput.x, _isRunHeld, _sensor.IsGrounded);
    }

    private void HandleJump()
    {
        if (!_jumpRequested)
        {
            return;
        }

        if (_sensor.IsGrounded)
        {
            _motor.Jump();
            _jumpCount = 1;
        }
        else if (_jumpCount == 1)
        {
            StartAirDash();
            _jumpCount = 2;
        }

        _jumpRequested = false;
    }

    private void RefreshJumpState()
    {
        if (_sensor.IsGrounded && !_wasGrounded)
        {
            _jumpCount = 0;
            _isAirDashing = false;
            _airDashTimer = 0f;
        }
    }

    private void StartAirDash()
    {
        _isAirDashing = true;
        _airDashTimer = _airDashDuration;
        _motor.AirDash(_facingDir, _moveInput.x, _isRunHeld);
    }

    private void UpdateAirDash()
    {
        if (!_isAirDashing)
        {
            return;
        }

        _airDashTimer -= Time.fixedDeltaTime;
        _motor.AirDash(_facingDir, _moveInput.x, _isRunHeld);

        if (_airDashTimer <= 0f)
        {
            _isAirDashing = false;
        }
    }

    private void OnDrawGizmos()
    {
        if (_collider == null)
        {
            _collider = GetComponent<Collider2D>();
        }

        if (_collider == null)
        {
            return;
        }

        _sensor.DrawGizmos(_collider);
    }

    public void OnMove(Vector2 moveInput)
    {
        _moveInput = moveInput;

        if (Mathf.Abs(moveInput.x) > 0.01f)
        {
            _facingDir = Mathf.Sign(moveInput.x);
        }
    }

    public void OnJump()
    {
        _jumpRequested = true;
    }

    public void OnRun(bool isHeld)
    {
        _isRunHeld = isHeld;
    }
}
