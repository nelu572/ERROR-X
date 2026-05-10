using UnityEngine;

[System.Serializable]
public class PlayerSensor
{
    private const float ProbeInset = 0.05f;

    [Header("바닥 체크")]
    [SerializeField] private float _groundCheckDistance = 0.1f;
    [SerializeField] private LayerMask _groundLayer;

    [Header("벽 체크")]
    [SerializeField] private float _wallCheckDistance = 0.08f;

    [Header("천장 체크")]
    [SerializeField] private float _ceilingCheckDistance = 0.08f;

    [field: SerializeField] public bool IsGrounded { get; private set; }
    public bool IsTouchingWallLeft { get; private set; }
    public bool IsTouchingWallRight { get; private set; }
    public bool IsTouchingWall => IsTouchingWallLeft || IsTouchingWallRight;
    public bool IsTouchingCeiling { get; private set; }

    private Collider2D _collider;

    public void Initialize(Collider2D collider)
    {
        _collider = collider;
    }

    public void UpdateContacts()
    {
        Bounds bounds = _collider.bounds;

        IsGrounded = Physics2D.OverlapBox(
            GetGroundProbeCenter(bounds),
            GetGroundProbeSize(bounds),
            0f,
            _groundLayer
        ) != null;

        IsTouchingWallLeft = Physics2D.OverlapBox(
            GetLeftWallProbeCenter(bounds),
            GetWallProbeSize(bounds),
            0f,
            _groundLayer
        ) != null;

        IsTouchingWallRight = Physics2D.OverlapBox(
            GetRightWallProbeCenter(bounds),
            GetWallProbeSize(bounds),
            0f,
            _groundLayer
        ) != null;

        IsTouchingCeiling = Physics2D.OverlapBox(
            GetCeilingProbeCenter(bounds),
            GetCeilingProbeSize(bounds),
            0f,
            _groundLayer
        ) != null;
    }

    public bool IsDashBlocked(Vector2 dashDirection)
    {
        if (dashDirection.x < -0.01f && IsTouchingWallLeft)
        {
            return true;
        }

        if (dashDirection.x > 0.01f && IsTouchingWallRight)
        {
            return true;
        }

        if (dashDirection.y > 0.01f && IsTouchingCeiling)
        {
            return true;
        }

        return false;
    }

    public void DrawGizmos(Collider2D collider)
    {
        Bounds bounds = collider.bounds;

        Gizmos.color = IsGrounded ? Color.green : Color.red;
        Gizmos.DrawWireCube(
            GetGroundProbeCenter(bounds),
            GetGroundProbeSize(bounds)
        );

        Color wallColor = IsTouchingWall ? Color.cyan : Color.yellow;
        Gizmos.color = wallColor;
        Gizmos.DrawWireCube(
            GetLeftWallProbeCenter(bounds),
            GetWallProbeSize(bounds)
        );
        Gizmos.DrawWireCube(
            GetRightWallProbeCenter(bounds),
            GetWallProbeSize(bounds)
        );

        Gizmos.color = IsTouchingCeiling ? Color.magenta : new Color(1f, 0.5f, 0f);
        Gizmos.DrawWireCube(
            GetCeilingProbeCenter(bounds),
            GetCeilingProbeSize(bounds)
        );
    }

    private Vector2 GetGroundProbeCenter(Bounds bounds)
    {
        return new Vector2(bounds.center.x, bounds.min.y - _groundCheckDistance / 2f);
    }

    private Vector2 GetGroundProbeSize(Bounds bounds)
    {
        return new Vector2(Mathf.Max(0.01f, bounds.size.x - ProbeInset * 2f), _groundCheckDistance);
    }

    private Vector2 GetLeftWallProbeCenter(Bounds bounds)
    {
        return new Vector2(bounds.min.x - _wallCheckDistance / 2f, bounds.center.y);
    }

    private Vector2 GetRightWallProbeCenter(Bounds bounds)
    {
        return new Vector2(bounds.max.x + _wallCheckDistance / 2f, bounds.center.y);
    }

    private Vector2 GetWallProbeSize(Bounds bounds)
    {
        return new Vector2(_wallCheckDistance, Mathf.Max(0.01f, bounds.size.y - ProbeInset * 2f));
    }

    private Vector2 GetCeilingProbeCenter(Bounds bounds)
    {
        return new Vector2(bounds.center.x, bounds.max.y + _ceilingCheckDistance / 2f);
    }

    private Vector2 GetCeilingProbeSize(Bounds bounds)
    {
        return new Vector2(Mathf.Max(0.01f, bounds.size.x - ProbeInset * 2f), _ceilingCheckDistance);
    }
}
