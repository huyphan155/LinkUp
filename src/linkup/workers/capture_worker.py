from PyQt6.QtCore import QObject, pyqtSignal

from services.application_capture import ApplicationCapture


class CaptureWorker(QObject):

    finished = pyqtSignal()
    error = pyqtSignal(str)

    def run(self):
        """
        Run application capture in background thread.
        """

        try:
            # application is capture and export to ./config/current_app.json
            ApplicationCapture.export()

        except Exception as e:
            self.error.emit(str(e))

        else:
            self.finished.emit()