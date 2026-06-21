from pathlib import Path
import json

from models.workspace import Workspace
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
                        url=item["url"],
                        profile=item.get("profile", "Default")
                    )
                    items.append(url_item)
                elif item["type"] == "executable":
                    executable_item = ExecutableItem(
                        name=item["name"],
                        enabled=item.get("enabled", True),
                        path=item["path"],
                        arguments=item.get("arguments", [])
                    )
                    items.append(executable_item)
                else:
                    raise ValueError(f"Unknown item type: {item['type']}")

        return Workspace(
            name=data["name"],
            description=data.get("description", ""),
            items=items,
        )


# rename

# delete

# search

# favorite