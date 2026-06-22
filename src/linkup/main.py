from services.workspace_service import WorkspaceService
from services.launcher_service import LauncherService
from pathlib import Path

from services.application_capture import ApplicationCapture
from services.ConfigProfile_Service import ConfigProfileService
import sys

import sys

from PySide6.QtWidgets import QApplication
from ui.main_window import MainWindow

def main():
    print("Hello from linkup!")
    # workspace = WorkspaceService.load(
    #     Path("D:/GitWork/LinkUp/config/workspace.json")
    # )
    # LauncherService.launch(workspace)
    # print(workspace)

    # abc = ApplicationCapture.capture()
    #
    # with open("terminal_output.txt", "w", encoding="utf-8") as log_file:
    #     # Lưu lại stdout gốc
    #     original_stdout = sys.stdout
    #     # Đổi hướng stdout sang file
    #     sys.stdout = log_file
    #
    #     print(abc)
    #
    #     # Trả lại stdout ban đầu sau khi kết thúc khối lệnh block "with"
    #     sys.stdout = original_stdout


    # ApplicationCapture.export(
    #     Path("D:/GitWork/LinkUp/config/current_app.json")
    # )

    # profiles = ConfigProfileService.scan()
    #
    # for profile in profiles:
    #     print(profile.name)

    app = QApplication(sys.argv)

    window = MainWindow()
    window.show()

    sys.exit(app.exec())



if __name__ == "__main__":
    main()
