from PyQt6.QtWidgets import (
    QWidget,
    QGroupBox,
    QVBoxLayout,
    QCheckBox,
)


class ProfileListWidget(QWidget):

    def __init__(self):
        super().__init__()

        # Main layout
        main_layout = QVBoxLayout()

        # Group box
        group_box = QGroupBox("Config Profiles")

        # Layout inside group box
        group_layout = QVBoxLayout()

        profiles = [
            "Default",
            "Profile1",
            "current_app",
        ]

        for profile in profiles:
            checkbox = QCheckBox(profile)
            group_layout.addWidget(checkbox)

        group_box.setLayout(group_layout)

        main_layout.addWidget(group_box)

        self.setLayout(main_layout)