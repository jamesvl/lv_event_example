## Minimal LiveView Event Bug(?)

This repo was created to help document a change to event handling
between LiveView 0.18 and 0.19.

### Step to Reproduce

Run each of the sample Elixir files (may be done side by side if you like) from your
console.

```
elixir lv_event_example.ex
# in another terminal
elixir lv_event_example_018.ex
```

Open your browser to `http://localhost:5001/` and `http://localhost:6001/` (respectively).

Click on the labels "Yes" and "No".
Use the keyboard to navigate the selected radio from "Yes to "No".

### Differences

Clicking the label:
* in LiveView 0.18 emits both a "click" and "focus" event.
* in 0.19, it emits only the "focus" event

Using keyboard navigation:
* in LiveView 0.18 the keyboard navigation emits both the "click" and "focus" event
* on 0.19 it emits only the "focus" event

