# Maven registry

A public Maven repository on R2. The read host serves the bucket anonymously
through an R2 custom domain. The publish host is a Worker accepting PUT from
GitHub Actions using the run OIDC token.

## Consume

Gradle:
```kotlin
repositories { maven { url = uri("https://maven.c0x12c.com") } }
```
Maven:
```xml
<repositories>
  <repository><id>public</id><url>https://maven.c0x12c.com</url></repository>
</repositories>
```

## Publish from Actions

Grant the publishing job `permissions: {contents: read, id-token: write}`.
Apply `maven-publish` and configure publications in the build. Save this Groovy
init script as `publish.init.gradle`, then run `./gradlew -I publish.init.gradle publish`:
```groovy
import groovy.json.JsonSlurper
import org.gradle.api.publish.maven.tasks.PublishToMavenRepository
allprojects {
    plugins.withId('maven-publish') {
        publishing.repositories.maven {
            name = 'pub'
            url = uri('https://maven-publish.c0x12c.com')
            credentials { username = 'oidc'; password = 'pending' }
        }
        tasks.withType(PublishToMavenRepository).configureEach {
            doFirst {
                if (repository.name == 'pub') {
                    def endpoint = System.getenv('ACTIONS_ID_TOKEN_REQUEST_URL')
                    def connection = new URL(endpoint + '&audience=c0x12c-maven-publish').openConnection()
                    connection.setRequestProperty('Authorization', 'bearer ' + System.getenv('ACTIONS_ID_TOKEN_REQUEST_TOKEN'))
                    repository.credentials.password = new JsonSlurper().parse(connection.inputStream).value
                }
            }
        }
    }
}
```
Every publish task fetches a fresh token because OIDC tokens are short-lived.
Any username works; the password carries the token. Never log tokens.

## Rules and configuration

Released files are immutable: re-PUT returns 409. Only `maven-metadata.xml` and
its checksums are overwritable. Snapshots upload new timestamped files.
Objects have a 100 MB maximum; paths allow only `[A-Za-z0-9._+/-]`. Allowed file
types: jar, pom, module, xml, aar, war, klib, zip, tar.gz, asc and checksums; others
get 415. XML and POM are served as text/plain so a browser never runs script in them.
Worker vars: `OIDC_AUDIENCE`, `ALLOWED_OWNERS`, `ALLOWED_REPOS`, `MAX_BYTES`.
Repository variables: `MAVEN_REGISTRY_DEPLOY_ENABLED`, `MAVEN_ALLOWED_OWNERS`,
`MAVEN_ALLOWED_REPOS` (required; an empty list rejects every publish). Use
`<owner>/<repo>` entries for allowed repositories.

## Operations and limits

One-time bootstrap: run Maven Registry Deploy with `bootstrap: true` and the
zone id. Set the repository variables, then deploy. Configure the repository
secrets `CLOUDFLARE_API_TOKEN` and `CLOUDFLARE_ACCOUNT_ID` before bootstrap.
Only `push` and `workflow_dispatch` runs on `master` or `main` of a listed repo can
publish (no tags, pull-request or comment-triggered runs). Such a run can add new
files under ANY group path and rewrite metadata, so keep `ALLOWED_REPOS` narrow.
A failed release publish cannot be retried at the same version.
R2 storage costs 0.015 USD per GB-month; 10 GB, 1M writes and 10M reads are free
per month, with zero egress. Roll back from this directory with `wrangler rollback`.
