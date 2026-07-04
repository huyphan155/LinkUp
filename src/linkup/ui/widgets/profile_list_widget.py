from PyQt6.QtWidgets import (
    QWidget,
    QGroupBox,
    QVBoxLayout,
    QCheckBox,
)

from PyQt6.QtCore import pyqtSignal

from services.ConfigProfile_Service import ConfigProfileService

class ProfileListWidget(QWidget):

    profiles_changed = pyqtSignal(list)
    def __init__(self):
        super().__init__()

        # Main layout
        self.main_layout = QVBoxLayout()
        # check boxs is empty
        self.checkboxes = []

        # Group box
        # +---------------------------+
        # | Config Profiles           |
        # |                           |
        # |                           |
        # +---------------------------+
        self.group_box = QGroupBox("Config Profiles")
        # Layout inside group box
        self.group_layout = QVBoxLayout()
        self.group_box.setLayout(self.group_layout)

        # Main layout
        self.main_layout.addWidget(self.group_box)
        self.setLayout(self.main_layout)
        # QWidget
        # │
        # └── main_layout
        #     │
        #     └── group_box
        #         │
        #         └── group_layout

        # Load profiles when widget is created
        self._load_profiles()

    def _load_profiles(self):
        """
        Load all config profiles and display them as checkboxes.
        """
        # Get all config files
        profiles = ConfigProfileService.scan()

        # Remove old checkboxes (for future refresh)
        while self.group_layout.count():
            item = self.group_layout.takeAt(0)
            if item.widget():
                item.widget().deleteLater()

        self.checkboxes.clear()

        # Create checkboxes
        for profile in profiles:
            # stem explain : Path("Default.json").stem -> Default
            checkbox = QCheckBox(profile.stem)
            # connect to slot function "self._checkbox_changed"
            checkbox.stateChanged.connect(self._checkbox_changed)
            self.checkboxes.append(checkbox)
            self.group_layout.addWidget(checkbox)


    def selected_profiles(self) -> list[str]:
        """
        Return all selected profile names.
        """

        selected = []

        for checkbox in self.checkboxes:

            if checkbox.isChecked():
                selected.append(checkbox.text())

        return selected

    def _checkbox_changed(self):
        """
        broadcast signal of selected profiles.
        """
        self.profiles_changed.emit(self.selected_profiles())