class Seat {
  final int id;
  final int row;
  final int col;

  /// AVAILABLE / LOCKED / SOLD
  String status;

  /// 仅用于前端“临时选择”（UI高亮、底部统计）
  /// 注意：最终应该由后端 LOCKED/SOLD 决定，但为了不大改UI先保留。
  bool selected;

  Seat({
    required this.id,
    required this.row,
    required this.col,
    required this.status,
    this.selected = false,
  });

  bool get isSold => status == 'SOLD';
  bool get isLocked => status == 'LOCKED';
  bool get isAvailable => status == 'AVAILABLE';

  /// 兼容旧代码：seat.sold
  bool get sold => isSold;

  /// 兼容旧代码：seat.selected
  set selectedCompat(bool v) => selected = v;
}