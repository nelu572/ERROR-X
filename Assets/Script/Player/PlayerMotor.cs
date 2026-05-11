using UnityEngine;

[System.Serializable]
public class PlayerMotor
{
    [SerializeField] private float _moveSpeed = 5f;
    [SerializeField] private float _runSpeed = 8f;
    [SerializeField] private float _jumpForce = 5f;
    [SerializeField] private float _airDashSpeedBonus = 10f;

    private Rigidbody2D _rigidbody;

    public void Initialize(Rigidbody2D rigidbody)
    {
        _rigidbody = rigidbody;
    }

    public void MoveHorizontally(float inputX, bool isRunning, bool isGrounded)
    {
        Vector2 velocity = _rigidbody.linearVelocity;
        float targetSpeed = isRunning ? _runSpeed : _moveSpeed;
        velocity.x = inputX * targetSpeed;
        _rigidbody.linearVelocity = velocity;
    }

    public void Jump()
    {
        Vector2 velocity = _rigidbody.linearVelocity;
        velocity.y = 0f;
        _rigidbody.linearVelocity = velocity;

        _rigidbody.AddForce(Vector2.up * _jumpForce, ForceMode2D.Impulse);
    }

    public void AirDash(float facingDir, float inputX, bool isRunning)
    {
        float horizontalDir = Mathf.Abs(inputX) > 0.01f
            ? Mathf.Sign(inputX)
            : facingDir;

        float baseSpeed = isRunning ? _runSpeed : _moveSpeed;
        Vector2 velocity = _rigidbody.linearVelocity;
        velocity.x = horizontalDir * (baseSpeed + _airDashSpeedBonus);
        velocity.y = 0;
        _rigidbody.linearVelocity = velocity;
    }
}
