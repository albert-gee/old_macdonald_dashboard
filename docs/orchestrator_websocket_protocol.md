# Orchestrator WebSocket Protocol

This document describes the current Dashboard/Orchestrator protocol. Operator
pages should present product readiness and device capability status first.
Developer-only screens may expose raw command payloads, Matter IDs, Thread
diagnostics, and event payloads.

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
    "device_id": "sensor-1",
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
    "device_id": "sensor-1",
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
      "device_id": "sensor-1",
      "node_id": "123456789",
      "label": "Environmental sensor",
      "reachable": true,
      "product_name": "environmental sensor",
      "location": "chamber",
      "capabilities": [
        {
          "capability_id": "capability-1",
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

Pairing or commissioning is not the final operator step. A commissioned device
must be represented in the device registry with usable capabilities before it
can participate in Chamber workflows.

## Dashboard Page Ownership

- Operator pages: Chamber, Devices, Wi-Fi Network, Thread Network, Matter
  Network, and Orchestrator readiness.
- Maintainer tasks: certificate trust, Wi-Fi/Thread/Matter setup, device
  registry and capability verification.
- Developer tools: raw Matter cluster workflows, raw Thread diagnostics, raw
  command/event inspection, and manual recovery actions.

Live WSS verification requires the Dashboard machine to be connected to the
Orchestrator local access point or another reachable Orchestrator IP.

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
