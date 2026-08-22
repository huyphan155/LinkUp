from PyQt6.QtCore import QObject, pyqtSignal

from models.launch_result import LaunchResult
from services.ConfigProfile_Service import ConfigProfileService
from services.workspace_service import WorkspaceService
from services.launcher_service import LauncherService

class LaunchWorker(QObject):

    finished = pyqtSignal()
    error = pyqtSignal(str)
    log_requested = pyqtSignal(str)
    launch_result = pyqtSignal(object)

    def __init__(self, selected_profiles: list[str]):
        super().__init__()
        self.selected_profiles = selected_profiles  # Lưu dữ liệu vào instance variable

    def run(self):
        """
        Run launch in background thread.
        """
        try:
            for profile_name in self.selected_profiles:
                # Log activity
                self.log_requested.emit(f"Loading profile: {profile_name}")
                # get path of profile_name
                path = ConfigProfileService.get(profile_name)
                # load workspace from path
                workspace = WorkspaceService.load(path)
                # launch from workspace
                launch_result = LauncherService.launch(workspace)
                # pass the result back to main_window.py
                self.launch_result.emit(launch_result)

        except Exception as e:
            self.error.emit(str(e))

        else:
            self.finished.emit()