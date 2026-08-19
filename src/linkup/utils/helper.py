from models.launch_result import LaunchResult

def log_launch_results(activity_log, results: list[LaunchResult]):
    """
    Log launch results to ActivityLogWidget.
    """

    for result in results:
        if result.success:
            activity_log.log(
                f"✔ {result.name}"
            )
        else:
            activity_log.log(
                f"✘ {result.name} - {result.error}"
            )