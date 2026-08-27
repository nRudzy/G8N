# G8N-026 — Local incremental schedule and bounded backfill

Status: implemented as configuration and inactive workflow skeleton; not executed.

## Purpose

G8N needs a local daily collection window with overlap so missed or delayed runs do not create holes. Idempotence and deduplication absorb overlaps.

## Schedule

`config/france-travail.schedule.json` defines an Europe/Paris daily schedule at 06:15. The exported workflow is inactive; the user enables the schedule locally in n8n after validating credentials and data writes.

## Incremental windows

The incremental window starts from `checkpoint_json.last_successful_window_end_utc` minus the configured overlap. If no checkpoint exists, it uses a 24-hour lookback. The watermark is advanced only when the whole window is completed.

Failed, partial or cancelled windows do not advance the watermark.

## Backfill

Manual backfill requires explicit UTC start and end dates. A run is capped to 7 days and split into 24-hour sub-windows. Failed sub-windows are resumable.

## Concurrency

The logical lock key is:

```text
source + ":" + window_start_utc + ":" + window_end_utc
```

If an active `started` run already exists for the same source/window, the skeleton returns `skipped_locked` instead of starting concurrent work.

## Workflow skeleton

`workflows/wf-22-france-travail-incremental-schedule.json` is inactive. It computes windows and delegates actual collection/persistence/normalization/deduplication to WF-10, WF-11, WF-20 and WF-21 after local wiring.

It does not enable a real schedule, execute workflows, read Data Tables or call APIs in the cloud.

## Local validation commands not executed in cloud

The user can validate later with:

```shell
docker compose up -d
```

Then in n8n:

1. Import `workflows/wf-22-france-travail-incremental-schedule.json`.
2. Confirm the Europe/Paris schedule is disabled before manual review.
3. Simulate no checkpoint, nominal daily checkpoint and one missed day.
4. Simulate double trigger and verify `skipped_locked`.
5. Simulate a 3-day backfill split into sub-windows with one failed sub-window.
6. Enable the local schedule only after WF-10/WF-11/WF-20/WF-21 are validated.

No command, workflow import, schedule enablement, validation, Data Table read/write or API call was executed in the cloud authoring environment.
