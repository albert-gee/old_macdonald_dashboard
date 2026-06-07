# Old Macdonald Dashboard

Flutter operator app for the Old Macdonald Orchestrator.

Old Macdonald Dashboard is a professional local operator app for the
Orchestrator. It provides a connection-first workflow, guided Thread/Matter
infrastructure setup, Matter device commissioning and discovery, chamber device
assignment, live environmental monitoring, relay/fan manual control,
cooling-rule configuration, and actionable diagnostics. Raw protocol tools are
kept out of the normal operator path and remain available under Developer Tools.

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

- **Overview**: connection, Orchestrator health, Thread/Matter status, chamber
  state, and the next recommended action.
- **Setup**: guided connection, Thread dataset, Thread runtime, Matter
  controller, and device commissioning workflow.
- **Devices**: commissioned device registry, reachability, capability readiness,
  rename/remove actions, and collapsed raw Matter path details.
- **Chamber**: live readings, source/actuator assignments, manual relay/fan
  controls, min/max cooling thresholds, and automation state.
- **Diagnostics**: platform errors, Thread/Matter state, latest snapshot,
  protocol log, and copyable hardware validation commands.
- **Developer Tools**: raw Matter, Thread, command, and JSON diagnostics for
  debugging and recovery.

Operator workflow:

1. Connect the host computer or tablet to the Orchestrator Wi-Fi AP.
2. Open the Dashboard and use the global Connect button for
   `wss://192.168.4.1/ws`.
3. Confirm a `state_snapshot` arrives and follow the Overview next action.
4. Use Setup to create or verify the Thread dataset, enable Thread, initialize
   Matter, and commission devices.
5. Use Devices to refresh discovery and verify semantic capabilities.
6. Use Chamber to assign temperature and On/Off capabilities, manually control
   the fan/relay, save cooling thresholds, and enable automation.
7. Use Diagnostics when the Orchestrator reports degraded state, such as
   `MATTER_PLATFORM_INIT_FAILED:ESP_FAIL`.

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

Operator commands include `device.list`, `device.get`, `device.refresh`,
`device.rename`, `device.remove`, `chamber.status_get`, `device.temperature.read`,
`device.pressure.read`, `device.relay.set`, Thread setup commands,
`matter.controller_init`, `matter.pair_ble_thread`, and
`control.temperature.upsert`. Device read, relay, and cooling-rule commands
include both `device_id` and `capability_id`. Raw Matter commands remain in
Developer Tools.

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
    "capability_id": "sensor-1-ep1-temperature",
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
