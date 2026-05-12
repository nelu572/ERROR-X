using UnityEngine;

public class MenuDistortionController : MonoBehaviour
{
    [SerializeField] private Material _distortionMaterial;
    [SerializeField] private float _decayDuration = 0.6f;
    [SerializeField] private float _maxEventStrength = 0.12f;

    private static readonly int EventStrengthId = Shader.PropertyToID("_EventStrength");
    private float _currentStrength;
    private float _velocity;

    private void Awake()
    {
        ApplyStrength(0f);
    }

    private void Update()
    {
        if (_distortionMaterial == null)
        {
            return;
        }

        if (_currentStrength <= 0.0001f)
        {
            ApplyStrength(0f);
            return;
        }

        float smoothTime = Mathf.Max(0.01f, _decayDuration);
        _currentStrength = Mathf.SmoothDamp(_currentStrength, 0f, ref _velocity, smoothTime);
        ApplyStrength(_currentStrength);
    }

    public void TriggerPulse()
    {
        TriggerPulse(_maxEventStrength);
    }

    public void TriggerPulse(float strength)
    {
        _currentStrength = Mathf.Clamp(strength, 0f, _maxEventStrength);
        _velocity = 0f;
        ApplyStrength(_currentStrength);
    }

    public void SetCenter(Vector2 viewportCenter)
    {
        if (_distortionMaterial == null)
        {
            return;
        }

        _distortionMaterial.SetVector("_Center", new Vector4(viewportCenter.x, viewportCenter.y, 0f, 0f));
    }

    private void ApplyStrength(float value)
    {
        if (_distortionMaterial == null)
        {
            return;
        }

        _distortionMaterial.SetFloat(EventStrengthId, value);
    }
}
