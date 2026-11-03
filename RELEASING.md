# Releasing highs-sys

The crate version follows HiGHS: same `MAJOR.MINOR`, and a `PATCH` at least
as high as HiGHS's. Binding-only releases bump the crate's `PATCH`.

## Prepare the release

- **New HiGHS release**: run `scripts/update-highs.sh` (or
  `scripts/update-highs.sh v1.16.0` for a specific tag). It opens a PR that
  updates the submodule and crate version. Add any new C API constants to
  `src/lib.rs`, then merge.
- **Binding-only release**: bump `version` in `Cargo.toml` and merge.

## Publish

A crates.io owner of `highs-sys` publishes from an up-to-date `master`:

```sh
git checkout master && git pull
git submodule update --init       # the submodule must match the commit (#51)
scripts/check-highs-version.sh
cargo publish
git tag vX.Y.Z && git push origin vX.Y.Z   # X.Y.Z = version in Cargo.toml
```

`cargo publish` packages whatever is in the `HiGHS/` folder on disk, so never
skip the `git submodule update` and the check script.

## Testing unreleased HiGHS

- CI runs nightly against the HiGHS `latest` branch.
- HiGHS's CI can test every commit by calling `rust-or/highs-sys/.github/workflows/rust.yml@master`
  with `highs_ref: <commit>`.
- Locally:

  ```sh
  git -C HiGHS fetch origin latest && git -C HiGHS checkout FETCH_HEAD
  cargo test
  git submodule update   # back to the committed version
  ```
