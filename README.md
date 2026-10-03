# 🚀 Windows Terminal & PowerShell Dotfiles

Script tự động thiết lập môi trường Terminal hiện đại cho lập trình viên trên Windows:
- **Oh My Posh**: Prompt theme engine tuyệt đẹp (mặc định Catppuccin, tích hợp Git status, Python venv, execution time).
- **MesloLGM Nerd Font**: Hiển thị đầy đủ glyphs/icons lập trình.
- **PowerShell 7**: Phiên bản PowerShell mới nhất, tốc độ cao.
- **PSReadLine 2.4.5**: Gợi ý lệnh thông minh theo lịch sử (Predictive IntelliSense), chuyển đổi linh hoạt giữa dòng mờ (`InlineView`) và menu danh sách (`ListView`) bằng phím `F2`.
- **posh-git**: Tự động gợi ý mọi lệnh Git, nhánh (branches), cờ (flags) với menu trực quan khi bấm `Tab` / `Ctrl + Space`.
- **Terminal-Icons**: Tự động hiển thị icon thư mục và file khi gõ lệnh.
- **Windows Terminal & VS Code**: Tự động cấu hình font `MesloLGM Nerd Font` đồng bộ.

---

## ⚡ Cài đặt nhanh bằng 1 dòng lệnh

Mở **PowerShell** và chạy lệnh sau:

```powershell
irm https://raw.githubusercontent.com/nhatxtn/dotfiles/main/setup-terminal.ps1 | iex
```

---

## 🛠️ Phím tắt & Lệnh tiện ích

| Phím tắt / Lệnh | Mô tả |
|---|---|
| `Tab` hoặc `Ctrl + Space` | Mở menu tương tác chọn lệnh Git / tham số |
| `F2` | Đổi qua lại giữa `ListView` (menu lịch sử) và `InlineView` (dòng chữ mờ) |
| `→` hoặc `Ctrl + f` | Nhận toàn bộ câu lệnh gợi ý |
| `Ctrl + →` | Nhận gợi ý theo từng từ một |
| `↑` / `↓` | Lọc và tìm lại các lệnh lịch sử theo từ khóa đã gõ |
| `Ctrl + r` | Tìm kiếm tương tác trong toàn bộ lịch sử lệnh |
| `Get-PoshThemes` | Xem danh sách các theme Oh My Posh đã tải |
| `Set-PoshTheme <name>` | Đổi theme tức thì (`catppuccin`, `tokyonight_storm`, `atomic`,...) |
| `Set-SuggestionStyle` | Chọn kiểu hiển thị gợi ý (`-Style List` hoặc `-Style Inline`) |
| `reload` | Tải lại cấu hình PowerShell profile ngay lập tức |
| `ll` | Xem danh sách file/thư mục kèm icons |
