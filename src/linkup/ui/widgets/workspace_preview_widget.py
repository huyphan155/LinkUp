from sys import executable

from PyQt6.QtWidgets import QWidget
from PyQt6.QtWidgets import QListWidget
from PyQt6.QtWidgets import QVBoxLayout

from models.workspace import Workspace
from models.url_item import UrlItem
from models.executable_item import ExecutableItem

class WorkspacePreviewWidget(QWidget):

    def __init__(self):
        super().__init__()

        # Preview layout
        Preview_layout = QVBoxLayout()

        # List widget
        self.list_widget = QListWidget()
        Preview_layout.addWidget(self.list_widget)

        self.setLayout(Preview_layout)

    def show_workspace(self, workspace: Workspace):
        self.list_widget.clear()

        for item in workspace.items:
            if isinstance(item, UrlItem):
                self.list_widget.addItem("🌐 " + item.name)
            if isinstance(item, ExecutableItem):
                self.list_widget.addItem("💻 " + item.name)

    def clear(self):
        self.list_widget.clear()

    def show_message(self, message: str):
        self.list_widget.clear()
        self.list_widget.addItem(message)