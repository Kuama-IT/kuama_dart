# Kuama Packages

## MonoRepo

- Install (Only once) [melos package](https://pub.dev/packages/melos) package `dart pub global activate melos`
- You can run every script in [melos.yaml](melos.yaml) file with `melos run <SCRIPT>`

## Release

- Create branch
- Update packages version
- Update package versions that depend on updated packages
- Commit -> Push -> PR -> Merge
- Create tag
