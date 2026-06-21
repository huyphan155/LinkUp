from services.workspace_service import WorkspaceService
from services.launcher_service import LauncherService
from pathlib import Path

from services.application_capture import ApplicationCapture
import sys

def main():
    print("Hello from linkup!")
    # workspace = WorkspaceService.load(
    #     Path("D:/GitWork/LinkUp/config/workspace.json")
    # )
    # LauncherService.launch(workspace)
    # print(workspace)

    abc = ApplicationCapture.capture()

    with open("terminal_output.txt", "w", encoding="utf-8") as log_file:
        # Lưu lại stdout gốc
        original_stdout = sys.stdout
        # Đổi hướng stdout sang file
        sys.stdout = log_file

        print(abc)

        # Trả lại stdout ban đầu sau khi kết thúc khối lệnh block "with"
        sys.stdout = original_stdout



if __name__ == "__main__":
    main()
