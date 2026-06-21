import win32gui
import win32process
import psutil
import sys

def check_app(hwnd):
    if win32gui.IsWindow(hwnd):
        _, pid = win32process.GetWindowThreadProcessId(hwnd)
        try:
            proc = psutil.Process(pid)
            exe_name = proc.name()
            exe_path = proc.exe()
        except Exception:
            exe_name = "Unknown"
            exe_path = "Unknown"

        # Không mở/đóng file tại đây nữa, chỉ print bình thường
        print(f"--- THÔNG TIN CỬA SỔ HWND: {hwnd} ---")
        print(f"Ứng dụng (.exe): {exe_name}")
        print(f"Mã định danh Process (PID): {pid}")
        print(f"Đường dẫn file: {exe_path}\n")
    else:
        print(f"HWND {hwnd} không tồn tại hoặc cửa sổ này đã bị đóng rồi!")

def enum_window_callback(hwnd, extra):
    title = win32gui.GetWindowText(hwnd)
    if title.strip() and win32gui.IsWindowVisible(hwnd):
        check_app(hwnd)

# --- THỰC THI CHƯƠNG TRÌNH VÀ GHI LOG TOÀN BỘ ---
# Mở file terminal_output.txt ở hàm main chính
with open("terminal_output.txt", "w", encoding="utf-8") as log_file:
    # Lưu lại stdout gốc
    original_stdout = sys.stdout
    # Đổi hướng stdout sang file
    sys.stdout = log_file

    print("--- DANH SÁCH CÁC CỬA SỔ ĐANG MỞ ---")
    win32gui.EnumWindows(enum_window_callback, None)

    # Trả lại stdout ban đầu sau khi kết thúc khối lệnh block "with"
    sys.stdout = original_stdout

print("Đã xuất danh sách thành công vào file terminal_output.txt!")
