from PyQt6.QtWidgets import (
    QMainWindow,
    QWidget,
    QVBoxLayout,
    QHBoxLayout
)

from PyQt6.QtWidgets import QPushButton
from PyQt6.QtWidgets import QStatusBar

# user import
from ui.widgets.profile_list_widget import ProfileListWidget
from ui.widgets.workspace_preview_widget import WorkspacePreviewWidget
from ui.widgets.activity_log_widget import ActivityLogWidget
from services.ConfigProfile_Service import ConfigProfileService
from services.workspace_service import WorkspaceService
from services.launcher_service import LauncherService
from services.application_capture import ApplicationCapture


class MainWindow(QMainWindow):

    def __init__(self):
        super().__init__()

        self.setWindowTitle("LinkUp")
        # Status bar
        self.status_bar = QStatusBar()
        self.setStatusBar(self.status_bar)
        self.status_bar.showMessage("Ready")
        # self.resize(700, 500)
        self.setFixedSize(400, 300)
        self.setMinimumSize(200,300) # min
        self.setMaximumSize(800,800) # max

        # Main layout
        main_layout = QVBoxLayout()
        # Top layout
        top_layout = QHBoxLayout()

        # Profile list
        self.profile_list = ProfileListWidget()

        # Launch button
        self.launch_button = QPushButton("Launch!")
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

        # Central Widget(QWidget)            # QWidget
        #     │
        #     └── QVBoxLayout                # main_layout
        #            │
        #            └── self.profile_list   # widget of main_layout
        #            └── self.launch_button  # widget of main_layout
        top_layout.addWidget(self.profile_list)
        top_layout.addWidget(self.preview)

        main_layout.addLayout(top_layout)

        main_layout.addWidget(self.launch_button)
        main_layout.addWidget(self.capture_button)
        main_layout.addWidget(self.activity_log)

        central_widget = QWidget()
        central_widget.setLayout(main_layout)
        self.setCentralWidget(central_widget)

    # status bar status
    def _status_bar(self, message: str, timeout: int = 0):
        self.status_bar.showMessage(message, timeout)

    # launch button slot
    def _launch_button_clicked(self):
        self._status_bar("Launching...")
        # Log activity
        self.activity_log.log("Launching...")
        selected_profiles = self.profile_list.selected_profiles()
        for profile_name in selected_profiles:
            # Log activity
            self.activity_log.log(f"Loading profile: {profile_name}")
            # get path of profile_name
            path = ConfigProfileService.get(profile_name)
            # load workspace from path
            workspace = WorkspaceService.load(path)
            # launch from workspace
            LauncherService.launch(workspace)
            # Log activity
            self.activity_log.log(f"✔ {profile_name} launched.")
        self._status_bar("Launch completed.")
        # Log activity
        self.activity_log.log("Launch completed.")

    # capture button slot
    def _capture_button_clicked(self):
        self._status_bar("Capturing applications...")
        self.activity_log.log("Capturing applications...")
        # application is capture and export to ./config/current_app.json
        ApplicationCapture.export()
        self.activity_log.log(
            "✔ Applications captured.",
            "✔ Exported ./config/current_app.json",
            "Capture completed."
        )
        self._status_bar("Capture completed.",3000)

    # work space preview slot
    def _profiles_changed(self, profiles: list[str]):

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
        # get path of profile_name
        path = ConfigProfileService.get(profile_name)
        # load workspace from path
        workspace = WorkspaceService.load(path)
        # preview from workspace
        self.preview.show_workspace(workspace)







