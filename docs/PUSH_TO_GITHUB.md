# Pushing the monorepo to GitHub

The repository is ready: clean Git history with 3 labeled commits and an empty
worktree. Push it with any of the options below.

## Option A — via GitHub CLI (recommended)

```bash
cd vendorhub-ecosystem
gh repo create vendorhub-ecosystem --private --source=. --push
```

Requires `gh auth login` first.

## Option B — create repo in UI, then push

1. On github.com → **New repository** → name `vendorhub-ecosystem`, keep it
   private (don't "Add a README").
2. Copy the commands from the quick-setup block and run:

```bash
cd vendorhub-ecosystem
git remote add origin https://github.com/YOUR_USERNAME/vendorhub-ecosystem.git
git branch -M main
git push -u origin main
```

## Option C — I can push it for you

If you paste a **GitHub Personal Access Token** (classic with `repo` scope, or
fine-grained with Contents:Read/Writes on a new repo), I can run the push and
`git push -u origin main` with the token embedded. Use a fresh repo you create,
or let me create it via the GitHub API — tell me which.

> Security: never commit the token. It should only be used transiently for the
> push and then revoked.

## Good practice

- The repo already has `.gitignore` excluding `.env`, vendor, build artifacts.
- Keep the token out of `git` and out of any shell history that gets shared.
