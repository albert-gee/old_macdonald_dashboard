# Old MacDonald Dashboard

Flutter dashboard for the Old MacDonald Orchestrator.

The Dashboard is structured as an operator console, not a raw protocol panel.
Primary pages explain operational state first, with low-level diagnostics kept
in Developer or collapsed Advanced diagnostics sections.

## Run

```sh
flutter pub get
flutter run -d linux
```

The default Orchestrator URL is:

```text
wss://192.168.4.1/ws
```

## Product Structure

- **Orchestrator**: system connection, certificate trust, runtime state, and
  setup checklist.
- **Chamber**: day-to-day readings and actuator controls built from registered
  device capabilities.
- **Devices**: device registry status, reachability, and capability readiness.
- **Wi-Fi Network**: local Dashboard access and optional uplink Wi-Fi.
- **Thread Network**: Thread mesh readiness for chamber sensors and actuators.
- **Matter Network**: commissioned devices and chamber device onboarding.
- **Developer**: raw Matter, Thread, command, and event diagnostics.

Operator workflow: connect to the Orchestrator, trust the certificate, receive a
`state_snapshot`, onboard or verify devices, then use Chamber controls.
Installer/maintainer workflow: use Wi-Fi, Thread, Matter, and Devices pages to
verify setup. Developer workflow: use Developer for raw protocol diagnostics.

Chamber controls are built from registered device labels and capabilities, not
raw Matter node, endpoint, cluster, or attribute IDs.

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
administration. The Chamber page filters capabilities into environmental reading
and switchable actuator selectors such as:

```text
Environmental sensor - Temperature
Environmental sensor - Pressure
Switchable actuator - On/Off
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
    "device_id": "sensor-1",
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

## Verification Notes

Automated tests validate Dashboard-side command encoding, readiness models,
page rendering, certificate trust storage, and widget smoke coverage. Live WSS
verification requires the computer running the Dashboard to have a real network
path to the Orchestrator access point or a reachable uplink IP.
