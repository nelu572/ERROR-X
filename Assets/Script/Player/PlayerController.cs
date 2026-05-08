using UnityEngine;

[RequireComponent(typeof(Rigidbody2D))]
[RequireComponent(typeof(Collider2D))]
public class PlayerController : MonoBehaviour
{
    [SerializeField] private Rigidbody2D _rigidbody;
    [SerializeField] private Collider2D _collider;

    [Header("이동")]
    [SerializeField] private float _moveSpeed = 5f;
    private float _inputDirX;

    [Header("점프")]
    [SerializeField] private float _jumpForce = 5f;
    private bool _jumpRequested;

    [Header("바닥 체크")]
    [SerializeField] private float _groundCheckDistance = 0.1f;
    [SerializeField] private LayerMask _groundLayer;
    [SerializeField] private bool _isGrounded;

    private void Awake()
    {
        _rigidbody ??= GetComponent<Rigidbody2D>();
        _collider ??= GetComponent<Collider2D>();
    }

    private void FixedUpdate()
    {
        CheckGround();
        HandleMove();
        HandleJump();
    }

    // =========================
    // 이동 처리
    // =========================
    private void HandleMove()
    {
        Vector2 velocity = _rigidbody.linearVelocity;
        velocity.x = _inputDirX * _moveSpeed;
        _rigidbody.linearVelocity = velocity;
    }

    // =========================
    // 점프 처리
    // =========================
    private void HandleJump()
    {
        if (!_jumpRequested || !_isGrounded)
        {
            _jumpRequested = false;
            return;
        }

        Vector2 velocity = _rigidbody.linearVelocity;
        velocity.y = 0f;
        _rigidbody.linearVelocity = velocity;

        _rigidbody.AddForce(Vector2.up * _jumpForce, ForceMode2D.Impulse);

        _jumpRequested = false;
    }

    // =========================
    // 바닥 체크
    // =========================
    private void CheckGround()
    {
        Bounds b = _collider.bounds;

        RaycastHit2D box = Physics2D.BoxCast(
            b.center,
            b.size,
            0f,
            Vector2.down,
            _groundCheckDistance,
            _groundLayer
        );
        _isGrounded = box.collider != null;
    }

    // =========================
    // 씬 뷰 시각화
    // =========================
    private void OnDrawGizmos()
    {
        if (_collider == null) return;

        Bounds b = _collider.bounds;
        Gizmos.color = _isGrounded ? Color.green : Color.red;

        Gizmos.DrawWireCube(
            new Vector2(b.center.x, b.min.y - _groundCheckDistance / 2f),
            new Vector2(b.size.x, _groundCheckDistance)
        );
    }

    // =========================
    // 입력 (외부에서 호출)
    // =========================
    public void OnMove(float dirX)
    {
        _inputDirX = dirX;
    }

    public void OnJump()
    {
        _jumpRequested = true;
    }
}