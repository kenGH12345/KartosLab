/// Coin count rendering strategy -?Coins LayoutSpec / CoinSetPixelRepresentation.
library;

enum CoinRenderMode {
  /// 10 / 100 -?individual small coin nodes inside test box.
  individual,

  /// 10000 -?100×100 canvas pixel grid (never 10000 widgets).
  pixelCanvas,
}

CoinRenderMode coinRenderModeForCount(int count) {
  return count >= 10000 ? CoinRenderMode.pixelCanvas : CoinRenderMode.individual;
}
