from pathlib import Path
from utils.path_connect import CONFIG_DIR

class ConfigProfileService:
    """
    Manage all LinkUp config profiles (.json).
    """

    @staticmethod
    def scan() -> list[Path]:
        """
        Scan config folder and return all workspace profiles.
        """
        if not CONFIG_DIR.exists():
            return []

        if not CONFIG_DIR.is_dir():
            return []

        # .glob("*.json") find only .json in (no recursive)
        # sorted() : a -> Z
        config_files = sorted(CONFIG_DIR.glob("*.json"))

        return config_files

    @staticmethod
    def exists(profile_name: str) -> bool:
        """
        Check whether a config profile exists.
        """
        profile_path = (CONFIG_DIR /f"{profile_name}.json")

        return profile_path.exists()

    @staticmethod
    def get(profile_name: str) -> Path | None:
        """
        Return config profile path.
        """
        profile_path = (CONFIG_DIR /f"{profile_name}.json")

        if profile_path.exists():
            return profile_path

        return None

    @staticmethod
    def delete(profile_name: str) -> bool:
        """
        Delete a config profile.
        """
        profile_path = ConfigProfileService.get(profile_name)

        if profile_path is None:
            return False

        profile_path.unlink()
        return True

    @staticmethod
    def rename(old_name: str, new_name: str) -> bool:
        """
        Rename a config profile.
        """
        old_path = ConfigProfileService.get(old_name)

        if old_path is None:
            return False

        new_path = (CONFIG_DIR /f"{new_name}.json")

        old_path.rename(new_path)
        return True