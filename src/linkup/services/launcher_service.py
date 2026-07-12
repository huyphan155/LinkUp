from models.workspace import Workspace
import subprocess

CHROME_PATH = r"C:\Program Files\Google\Chrome\Application\chrome.exe"

class LauncherService:

    @staticmethod
    def launch(workspace: Workspace)-> None:
        for item in workspace.items:
            if type(item).__name__ == "UrlItem":
                cmd = [
                    CHROME_PATH,
                    f"--profile-directory={item.profile}",
                    item.url
                ]
                subprocess.Popen(cmd)

            elif type(item).__name__ == "ExecutableItem":
                subprocess.Popen(
                    [item.path] + item.arguments
                )
            else:
                raise ValueError("Unknown")