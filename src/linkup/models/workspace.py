from dataclasses import dataclass, field
from .base_item import BaseItem


@dataclass
class Workspace:
    name: str
    description: str = ""
    items: list[BaseItem] = field(default_factory=list)