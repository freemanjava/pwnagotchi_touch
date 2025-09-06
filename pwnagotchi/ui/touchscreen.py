import threading
import time
import logging
import subprocess
import os
from threading import Lock

try:
    import evdev
    from evdev import InputDevice, categorize, ecodes
    EVDEV_AVAILABLE = True
except ImportError:
    EVDEV_AVAILABLE = False
    logging.warning("evdev not available, touchscreen functionality disabled")


class TouchHandler:
    def __init__(self, config, view):
        self._config = config
        self._view = view
        self._running = False
        self._thread = None
        self._lock = Lock()
        self._touch_device = None
        self._callbacks = {}
        self._last_touch = 0
        self._debounce_time = 0.3  # 300ms debounce

        # Touch zones for 250x122 display (Waveshare 2.13")
        self._touch_zones = {
            'menu': {'x': (0, 83), 'y': (0, 40)},      # Top left - Menu
            'action': {'x': (84, 166), 'y': (0, 40)},   # Top center - Action
            'stop': {'x': (167, 250), 'y': (0, 40)},    # Top right - Stop
            'bt_scan': {'x': (0, 125), 'y': (41, 81)},  # Middle left - BT Scan
            'bt_util': {'x': (126, 250), 'y': (41, 81)}, # Middle right - BT Utils
            'status': {'x': (0, 250), 'y': (82, 122)}   # Bottom - Status area
        }

        if EVDEV_AVAILABLE:
            self._find_touch_device()

    def _find_touch_device(self):
        """Find the touchscreen input device"""
        try:
            devices = [evdev.InputDevice(path) for path in evdev.list_devices()]
            for device in devices:
                if 'touch' in device.name.lower() or 'tp' in device.name.lower():
                    self._touch_device = device
                    logging.info(f"Found touchscreen device: {device.name}")
                    break

            if not self._touch_device and devices:
                # Fallback to first input device
                self._touch_device = devices[0]
                logging.info(f"Using fallback input device: {self._touch_device.name}")

        except Exception as e:
            logging.error(f"Error finding touch device: {e}")

    def register_callback(self, zone, callback):
        """Register a callback for a touch zone"""
        with self._lock:
            self._callbacks[zone] = callback

    def _get_touch_zone(self, x, y):
        """Determine which zone was touched"""
        for zone, coords in self._touch_zones.items():
            if (coords['x'][0] <= x <= coords['x'][1] and
                coords['y'][0] <= y <= coords['y'][1]):
                return zone
        return None

    def _handle_touch_event(self, event):
        """Process touch events"""
        current_time = time.time()

        # Debounce touches
        if current_time - self._last_touch < self._debounce_time:
            return

        self._last_touch = current_time

        # Simple touch detection - you may need to adjust based on your specific touchscreen
        if event.type == ecodes.EV_ABS:
            if event.code == ecodes.ABS_X:
                self._touch_x = event.value
            elif event.code == ecodes.ABS_Y:
                self._touch_y = event.value
        elif event.type == ecodes.EV_KEY and event.code == ecodes.BTN_TOUCH and event.value == 1:
            # Touch press detected
            if hasattr(self, '_touch_x') and hasattr(self, '_touch_y'):
                # Scale coordinates to display size (250x122)
                x = int((self._touch_x / 4096.0) * 250)  # Adjust scaling as needed
                y = int((self._touch_y / 4096.0) * 122)

                zone = self._get_touch_zone(x, y)
                if zone and zone in self._callbacks:
                    logging.info(f"Touch detected in zone: {zone} at ({x}, {y})")
                    try:
                        self._callbacks[zone]()
                    except Exception as e:
                        logging.error(f"Error executing callback for zone {zone}: {e}")

    def _touch_thread(self):
        """Main touch handling thread"""
        if not self._touch_device:
            logging.warning("No touch device available")
            return

        try:
            for event in self._touch_device.read_loop():
                if not self._running:
                    break
                self._handle_touch_event(event)
        except Exception as e:
            logging.error(f"Touch thread error: {e}")

    def start(self):
        """Start touch handling"""
        if not EVDEV_AVAILABLE or not self._touch_device:
            logging.warning("Touch handling not available")
            return

        with self._lock:
            if not self._running:
                self._running = True
                self._thread = threading.Thread(target=self._touch_thread, daemon=True)
                self._thread.start()
                logging.info("Touch handler started")

    def stop(self):
        """Stop touch handling"""
        with self._lock:
            if self._running:
                self._running = False
                if self._thread:
                    self._thread.join(timeout=1.0)
                logging.info("Touch handler stopped")
