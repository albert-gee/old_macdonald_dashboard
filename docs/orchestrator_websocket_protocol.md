# Orchestrator WebSocket Protocol

## Command

```json
{
  "type": "command",
  "request_id": "client-generated-id",
  "action": "thread.status_get",
  "payload": {}
}
```

## Command Result

```json
{
  "type": "command_result",
  "request_id": "client-generated-id",
  "action": "thread.status_get",
  "ok": true,
  "payload": {}
}
```

```json
{
  "type": "command_result",
  "request_id": "client-generated-id",
  "action": "thread.status_get",
  "ok": false,
  "error": {
    "code": "ESP_ERR_INVALID_ARG",
    "message": "Missing required field: node_id"
  }
}
```

## State Snapshot

```json
{
  "type": "state_snapshot",
  "payload": {
    "wifi": {
      "mode": "apsta",
      "ap_running": true,
      "sta_configured": false,
      "sta_connected": false,
      "sta_ip": null,
      "rssi": null
    },
    "thread": {
      "enabled": false,
      "attached": false,
      "role": "disabled",
      "dataset_present": false
    },
    "matter": {
      "controller_initialized": false,
      "commissioned_nodes": []
    },
    "websocket": {
      "clients": 1
    }
  }
}
```

## Event

```json
{
  "type": "event",
  "event": "wifi.sta_connected",
  "payload": {
    "ip": "192.168.1.123"
  }
}
```

Semantic Matter reads can be asynchronous. `device.temperature.read` and
`device.pressure.read` may return a successful command acceptance first:

```json
{
  "type": "command_result",
  "request_id": "req-temp-1",
  "action": "device.temperature.read",
  "ok": true,
  "payload": {
    "device_id": "bmp280-1",
    "accepted": true,
    "result_delivery": "matter.attribute_report"
  }
}
```

The value then arrives as an event:

```json
{
  "type": "event",
  "event": "matter.attribute_report",
  "payload": {
    "device_id": "bmp280-1",
    "semantic_type": "temperature",
    "temperature_celsius": 23.41,
    "raw_measured_value": 2341,
    "node_id": "123456789",
    "endpoint_id": 1,
    "cluster_id": 1026,
    "attribute_id": 0,
    "value": "2341"
  }
}
```

Pressure reports use `semantic_type=pressure` and `pressure_kpa`.

## Device Registry

`device.list` returns capability-aware device records:

```json
{
  "devices": [
    {
      "device_id": "bmp280-1",
      "node_id": "123456789",
      "label": "BMP280 Sensor",
      "reachable": true,
      "product_name": "BMP280",
      "location": "Root chamber",
      "capabilities": [
        {
          "capability_id": "bmp280-1-temperature",
          "semantic_type": "temperature",
          "endpoint_id": 1,
          "cluster_id": 1026,
          "attribute_id": 0,
          "label": "Temperature"
        }
      ]
    }
  ]
}
```

The Dashboard uses `temperature`, `pressure`, and `relay` capabilities for
normal Chamber workflows. Raw Matter IDs remain available in Developer tools.

## Protocol Error

```json
{
  "type": "error",
  "error": {
    "code": "INVALID_JSON",
    "message": "Message is not valid JSON"
  }
}
```
