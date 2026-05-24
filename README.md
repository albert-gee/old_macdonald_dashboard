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
registered devices, then use Devices and Chamber controls. Developer workflow:
use the Developer screen for raw Matter and Thread tools.

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
- `event`: appended to recent event logs.
- `error`: shown as a protocol error event.

Operator commands include `device.list`, `device.get`, `device.rename`,
`device.remove`, `chamber.status_get`, `device.temperature.read`,
`device.pressure.read`, and `device.relay.set`. Raw Matter commands remain in
Developer.

## Certificate Trust

Secure connections use per-device SHA-256 certificate fingerprint trust. The
dashboard stores trusted fingerprints by host and rejects unexpected
fingerprints. Use the Orchestrator page to save or clear a trusted fingerprint.

`assets/rootCA.example.pem` is only a development example. Do not commit real
generated certificates, private keys, or device CA files. The app no longer
requires `assets/rootCA.pem` for WSS startup.
