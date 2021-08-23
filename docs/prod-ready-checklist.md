# Medge's Production Ready Checklist

This is NOT a "do it all or don't go to prod" list. Just a collection of considerations (some more important than others) to at least think about before deploying to production

## Versioning

- Semantic versioning - `Major.Minor.Patch`
    - Major versions can CHANGE functionality as needed (provide migration steps as appropriate)
    - Minor versions should only ADD functionality, not alter them. Deprecation warnings added
    - Only bug fixes/hot fixes. Patch versions should not introduce new functionality or change functionality

Tag git commits (`git tag`) for releases with the current version of the code for easy checkouts

## Releases & Branching

- Code released to `main` branch and tagged with current release version
    - Recommend squash commits for cleaner history
- If using GitFlow, merge back up to `dev` once complete to ensure history is synced
    - Use `dev` as an automated deploy branch for DEV environments

## Build & Deploy

- Have a CI server pointing to `main` that:
    - Runs the test suit and reports status on a build page or back to the repository (build badges)
    - Collects coverage metrics if available and reports them on the build page
    - Builds a clean artifact (not from cache)
    - Runs load tests / E2E tests on a temporary instance of the code
- Final deployable artifact produced from the build tool without human involvement
- Do not have separate versions of the code for separate environments. Use environment-based configuration
    - Configuration should be as consistent as possible
    - Don't change technologies (i.e use Postgres throughout environments. Don't swap to MySQL in DEV)
- Deploy artifact through CI or kick off external process to deploy from CI
- Apply Database Migrations as necessary to the target environment on artifact startup

### Blue/Green Deployments

- Green = currently active instance. Blue = additional instance with updated artifact
- Spin up new instance with new artifact to deploy (blue)
- If successful deployment of new instance - spin down original instance (green) and redeploy with new artifact

This process assumes at least 2 active instances are running. For a single running instance there also needs to be some form of traffic routing (proxy, load balancer, etc)
which can be toggled over to the new instance.

## Rollbacks

- Database change rollbacks automated
- Previous versions of the application available and identified as the `rollback artifact`
- If deployment fails, rollback should initiate if not using Blue/Green deployments

## Logging

- Logs should be structured (ex: JSON), not free-form text
    - This aids in log querying on tools like Splunk, Kibana, Graylog, etc
- Logging to an interface and not an implentation (ex slf4j, not log4j) in JVM languages
- DEBUG turned on in DEV, off elsewhere, for app code.
    - Alternatively - sift DEBUG logs to a separate location and automatically clean after 30 days
- Console, File (Daily/Monthly), and Sifting (if applicable) loggers
- If applicable, pipe logs to central sink
    - Logstash
    - Graylog
    - Others

## Metrics

- Inputs / outputs to / from external services
- Error rates
- Usage counts (to identify hot/dead features)
- Tracing
- Timings for core functionality

## Monitoring

- Metrics accessible from either a secured API or in a separate DB/file
- Metrics updated at configurable time windows (every 2-5 minutes is common)
- Prometheus can scrape if in Prometheus format.
    - JSON format == custom UI possibilities
- Health Checks for external resource access (DB Connections, API pings, etc)
    - Use small, lightweight, calls (ex. `SELECT 1` for DBs)
    - Responses contain at least service name and status enum (UP/DOWN/WARNING)
- Ping endpoint available to automate "app is alive" check
    - Avoid calling external resources for speed and use by schedulers like Load Balancers

## Tests

- Unit Tests should not depend on any external resources (network, file system, DB, etc)
- Tests should not test the language or framework. Rather, they should test the business logic
    - ex. `assert repository.save() created a db record`
- Integration Tests should use local variants of external resources
    - Ex: H2 in memory DB, embedded Message broker, etc
- Load Testing performed on any customer-facing API
- Functional tests run against a live instance
    - Preferably packaged and deployable to be run by the CI/CD process

## Web - REST

- API paths versioned (/api/v1/...)
- Service layer separates Persistence layer
- Errors mapped to parseable Responses, not Generic 500 errors
- Domain Models mapped to user responses, not to other layers
- Metric: 404s, 500s, Error rates
- Metric: API timings round trip

## Persistence

- Audit fields for createdDate, lastModifiedDate
- Migrations prepared through migration script/tool
    - DEV/QA should be cleaned on deployment and/or should be set to test schema upgrades on "known" state
- Metric: DB round trip times
- Metric: error rates

## Infrastructure

- Simpler is better - less to break
- Docker images preferable for their reduced deployment context
- Health check your instances at least for "alive" check
