from PyQt6.QtWidgets import (
    QMainWindow,
    QWidget,
    QVBoxLayout,
    QHBoxLayout,
    QPushButton,
    QStatusBar,
)

from PyQt6.QtCore import QThread

# import helper
from utils.helper import log_launch_results

# user import
from ui.widgets.profile_list_widget import ProfileListWidget
from ui.widgets.workspace_preview_widget import WorkspacePreviewWidget
from ui.widgets.activity_log_widget import ActivityLogWidget

from services.ConfigProfile_Service import ConfigProfileService
from services.workspace_service import WorkspaceService
from services.launcher_service import LauncherService

from workers.capture_worker import CaptureWorker
from workers.launch_worker import LaunchWorker

class MainWindow(QMainWindow):

    def __init__(self):
        super().__init__()

        self.setWindowTitle("LinkUp")
        # Status bar
        self.status_bar = QStatusBar()
        self.setStatusBar(self.status_bar)
        self.status_bar.showMessage("Ready")
        # self.resize(700, 500)
        self.setFixedSize(600, 500)
        self.setMinimumSize(200,300) # min
        self.setMaximumSize(800,800) # max
        # Capture thread / worker
        self.capture_thread = None
        self.capture_worker = None
        self.launch_worker = None
        self.launch_thread = None

        # Main layout
        main_layout = QVBoxLayout()
        # Top layout
        top_layout = QHBoxLayout()

        # Profile list
        self.profile_list = ProfileListWidget()

        # Launch button
        self.launch_button = QPushButton("Launch!")
        # Disable launch if no profile is selected
        self.launch_button.setEnabled(False)
        self.launch_button.clicked.connect(self._launch_button_clicked)

        # Capture Applications button
        self.capture_button = QPushButton("Capture Applications!")
        self.capture_button.clicked.connect(self._capture_button_clicked)

        # preview widget
        self.preview = WorkspacePreviewWidget()

        # Activity log
        self.activity_log = ActivityLogWidget()

        # take signal from self.profile_list.profiles_changed
        # and connect to slot "self._profiles_changed"
        self.profile_list.profiles_changed.connect(self._profiles_changed)

        # ------------------------------------------------------------------
        # Central Widget                               (QWidget)
        # └── QVBoxLayout                                (main_layout)
        #      ├── QHBoxLayout                              (top_layout)
        #      │    ├── self.profile_list
        #      │    └── self.preview
        #      ├── QHBoxLayout                               (button_layout)
        #      │    ├── self.launch_button
        #      │    └── self.capture_button
        #      └── self.activity_log
        # ------------------------------------------------------------------

        # Profile list + Preview
        top_layout.addWidget(self.profile_list, 1)
        top_layout.addWidget(self.preview, 2)

        # Button layout
        button_layout = QHBoxLayout()
        button_layout.addWidget(self.launch_button)
        button_layout.addWidget(self.capture_button)

        # Main layout
        main_layout.addLayout(top_layout)
        main_layout.addLayout(button_layout)
        main_layout.addWidget(self.activity_log)

        # Stretch
        main_layout.setStretch(0, 3)
        main_layout.setStretch(1, 0)
        main_layout.setStretch(2, 2)

        # Central widget
        central_widget = QWidget()
        central_widget.setLayout(main_layout)
        self.setCentralWidget(central_widget)

    # ------------------------------------------------------------------
    # Status bar
    # ------------------------------------------------------------------
    def _status_bar(self, message: str, timeout: int = 0):
        self.status_bar.showMessage(message, timeout)

    # ------------------------------------------------------------------
    # launch button slot
    # ------------------------------------------------------------------
    def _launch_button_clicked(self):

        selected_profiles = self.profile_list.selected_profiles()
        if not selected_profiles:
            return

        # Prevent multiple launch operations
        self.launch_button.setEnabled(False)

        self._status_bar("Launching...")
        self.activity_log.log("Launching...")

        # Create thread
        self.launch_thread  = QThread()
        # Create worker
        self.launch_worker  = LaunchWorker(selected_profiles)

        # Move worker to background thread
        self.launch_worker.moveToThread(self.launch_thread)
        # Start worker when thread starts
        self.launch_thread.started.connect(self.launch_worker.run)

        # Worker signals
        self.launch_worker.finished.connect(self._launch_finished)
        self.launch_worker.error.connect(self._launch_error)
        self.launch_worker.log_requested.connect(self.activity_log.log)
        self.launch_worker.launch_result.connect(
            lambda result: log_launch_results(self.activity_log, result)
        )

        # Cleanup worker/thread
        self.launch_worker.finished.connect(self.launch_thread.quit)
        self.launch_worker.error.connect(self.launch_thread.quit)
        self.launch_thread.finished.connect(self._launch_thread_finished)

        # Start background thread
        self.launch_thread.start()

    def _launch_finished(self):
        self._status_bar("Launch completed.")

    def _launch_error(self,error_message: str):
        self.activity_log.log("✘ Launch failed.")
        self.activity_log.log(f"Error: {error_message}")
        self._status_bar("Launch failed.",5000)

    def _launch_thread_finished(self):
        self.launch_button.setEnabled(True)
        self.launch_worker.deleteLater()
        self.launch_thread.deleteLater()
        self.launch_worker = None
        self.launch_thread = None

    # ------------------------------------------------------------------
    # capture button slot
    # ------------------------------------------------------------------
    def _capture_button_clicked(self):
        # Prevent multiple capture operations
        self.capture_button.setEnabled(False)

        self._status_bar("Capturing applications...")
        self.activity_log.log("Capturing applications...")

        # Create thread
        self.capture_thread = QThread()
        # Create worker
        self.capture_worker = CaptureWorker()

        # Move worker to background thread
        self.capture_worker.moveToThread(self.capture_thread)
        # Start worker when thread starts
        self.capture_thread.started.connect(self.capture_worker.run)

        # Worker signals
        self.capture_worker.finished.connect(self._capture_finished)
        self.capture_worker.error.connect(self._capture_error)

        # Cleanup worker/thread
        self.capture_worker.finished.connect(self.capture_thread.quit)
        self.capture_worker.error.connect(self.capture_thread.quit)
        self.capture_thread.finished.connect(self._capture_thread_finished)

        # Start background thread
        self.capture_thread.start()


    def _capture_finished(self):
        self.activity_log.log(
            "✔ Applications captured.",
            "✔ Exported ./config/current_app.json",
            "Capture completed."
        )
        self._status_bar("Capture completed.",3000)

    def _capture_error(self,error_message: str):
        self.activity_log.log("✘ Capture failed.")
        self.activity_log.log(f"Error: {error_message}")
        self._status_bar("Capture failed.",5000)

    def _capture_thread_finished(self):
        self.capture_button.setEnabled(True)
        self.capture_worker.deleteLater()
        self.capture_thread.deleteLater()
        self.capture_worker = None
        self.capture_thread = None

    # ------------------------------------------------------------------
    # work space preview slot
    # ------------------------------------------------------------------
    def _profiles_changed(self, profiles: list[str]):
        # Enable Launch when at least one profile is selected
        self.launch_button.setEnabled(bool(profiles))

        # 0 profile select : clear
        if len(profiles) == 0:
            self.preview.clear()
            return
        # >2 profile : show message
        if len(profiles) > 1:
            self.preview.show_message("Select one profile to preview.")
            return
        # 1 profile : load -> preview
        profile_name = profiles[0]
        try:
            # get path of profile_name
            path = ConfigProfileService.get(profile_name)
            # load workspace from path
            workspace = WorkspaceService.load(path)
            # preview from workspace
            self.preview.show_workspace(workspace)
        except Exception as e:
            self.preview.show_message("Failed to load profile.")
            self.activity_log.log(f"✘ Failed to preview: {profile_name}")
            self.activity_log.log(f"Error: {e}")
