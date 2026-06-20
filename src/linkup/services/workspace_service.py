from pathlib import Path
import json

from models.workspace import Workspace
from models.base_item import BaseItem
from models.executable_item import ExecutableItem
from models.url_item import UrlItem

class WorkspaceService:

    @staticmethod
    def load(path: Path) -> Workspace:
        items = []
        # deserialize ( Read file )
        with open(path, "r", encoding="utf-8") as file:
            data = json.load(file)  # data is a dict
            for item in data.get("items", []):
                if item["type"] == "url":
                    url_item = UrlItem(
                        name=item["name"],
                        enabled=item.get("enabled", True),
                        delay=item.get("delay", 0),
                        url=item["url"]
                    )
                    items.append(url_item)
                elif item["type"] == "executable":
                    executable_item = ExecutableItem(
                        name=item["name"],
                        enabled=item.get("enabled", True),
                        delay=item.get("delay", 0),
                        path=item["path"],
                        arguments=item.get("arguments", [])
                    )
                    items.append(executable_item)

        return Workspace(
            name=data["name"],
            description=data.get("description", ""),
            items=items,
        )


# rename

# delete

# search

# favorite