# Old MacDonald Dashboard

## Getting Started

Copy the generated root CA from the Orchestrator to `assets/rootCA.pem` before
running secure local WebSocket builds. The real `assets/rootCA.pem` file is
ignored because it is environment-specific. `assets/rootCA.example.pem` is a
non-sensitive development example.

## WebSocket Protocol

Commands are JSON envelopes. `payload` is always a JSON object, including for
commands with no arguments.

```json
{
  "type": "command",
  "action": "...",
  "payload": {}
}
```

| Action | Payload fields |
| --- | --- |
| `wifi.sta_connect` | `ssid`, `password` |
| `thread.enable` | none |
| `thread.disable` | none |
| `thread.status_get` | none |
| `thread.attached_get` | none |
| `thread.role_get` | none |
| `thread.active_dataset_get` | none |
| `thread.unicast_addresses_get` | none |
| `thread.multicast_addresses_get` | none |
| `thread.br_init` | none |
| `thread.br_deinit` | none |
| `thread.dataset.init` | `channel`, `pan_id`, `network_name`, `extended_pan_id`, `mesh_local_prefix`, `master_key`, `pskc` |
| `matter.controller_init` | `node_id` string, `fabric_id` number, `listen_port` number |
| `matter.pair_ble_thread` | `node_id` string, `setup_code`, `discriminator` |
| `matter.cluster_command_invoke` | `destination_id` string, `endpoint_id`, `cluster_id`, `command_id`, `command_data` |
| `matter.attribute_read` | `node_id` string, `endpoint_id`, `cluster_id`, `attribute_id` |
| `matter.attribute_subscribe` | `node_id` string, `endpoint_id`, `cluster_id`, `attribute_id`, `min_interval`, `max_interval` |
