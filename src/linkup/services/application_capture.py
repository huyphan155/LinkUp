import win32gui
import win32process
import psutil
from pathlib import Path
import json

from models.executable_item import ExecutableItem
from utils.path_connect import CONFIG_DIR

class ApplicationCapture:
    """
    Capture all visible desktop applications.
    """

    IGNORED_EXECUTABLES = {
        "chrome.exe",              # Captured by Chrome Extension
        "applicationframehost.exe",
        "runtimebroker.exe",
        "searchhost.exe",
        "shellexperiencehost.exe",
        "textinputhost.exe",
        "taskmgr.exe",
        # Ignore LinkUp itself
        "linkup.exe",
    }

    @staticmethod
    # Convert HWND to ExecutableItem
    def _create_executable_item(hwnd):

        if win32gui.IsWindow(hwnd):

            # Get Process (PID) of this Window
            _, pid = win32process.GetWindowThreadProcessId(hwnd)

            # from pid, take the infor about file .exe
            try:
                process  = psutil.Process(pid)
                exe_name = process .name()
                exe_path = process .exe()
            except Exception:
                exe_name = "Unknown"
                exe_path = "Unknown"
                return None

            if exe_name.lower() in ApplicationCapture.IGNORED_EXECUTABLES:
                return None

            return ExecutableItem(
                name=win32gui.GetWindowText(hwnd).strip(),
                enabled=True,
                path=exe_path,
                arguments=[]
            )
        else:
            # print(f"HWND {hwnd} not valid! Application is closed/not visible.")
            return None

    @staticmethod
    # Internal callback used by EnumWindows()
    def _enum_window_callback(hwnd, result_list):
        title = win32gui.GetWindowText(hwnd)
        # only record visible window, skip underground task
        if title.strip() and win32gui.IsWindowVisible(hwnd):
            item = ApplicationCapture._create_executable_item(hwnd)
            if item:
                result_list.append(item)

        return True

    @staticmethod
    def capture() -> list[ExecutableItem]:

        result_list = []
        win32gui.EnumWindows(ApplicationCapture._enum_window_callback, result_list)

        # Remove duplicated executable path
        unique_apps = []
        seen_paths = set()

        for app in result_list:

            path = app.path.lower()

            if path in seen_paths:
                continue

            seen_paths.add(path)
            unique_apps.append(app)

        return unique_apps

    @staticmethod
    def export(output_path: Path | None = None):
        """
        Capture all running applications and export to LinkUp workspace JSON.
        """
        if output_path is None:
            output_path = CONFIG_DIR /"current_app.json"

        applications = ApplicationCapture.capture()

        workspace = {
            "name": output_path.stem,
            "description": "",
            "items": []
        }

        for app in applications:
            workspace["items"].append({
                "type": "executable",
                "name": app.name,
                "enabled": app.enabled,
                "path": app.path,
                "arguments": app.arguments
            })

        with open(output_path, "w", encoding="utf-8") as file:
            json.dump(
                workspace,
                file,
                indent=4,
                ensure_ascii=False
            )






