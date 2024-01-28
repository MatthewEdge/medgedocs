## Pooling Patterns

In distributed systems, the Pooling pattern applies to more than just Database connections. `PGBouncer` is one such example of funneling many, potentially an unbounded number of, connections to a fixed set of connections to the target service. It is not always strictly necessary but often appears in background workers where scaling is often in how many instances you can throw at the problem.

If, for example, we have a small service pipeline like so:

![[sys-scaling-example.excalidraw]]

The `Ingest` service creates many requests that are queued for fulfillment by the `Task Runners`. Task Runners need to call out to the `Metadata` service, which sits over a `DB`, for necessary job info. We can assume that Task Runners have their own simple caches so as not to destroy the Metadata service outright. These caches will eventually expire, or a burst of cache misses can occur, which will cause a flood of requests to the Metadata service. Once flooded, the Metadata service overwhelms its DB with requests, which slows everything down. If the Task Runners have retry mechanisms - they can exacerbate the issue by extending the pummeling.

Rather than trying to coordinate Task Runner instances with a complicated Backoff coordinator, putting a Connection Pool between them and the Metadata Service can help keep the traffic going to the service under control. It's worth noting that this can be done client-side with a fairly simple semaphore limiter (often called Slots). What the correct number is for how many slots each Task Runner can have is up to the service and the infrastructure.

In a more big picture view: sacrificing a tiny bit of throughput (usually milliseconds in my experience) can save you from throwing money at the problem (buy more DB instances, deploy more service instances, etc).