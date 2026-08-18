from datetime import datetime

from PyQt6.QtWidgets import QWidget, QPlainTextEdit, QVBoxLayout


class ActivityLogWidget(QWidget):
    """
    Display LinkUp activity logs.
    """

    def __init__(self):
        super().__init__()

        # Log display
        self.log_widget = QPlainTextEdit()

        # User should not edit logs
        self.log_widget.setReadOnly(True)

        # Main layout
        layout = QVBoxLayout()
        layout.addWidget(self.log_widget)

        self.setLayout(layout)

    def log(self, message: str):
        """
        Add a timestamped message to the activity log.
        """
        timestamp = datetime.now().strftime("%H:%M:%S")

        self.log_widget.appendPlainText(
            f"[{timestamp}] {message}"
        )

    def clear(self):
        """
        Clear all activity logs.
        """
        self.log_widget.clear()
