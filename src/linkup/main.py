from services.workspace_service import WorkspaceService
from services.launcher_service import LauncherService
from pathlib import Path


def main():
    print("Hello from linkup!")
    workspace = WorkspaceService.load(
        Path("D:/GitWork/LinkUp/config/workspace.json")
    )
    LauncherService.launch(workspace)
    print(workspace)


if __name__ == "__main__":
    main()
