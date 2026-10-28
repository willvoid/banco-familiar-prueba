/// An authenticated user session.
///
/// Send [accessToken] as `Authorization: Bearer <accessToken>` on later calls.
class Session {
  const Session({
    required this.accessToken,
    required this.tokenType,
    this.expiresIn,
  });

  final String accessToken;
  final String tokenType;

  /// Token lifetime reported by the server. There is no refresh.
  final Duration? expiresIn;
}
