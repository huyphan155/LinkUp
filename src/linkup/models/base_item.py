from dataclasses import dataclass

@dataclass
class BaseItem:
    name: str
    enabled: bool = True
    delay: int = 0