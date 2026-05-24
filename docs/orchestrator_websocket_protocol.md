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
