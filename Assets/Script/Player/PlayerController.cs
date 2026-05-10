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

    [Header("대쉬")]
    [SerializeField] private PlayerDash _dash = new();

    private Vector2 _moveInput;
    private float _facingDir = 1f;
    private bool _jumpRequested;
    private bool _dashRequested;

    private void Awake()
    {
        _rigidbody ??= GetComponent<Rigidbody2D>();
        _collider ??= GetComponent<Collider2D>();

        _motor.Initialize(_rigidbody);
        _sensor.Initialize(_collider);
        _dash.Initialize(_motor.GravityScale);
    }

    private void FixedUpdate()
    {
        _sensor.UpdateContacts();
        _dash.RefreshCharge(_sensor.IsGrounded);

        if (HandleDash())
        {
            _jumpRequested = false;
            return;
        }

        HandleMove();
        HandleJump();
    }

    private bool HandleDash()
    {
        if (_dash.Tick(_motor))
        {
            if (_dash.ShouldCancelByCollision(_sensor))
            {
                _dash.Cancel(_motor);
            }

            return true;
        }

        if (!_dashRequested)
        {
            return false;
        }

        _dashRequested = false;
        return _dash.TryStart(_moveInput, _facingDir, _motor);
    }

    private void HandleMove()
    {
        _motor.MoveHorizontally(_moveInput.x);
    }

    private void HandleJump()
    {
        if (!_jumpRequested || !_sensor.IsGrounded)
        {
            _jumpRequested = false;
            return;
        }

        _motor.Jump();
        _jumpRequested = false;
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

    public void OnDash()
    {
        _dashRequested = true;
    }
}
