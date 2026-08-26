# Amplify example using a GitHub App installation token

Connects the repository with a short-lived GitHub App installation token rather than a personal
access token, so there is no long-lived credential to store or rotate.

The token is passed as `github_oauth_token`, not `github_token`. Installation tokens (`ghs_`) run
about 380 characters and the Amplify API caps `access_token` at 255, so using `github_token` fails
during planning:

```
Error: expected length of access_token to be in the range (1 - 255), got ghs_...
```

The token is write-only and the repository connection is stored server-side, so its short lifetime
only matters when the app is first created - it is not a standing dependency for later builds.

## Usage

```bash
$ terraform init
$ terraform plan
```
