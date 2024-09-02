Lessons learned with PGO in Production
## Measure Measure Measure!

Measure **before** AND **after** applying PGO. [[Metrics]] are key and it's important to have a baseline to compare to!
## Getting Started

The application must be running _in Production_ before you take the pprof profiles. Real production traffic produces the best profiles. Try to collect, at least, **30 seconds of a /profile**:

```
curl --data-binary -o instance1.pprof http://23.23.23.23:8080/admin/pprof/profile?seconds=30
```

[[PPROF]] profiles are likely to be collected via the [net/http/pprof](https://pkg.go.dev/net/http/pprof) package since accessing binaries directly is usually more of a pain. [[Service Kit]] exposes endpoints automatically for collection.

If there are multiple instances for the service, you'll want to collect profiles from, at least, a few instances **at different periods of time**. Traffic can vary! You then merge those profiles together with:

`go tool pprof -proto profile1 profile2 ... > default.pgo`

Note the `default.pgo` name. This is what `go build` looks for. You can change it but.. why bother?
## Iterating on Profiles

TODO lessons