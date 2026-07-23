# Contributing

## Commit messages

This project follows the [Conventional Commits](https://www.conventionalcommits.org/) format:

```text
<type>(optional-scope): <description>
```

Examples:

```text
feat(auth): add login validation
fix(docker): preserve frontend dependencies
docs(readme): document project setup
test(profile): cover invalid image upload
```

### Allowed types

| Type       | Use                                                       |
| ---------- | --------------------------------------------------------- |
| `feat`     | Add new functionality                                     |
| `fix`      | Correct a bug                                             |
| `docs`     | Change documentation only                                 |
| `test`     | Add or update tests                                       |
| `refactor` | Change code without adding a feature or fixing a bug      |
| `style`    | Change formatting or code style without changing behavior |
| `perf`     | Improve performance                                       |
| `build`    | Change dependencies or the build system                   |
| `ci`       | Change CI/CD configuration                                |
| `chore`    | Perform maintenance work                                  |
| `revert`   | Revert a previous commit                                  |

### Rules

- Use a lowercase type and scope.
- Add a scope only when it provides useful context.
- Write the description in the imperative mood.
- Do not end the subject with a period.
- Keep the subject at 72 characters or fewer.
- Use the commit body or footer when more context is needed.
- Mark breaking changes with `!` or a `BREAKING CHANGE:` footer.

Breaking-change example:

```text
feat(auth)!: replace token authentication with sessions

BREAKING CHANGE: API clients must now use the session cookie.
```

Git-generated merge, revert, fixup, and squash commit subjects are allowed.

## Enable the local commit hook

After cloning the repository, run:

```bash
git config core.hooksPath .githooks
```

Confirm the configuration:

```bash
git config --get core.hooksPath
```

Expected output:

```text
.githooks
```

The hook provides immediate local feedback. Pull request commits are also validated in GitHub Actions because local hooks can be bypassed with `--no-verify`.
