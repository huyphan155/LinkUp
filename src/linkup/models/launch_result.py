from dataclasses import dataclass

@dataclass
class LaunchResult:
    name: str
    success: bool
    error: str = ""