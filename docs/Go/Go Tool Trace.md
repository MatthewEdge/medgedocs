## Tracing Hot Paths
One very sneaky problem that can crop up with Traces (OTel) is trace bulk in code hot paths. For example: tracing every chunk write is a _bad_ idea as, under high concurrent loads, contention on the OTel Tracer mutex can cause pile ups and slowdowns surrounding. It takes a pretty high load to reach those points but if you start seeing `Tracer.Mutex.Lock/Unlock` show up on `go tool trace` under the `/block` profile - you're hitting this issue.

## Go Tool Trace vs. PPROF

Read a trace from an inactive service _first_ before trying to read a trace from a Production service. It makes it much easier to understand the anomalies vs. starting from chaos

### HTTP trace - Normal
A normal HTTP can look like the following:
![[http-trace-normal.png]]