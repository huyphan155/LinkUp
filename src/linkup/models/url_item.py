from dataclasses import dataclass

from .base_item import BaseItem


@dataclass
class UrlItem(BaseItem):
    url: str = ""