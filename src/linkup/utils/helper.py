from models.launch_result import LaunchResult

def log_launch_results(activity_log, results: list[LaunchResult]):
    """
    Log launch results to ActivityLogWidget.
    """
    success_count = 0

    if not results:
        activity_log.log("No items to launch.")
        return

    for result in results:
        if result.success:
            activity_log.log(f"✔ {result.name}")
            success_count += 1
        else:
            activity_log.log(f"✘ {result.name} - {result.error}")

    activity_log.log(f"Launch completed: {success_count}/{len(results)}")