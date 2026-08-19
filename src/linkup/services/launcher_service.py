
from models.workspace import Workspace
from models.launch_result import LaunchResult
import subprocess

CHROME_PATH = r"C:\Program Files\Google\Chrome\Application\chrome.exe"

class LauncherService:

    @staticmethod
    def launch(workspace: Workspace)-> list[LaunchResult]:
        results: list[LaunchResult] = []

        for item in workspace.items:

            try:
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

                results.append(LaunchResult(
                    name=item.name,
                    success=True,
                ))

            except Exception as e:
                results.append(LaunchResult(
                    name=item.name,
                    success=False,
                    error=str(e)
                ))

        return results