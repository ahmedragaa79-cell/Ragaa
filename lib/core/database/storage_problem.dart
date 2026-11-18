/// Safe recovery states. Never repair a failing open by replacing the file.
enum StorageProblem implements Exception {
  corrupt,
  incompatible,
  noDurableBrowserStorage,
}
