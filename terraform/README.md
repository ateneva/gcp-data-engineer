
# Info

- bucekts that have retention policy cannot store files that need to be over-written

```python
google.api_core.exceptions.Forbidden: 403 PUT https://storage.googleapis.com/upload/storage/v1/b/eu-data-challenge/o?uploadType=resumable&upload_id=AD-8ljty7r801mcL__LHRuIzMV0xefkPEzFB6XIFJAKbEz0-kGPEoKF0ruqHEdPXnCHTmCmbrxUvIdnqEeCXP5Z5jyOh8BQs11eDy-WiE7-a7xUl: {
  "error": {
    "code": 403,
    "message": "Object 'eu-data-challenge/DataEngineer.csv' is subject to bucket's retention policy or object retention and cannot be deleted or overwritten until 2024-10-23T02:08:44.292127-07:00",
    "errors": [
      {
        "message": "Object 'eu-data-challenge/DataEngineer.csv' is subject to bucket's retention policy or object retention and cannot be deleted or overwritten until 2024-10-23T02:08:44.292127-07:00",
        "domain": "global",
        "reason": "retentionPolicyNotMet"
      }
    ]
  }

```
