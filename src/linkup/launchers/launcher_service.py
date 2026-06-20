from models.workspace import Workspace
import webbrowser
import subprocess

class LauncherService:

    @staticmethod
    def launch(workspace: Workspace)-> None:
        for item in workspace.items:
            if type(item).__name__ == "UrlItem":
                webbrowser.open(item.url)
            elif type(item).__name__ == "ExecutableItem":
                subprocess.Popen(
                    [item.path] + item.arguments
                )
            else:
                raise ValueError("Unknown")