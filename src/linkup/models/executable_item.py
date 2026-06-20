from dataclasses import dataclass, field

from .base_item import BaseItem


@dataclass
class ExecutableItem(BaseItem):
    path: str = ""
    arguments: list[str] = field(default_factory=list)