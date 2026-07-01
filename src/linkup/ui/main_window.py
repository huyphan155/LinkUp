from PyQt6.QtWidgets import (
    QMainWindow,
    QWidget,
    QVBoxLayout,
)

from PyQt6.QtWidgets import QPushButton

# user import
from ui.widgets.profile_list_widget import ProfileListWidget
from services.ConfigProfile_Service import ConfigProfileService
from services.workspace_service import WorkspaceService
from services.launcher_service import LauncherService


class MainWindow(QMainWindow):

    def __init__(self):
        super().__init__()

        self.setWindowTitle("LinkUp")
        # self.resize(700, 500)
        self.setFixedSize(400, 300)
        self.setMinimumSize(200,300) # min
        self.setMaximumSize(800,800) # max

        # Main layout
        main_layout = QVBoxLayout()

        # Profile list
        self.profile_list = ProfileListWidget()
        main_layout.addWidget(self.profile_list)

        # Launch button
        self.launch_button = QPushButton("Launch!")
        self.launch_button.clicked.connect(self._launch_button_clicked)
        main_layout.addWidget(self.launch_button)


        # Central Widget(QWidget)            # QWidget
        #     │
        #     └── QVBoxLayout                # main_layout
        #            │
        #            └── self.profile_list   # widget of main_layout
        #            └── self.launch_button  # widget of main_layout
        central_widget = QWidget()
        central_widget.setLayout(main_layout)
        self.setCentralWidget(central_widget)

    def _launch_button_clicked(self):
        selected_profiles = self.profile_list.selected_profiles()

        for profile_name in selected_profiles:
            # get path of profile_name
            path = ConfigProfileService.get(profile_name)
            # load workspace from path
            work_space = WorkspaceService.load(path)
            # launch from workspace
            LauncherService.launch(work_space)




