from PySide6.QtWidgets import (
    QMainWindow,
    QWidget,
    QVBoxLayout,
)

from ui.widgets.profile_list import ProfileListWidget
from ui.widgets.capture_panel import CapturePanel
from ui.widgets.status_panel import StatusPanel


class MainWindow(QMainWindow):

    def __init__(self):
        super().__init__()

        self.setWindowTitle("LinkUp")
        self.resize(700, 500)

        central_widget = QWidget()
        self.setCentralWidget(central_widget)

        layout = QVBoxLayout()

        self.profile_list = ProfileListWidget()
        self.capture_panel = CapturePanel()
        self.status_panel = StatusPanel()

        layout.addWidget(self.profile_list)
        layout.addWidget(self.capture_panel)
        layout.addWidget(self.status_panel)

        central_widget.setLayout(layout)