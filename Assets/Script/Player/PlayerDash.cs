using UnityEngine;

[System.Serializable]
public class PlayerDash
{
    [SerializeField] private float _dashSpeed = 18f;
    [SerializeField] private float _dashDuration = 0.18f;

    public bool IsDashing { get; private set; }
    public bool CanDash { get; private set; } = true;

    private float _dashTimer;
    private float _storedGravityScale;
    private Vector2 _dashDirection;

    public void Initialize()
    {
    }

    public void RefreshCharge(bool isGrounded, bool wasGrounded)
    {
        if (isGrounded && !wasGrounded)
        {
            CanDash = true;
        }
    }

    public bool TryStart(Vector2 moveInput, float facingDir, PlayerMotor motor)
    {
        if (!CanDash || IsDashing)
        {
            return false;
        }

        CanDash = false;
        IsDashing = true;
        _dashTimer = _dashDuration;
        _storedGravityScale = motor.GravityScale;
        motor.GravityScale = 0f;

        _dashDirection = moveInput.sqrMagnitude > 0.01f
            ? moveInput.normalized
            : new Vector2(facingDir, 0f);

        motor.SetVelocity(_dashDirection * _dashSpeed);
        return true;
    }

    public bool Tick(PlayerMotor motor)
    {
        if (!IsDashing)
        {
            return false;
        }

        _dashTimer -= Time.fixedDeltaTime;
        motor.SetVelocity(_dashDirection * _dashSpeed);

        if (_dashTimer <= 0f)
        {
            End(motor);
        }

        return true;
    }

    public bool ShouldCancelByCollision(PlayerSensor sensor)
    {
        return IsDashing && sensor.IsDashBlocked(_dashDirection);
    }

    public void Cancel(PlayerMotor motor)
    {
        if (!IsDashing)
        {
            return;
        }

        End(motor);
    }

    private void End(PlayerMotor motor)
    {
        IsDashing = false;
        motor.GravityScale = _storedGravityScale;
        motor.SetVelocity(Vector2.zero);
    }
}
