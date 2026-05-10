using UnityEngine;

[System.Serializable]
public class PlayerMotor
{
    [SerializeField] private float _moveSpeed = 5f;
    [SerializeField] private float _jumpForce = 5f;

    private Rigidbody2D _rigidbody;

    public float MoveSpeed => _moveSpeed;

    public float GravityScale
    {
        get => _rigidbody.gravityScale;
        set => _rigidbody.gravityScale = value;
    }

    public void Initialize(Rigidbody2D rigidbody)
    {
        _rigidbody = rigidbody;
    }

    public void MoveHorizontally(float inputX)
    {
        Vector2 velocity = _rigidbody.linearVelocity;
        velocity.x = inputX * _moveSpeed;
        _rigidbody.linearVelocity = velocity;
    }

    public void Jump()
    {
        Vector2 velocity = _rigidbody.linearVelocity;
        velocity.y = 0f;
        _rigidbody.linearVelocity = velocity;

        _rigidbody.AddForce(Vector2.up * _jumpForce, ForceMode2D.Impulse);
    }

    public Vector2 GetVelocity()
    {
        return _rigidbody.linearVelocity;
    }

    public void SetVelocity(Vector2 velocity)
    {
        _rigidbody.linearVelocity = velocity;
    }
}
