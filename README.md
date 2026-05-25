# Old MacDonald Dashboard

Flutter dashboard for the Old MacDonald Orchestrator.

## Run

```sh
flutter pub get
flutter run -d linux
```

The default Orchestrator URL is:

```text
wss://192.168.4.1/ws
```

Normal workflow: connect to the Orchestrator, receive a `state_snapshot`, list
registered devices, then use Devices and Chamber controls. The Dashboard is an
operator UI: Chamber controls are built from registered device labels and
capabilities, not raw Matter node, endpoint, cluster, or attribute IDs.
Developer workflow: use the Developer screen for raw Matter and Thread tools.

## WebSocket Protocol

Every command is a request envelope with a client-generated `request_id`.
Sending a WebSocket frame only means the command was submitted; success is shown
only after a matching `command_result` with `ok: true`.

```json
{
  "type": "command",
  "request_id": "req-...",
  "action": "thread.status_get",
  "payload": {}
}
```

The dashboard handles these inbound message types:

- `command_result`: matched by `request_id`; `ok: false` displays
  `error.message`.
- `state_snapshot`: updates Wi-Fi, Thread, Matter, and WebSocket runtime cards.
- `event`: appended to recent event logs. `event=matter.attribute_report`
  carries asynchronous semantic sensor values.
- `error`: shown as a protocol error event.

Operator commands include `device.list`, `device.get`, `device.rename`,
`device.remove`, `chamber.status_get`, `device.temperature.read`,
`device.pressure.read`, and `device.relay.set`. Raw Matter commands remain in
Developer.

## Device Registry And Chamber Controls

`device.list` returns a capability-aware registry. Each `DeviceRecord` contains
operator labels, reachability, optional product/location metadata, and a
`capabilities[]` list. Supported semantic capability types are:

- `temperature`
- `pressure`
- `relay`
- `raw_attribute`
- `raw_command`

The Devices page shows the registry and capability technical details for
administration. The Chamber page filters capabilities into temperature,
pressure, and relay selectors such as:

```text
BMP280 Sensor - Temperature
BMP280 Sensor - Pressure
Mist Relay - On/Off
```

Semantic sensor reads may complete asynchronously. A successful
`device.temperature.read` or `device.pressure.read` command can return
`accepted=true` and `result_delivery=matter.attribute_report`; the Dashboard then
shows a waiting state until the value arrives in an event:

```json
{
  "type": "event",
  "event": "matter.attribute_report",
  "payload": {
    "device_id": "bmp280-1",
    "semantic_type": "temperature",
    "temperature_celsius": 23.41,
    "raw_measured_value": 2341
  }
}
```

## Certificate Trust

Secure connections use per-device SHA-256 certificate fingerprint pinning. A
normal WSS connection requires a trusted fingerprint for the host and rejects a
changed certificate with a clear mismatch error.

Use **Pair / Trust Orchestrator** on the Orchestrator page to explicitly enter
temporary trust mode. In that mode the Dashboard captures the observed server
certificate SHA-256 fingerprint, displays it, and lets the operator confirm and
save it for the host. Future normal connections use the saved fingerprint.
Manual fingerprint entry remains available only as a developer fallback.

`assets/rootCA.example.pem` is only a development example. Do not commit real
generated certificates, private keys, or device CA files. The app no longer
requires `assets/rootCA.pem` for WSS startup.
