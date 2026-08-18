from sys import executable

from PyQt6.QtWidgets import QWidget
from PyQt6.QtWidgets import QTreeWidget, QTreeWidgetItem
from PyQt6.QtWidgets import QVBoxLayout

from models.workspace import Workspace
from models.url_item import UrlItem
from models.executable_item import ExecutableItem

class WorkspacePreviewWidget(QWidget):

    def __init__(self):
        super().__init__()

        # Tree widget
        self.tree_widget = QTreeWidget()
        # Hide tree widget header
        self.tree_widget.setHeaderHidden(True)

        # Preview layout
        Preview_layout = QVBoxLayout()
        Preview_layout.addWidget(self.tree_widget)

        self.setLayout(Preview_layout)

    def show_workspace(self, workspace: Workspace):
        self.tree_widget.clear()

        # Root: URLs
        url_root = QTreeWidgetItem(["🌐 URLs"])
        # Root: Applications
        app_root = QTreeWidgetItem(["💻 Applications"])

        for item in workspace.items:
            if isinstance(item, UrlItem):
                url_item = QTreeWidgetItem([f"🌐 {item.name}"])
                url_root.addChild(url_item)
            elif isinstance(item, ExecutableItem):
                app_item = QTreeWidgetItem([f"💻 {item.name}"])
                app_root.addChild(app_item)

        # Only add category if it contains items
        if url_root.childCount() > 0:
            self.tree_widget.addTopLevelItem(url_root)
        if app_root.childCount() > 0:
            self.tree_widget.addTopLevelItem(app_root)

        # Expand categories
        url_root.setExpanded(True)
        app_root.setExpanded(True)

    def clear(self):
        self.tree_widget.clear()

    def show_message(self, message: str):
        self.tree_widget.clear()
        item = QTreeWidgetItem([message])
        self.tree_widget.addTopLevelItem(item)