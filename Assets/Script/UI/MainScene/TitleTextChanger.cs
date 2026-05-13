using TMPro;
using UnityEngine;

public class TitleTextChanger : MonoBehaviour
{
    public readonly struct HttpStatusCodeData
    {
        public readonly string Code;
        public readonly string Description;

        public HttpStatusCodeData(string code, string description)
        {
            Code = code;
            Description = description;
        }
    }

    private readonly HttpStatusCodeData[] _httpStatusCodes =
    {
        // 1xx
        new("100", "Continue"),
        new("101", "Switching Protocols"),
        new("102", "Processing"),
        new("103", "Early Hints"),

        // 2xx
        new("200", "OK"),
        new("201", "Created"),
        new("202", "Accepted"),
        new("203", "Non-Authoritative Information"),
        new("204", "No Content"),

        // 3xx
        new("300", "Multiple Choices"),
        new("301", "Moved Permanently"),
        new("302", "Found"),
        new("303", "See Other"),
        new("304", "Not Modified"),
        new("307", "Temporary Redirect"),
        new("308", "Permanent Redirect"),

        // 4xx
        new("400", "Bad Request"),
        new("401", "Unauthorized"),
        new("403", "Forbidden"),
        new("404", "Not Found"),
        new("405", "Method Not Allowed"),
        new("408", "Request Timeout"),
        new("409", "Conflict"),
        new("418", "I'm a teapot"),
        new("429", "Too Many Requests"),

        // 5xx
        new("500", "Internal Server Error"),
        new("501", "Not Implemented"),
        new("502", "Bad Gateway"),
        new("503", "Service Unavailable"),
        new("504", "Gateway Timeout"),
        new("505", "HTTP Version Not Supported")
    };

    [Header("Text")]
    [SerializeField] private TextMeshProUGUI _titleText;
    [SerializeField] private TextMeshProUGUI _subTitleText;

    [Header("Delay")]
    [SerializeField] private float _minChangeDelay = 0.5f;
    [SerializeField] private float _maxChangeDelay = 3f;

    private float _timer;
    private float _currentDelay;

    private int _currentIndex = -1;

    private void Start()
    {
        SetRandomDelay();
        ChangeText();
    }

    private void Update()
    {
        _timer += Time.deltaTime;

        if (_timer < _currentDelay)
            return;

        _timer = 0f;

        SetRandomDelay();
        ChangeText();
    }

    private void SetRandomDelay()
    {
        _currentDelay = Random.Range(_minChangeDelay, _maxChangeDelay);
    }

    private void ChangeText()
    {
        int randomIndex;

        do
        {
            randomIndex = Random.Range(0, _httpStatusCodes.Length);
        }
        while (randomIndex == _currentIndex);

        _currentIndex = randomIndex;

        HttpStatusCodeData data = _httpStatusCodes[_currentIndex];

        _titleText.text = "ERROR-" + data.Code;
        _subTitleText.text = data.Description;
    }
}