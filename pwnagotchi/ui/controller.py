import logging
import threading
import time
import subprocess
import os
from enum import Enum
from threading import Lock

from pwnagotchi.ui.touchscreen import TouchHandler


class UIMode(Enum):
    MENU = "menu"
    PAWNING = "pawning"
    BLUETOOTH = "bluetooth"
    STOPPED = "stopped"


class UIController:
    def __init__(self, agent, view, config):
        self._agent = agent
        self._view = view
        self._config = config
        self._lock = Lock()
        self._current_mode = UIMode.MENU
        self._pawning_active = False
        self._bluetooth_scanning = False
        self._bluetooth_devices = []

        # Initialize touch handler
        self._touch_handler = TouchHandler(config, view)
        self._setup_touch_callbacks()

        # Status messages
        self._status_message = "Ready - Touch to interact"
        self._last_action = None

        # Bluetooth utilities
        self._bt_process = None

    def _setup_touch_callbacks(self):
        """Setup touch zone callbacks"""
        self._touch_handler.register_callback('menu', self._on_menu_touch)
        self._touch_handler.register_callback('action', self._on_action_touch)
        self._touch_handler.register_callback('stop', self._on_stop_touch)
        self._touch_handler.register_callback('bt_scan', self._on_bt_scan_touch)
        self._touch_handler.register_callback('bt_util', self._on_bt_util_touch)

    def start(self):
        """Start the UI controller"""
        self._touch_handler.start()
        self._update_display()
        logging.info("UI Controller started in menu mode")

    def stop(self):
        """Stop the UI controller"""
        self._touch_handler.stop()
        self._stop_all_activities()
        logging.info("UI Controller stopped")

    def _stop_all_activities(self):
        """Stop all running activities"""
        if self._pawning_active:
            self._stop_pawning()
        if self._bluetooth_scanning:
            self._stop_bluetooth_scan()

    def _on_menu_touch(self):
        """Handle menu button touch"""
        with self._lock:
            self._current_mode = UIMode.MENU
            self._status_message = "Menu - Select an action"
            self._update_display()
            logging.info("Switched to menu mode")

    def _on_action_touch(self):
        """Handle action button touch - toggles pawning"""
        with self._lock:
            if self._current_mode == UIMode.MENU:
                if not self._pawning_active:
                    self._start_pawning()
                else:
                    self._stop_pawning()
            elif self._current_mode == UIMode.BLUETOOTH:
                if not self._bluetooth_scanning:
                    self._start_bluetooth_scan()
                else:
                    self._stop_bluetooth_scan()

    def _on_stop_touch(self):
        """Handle stop button touch"""
        with self._lock:
            self._stop_all_activities()
            self._current_mode = UIMode.STOPPED
            self._status_message = "All activities stopped"
            self._update_display()
            logging.info("All activities stopped by user")

    def _on_bt_scan_touch(self):
        """Handle Bluetooth scan touch"""
        with self._lock:
            self._current_mode = UIMode.BLUETOOTH
            self._status_message = "Bluetooth mode - Touch Action to scan"
            self._update_display()
            logging.info("Switched to Bluetooth mode")

    def _on_bt_util_touch(self):
        """Handle Bluetooth utilities touch"""
        with self._lock:
            if self._current_mode == UIMode.BLUETOOTH:
                self._show_bluetooth_devices()

    def _start_pawning(self):
        """Start pawning activity"""
        try:
            if not self._pawning_active:
                # Switch agent to auto mode
                self._agent.mode = 'auto'

                # Start pawning in a separate thread
                self._pawning_thread = threading.Thread(target=self._pawning_worker, daemon=True)
                self._pawning_thread.start()

                self._pawning_active = True
                self._current_mode = UIMode.PAWNING
                self._status_message = "Pawning active - Hunting networks"
                self._last_action = "Started pawning"
                self._update_display()
                logging.info("Pawning started by user")
        except Exception as e:
            logging.error(f"Error starting pawning: {e}")
            self._status_message = f"Error: {str(e)[:30]}"
            self._update_display()

    def _stop_pawning(self):
        """Stop pawning activity"""
        try:
            if self._pawning_active:
                self._pawning_active = False
                # Switch agent to manual mode
                self._agent.mode = 'manual'

                self._status_message = "Pawning stopped"
                self._last_action = "Stopped pawning"
                self._update_display()
                logging.info("Pawning stopped by user")
        except Exception as e:
            logging.error(f"Error stopping pawning: {e}")

    def _pawning_worker(self):
        """Worker thread for pawning operations"""
        try:
            while self._pawning_active:
                if self._agent.mode == 'auto':
                    # Perform one cycle of recon and attacks
                    self._agent.recon()
                    channels = self._agent.get_access_points_by_channel()

                    for ch, aps in channels:
                        if not self._pawning_active:
                            break

                        time.sleep(1)
                        self._agent.set_channel(ch)

                        if not self._agent.is_stale() and self._agent.any_activity():
                            with self._lock:
                                self._status_message = f"Ch {ch}: {len(aps)} APs found"
                                self._update_display()

                        for ap in aps:
                            if not self._pawning_active:
                                break

                            # Associate for PMKID
                            self._agent.associate(ap)

                            # Deauth clients for handshakes
                            for sta in ap['clients']:
                                if not self._pawning_active:
                                    break
                                self._agent.deauth(ap, sta)
                                time.sleep(1)

                    self._agent.next_epoch()

                time.sleep(2)  # Small delay between cycles

        except Exception as e:
            logging.error(f"Pawning worker error: {e}")
            with self._lock:
                self._status_message = f"Pawning error: {str(e)[:20]}"
                self._pawning_active = False
                self._update_display()

    def _start_bluetooth_scan(self):
        """Start Bluetooth device scan"""
        try:
            if not self._bluetooth_scanning:
                self._bluetooth_scanning = True
                self._bluetooth_devices = []
                self._status_message = "Scanning for BT devices..."
                self._update_display()

                # Start Bluetooth scan in thread
                self._bt_thread = threading.Thread(target=self._bluetooth_scan_worker, daemon=True)
                self._bt_thread.start()

                logging.info("Bluetooth scan started")
        except Exception as e:
            logging.error(f"Error starting Bluetooth scan: {e}")
            self._status_message = f"BT Error: {str(e)[:20]}"
            self._update_display()

    def _stop_bluetooth_scan(self):
        """Stop Bluetooth scan"""
        try:
            if self._bluetooth_scanning:
                self._bluetooth_scanning = False
                if self._bt_process:
                    self._bt_process.terminate()
                    self._bt_process = None

                self._status_message = f"Found {len(self._bluetooth_devices)} BT devices"
                self._last_action = "BT scan completed"
                self._update_display()
                logging.info("Bluetooth scan stopped")
        except Exception as e:
            logging.error(f"Error stopping Bluetooth scan: {e}")

    def _bluetooth_scan_worker(self):
        """Worker thread for Bluetooth scanning"""
        try:
            # Use bluetoothctl or hcitool for scanning
            cmd = ["bluetoothctl", "scan", "on"]
            self._bt_process = subprocess.Popen(cmd, stdout=subprocess.PIPE,
                                              stderr=subprocess.PIPE, text=True)

            scan_time = 0
            max_scan_time = 30  # 30 seconds max scan

            while self._bluetooth_scanning and scan_time < max_scan_time:
                time.sleep(1)
                scan_time += 1

                # Get discovered devices
                try:
                    result = subprocess.run(["bluetoothctl", "devices"],
                                          capture_output=True, text=True, timeout=5)
                    if result.returncode == 0:
                        devices = []
                        for line in result.stdout.split('\n'):
                            if line.startswith('Device'):
                                parts = line.split(' ', 2)
                                if len(parts) >= 3:
                                    mac = parts[1]
                                    name = parts[2] if len(parts) > 2 else "Unknown"
                                    devices.append({'mac': mac, 'name': name})

                        with self._lock:
                            self._bluetooth_devices = devices
                            self._status_message = f"BT: {len(devices)} devices ({scan_time}s)"
                            self._update_display()

                except subprocess.TimeoutExpired:
                    pass
                except Exception as e:
                    logging.error(f"Bluetooth scan error: {e}")

            # Stop scanning
            if self._bt_process:
                subprocess.run(["bluetoothctl", "scan", "off"], timeout=5)
                self._bt_process.terminate()
                self._bt_process = None

            self._bluetooth_scanning = False

        except Exception as e:
            logging.error(f"Bluetooth scan worker error: {e}")
            self._bluetooth_scanning = False

    def _show_bluetooth_devices(self):
        """Show discovered Bluetooth devices"""
        with self._lock:
            if self._bluetooth_devices:
                # Show first few devices in status
                device_count = len(self._bluetooth_devices)
                if device_count > 0:
                    first_device = self._bluetooth_devices[0]['name'][:15]
                    self._status_message = f"{device_count} devices: {first_device}..."
                else:
                    self._status_message = "No BT devices found"
            else:
                self._status_message = "No BT scan performed yet"

            self._update_display()

    def _update_display(self):
        """Update the display with current status"""
        try:
            # Update view state with current information
            mode_text = self._current_mode.value.upper()

            # Set status elements
            if hasattr(self._view, '_state'):
                self._view._state.set('mode', mode_text)
                self._view._state.set('status', self._status_message)

                # Update activity indicators
                if self._pawning_active:
                    self._view._state.set('activity', 'PAWNING')
                elif self._bluetooth_scanning:
                    self._view._state.set('activity', 'BT_SCAN')
                else:
                    self._view._state.set('activity', 'IDLE')

            # Force display update
            self._view.update(force=True)

        except Exception as e:
            logging.error(f"Error updating display: {e}")

    def get_status(self):
        """Get current status information"""
        with self._lock:
            return {
                'mode': self._current_mode.value,
                'pawning_active': self._pawning_active,
                'bluetooth_scanning': self._bluetooth_scanning,
                'bluetooth_devices': len(self._bluetooth_devices),
                'status_message': self._status_message,
                'last_action': self._last_action
            }
