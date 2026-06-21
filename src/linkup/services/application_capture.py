import win32gui
import win32process
import psutil

from models.executable_item import ExecutableItem

class ApplicationCapture:

    @staticmethod
    # internal function for opening window check : HWMD -> ExecutableItem
    def _create_executable_item(hwnd):

        if win32gui.IsWindow(hwnd):

            # Get Process (PID) of this Window
            _, pid = win32process.GetWindowThreadProcessId(hwnd)

            # from pid, take the infor about file .exe
            try:
                proc = psutil.Process(pid)
                exe_name = proc.name()
                exe_path = proc.exe()
            except Exception:
                exe_name = "Unknown"
                exe_path = "Unknown"

            return ExecutableItem(
                name=exe_name,
                enabled=True,
                path=exe_path,
                arguments=[]
            )
        else:
            # print(f"HWND {hwnd} not valid! Application is closed/not visible.")
            return None

    @staticmethod
    # internal callback for open window check
    def enum_window_callback(hwnd, result_list):
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
        win32gui.EnumWindows(ApplicationCapture.enum_window_callback, result_list)

        return result_list






