/// Defines the environment configuration interface for the application.
///
/// This abstract interface class defines the contract for environment configurations.
/// Each environment should implement this interface with its specific values.
///
/// Uses the abbreviated name `Env` instead of `Environment` to avoid naming conflicts
/// with third-party packages.
abstract interface class Env {
  /// The API key for Stadia Maps.
  abstract final String stadiaMapsApiKey;

  /// The API key for PositionStack.
  abstract final String positionStackApiKey;
}
